from fastapi import FastAPI, HTTPException, Request, WebSocket, WebSocketDisconnect, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration
from datetime import datetime
from typing import Optional
import sys
import os
from pathlib import Path

# Add backend to path for ai_engine imports
sys.path.append(str(Path(__file__).resolve().parent.parent))

from ai_engine.risk import evaluate_risk, generate_ai_summary, detect_struggle, RiskTracker
from app.services.llm import generate_police_summary, analyze_audio_transcript, gemini_enabled
from app.services.supabase import supabase_db
import time
from threading import Lock


app = FastAPI(title="Proactive Guard API")

# Initialize Rate Limiter
limiter = Limiter(key_func=get_remote_address)
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# Initialize Sentry (only if DSN is provided)
# sentry_dsn = os.getenv("SENTRY_DSN")
# if sentry_dsn:
#     sentry_sdk.init(dsn=sentry_dsn, traces_sample_rate=1.0, integrations=[FastApiIntegration()])

# Import WebSocket manager and Auth
from app.websockets import manager
from app.auth import create_access_token
from app.dependencies import get_current_user


# ============================================================
# AI METRICS TRACKING (Day 5)
# ============================================================

class AIMetrics:
    def __init__(self):
        self._lock = Lock()
        self.total_predictions = 0
        self.false_positives = 0
        self.true_positives = 0
        self.latency_sum_ms = 0.0
        self.language_distribution = {}
        self.risk_level_distribution = {}

    def record_prediction(self, risk_level: str, language: str, latency_ms: float, is_false_positive: bool = False):
        with self._lock:
            self.total_predictions += 1
            self.latency_sum_ms += latency_ms
            self.risk_level_distribution[risk_level] = self.risk_level_distribution.get(risk_level, 0) + 1
            self.language_distribution[language] = self.language_distribution.get(language, 0) + 1
            if is_false_positive:
                self.false_positives += 1
            else:
                self.true_positives += 1

    def get_metrics(self) -> dict:
        with self._lock:
            fp_rate = 0.0
            if self.total_predictions > 0:
                fp_rate = self.false_positives / self.total_predictions
            avg_latency = 0.0
            if self.total_predictions > 0:
                avg_latency = self.latency_sum_ms / self.total_predictions
            return {
                "total_predictions": self.total_predictions,
                "false_positive_rate": round(fp_rate, 4),
                "avg_latency_ms": round(avg_latency, 2),
                "language_distribution": self.language_distribution,
                "risk_level_distribution": self.risk_level_distribution,
            }


ai_metrics = AIMetrics()


# ============================================================
# CORS CONFIGURATION
# ============================================================

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ============================================================
# DATA MODELS
# ============================================================

class TelemetryData(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    motion_score: float
    audio_score: float
    distance_off_route_m: float = 0.0
    previous_motion_score: Optional[float] = None
    audio_transcript: Optional[str] = None


class IncidentResponse(BaseModel):
    incident_id: str
    severity: str
    risk_score: int
    summary: str


class JourneyRequest(BaseModel):
    user_id: str


# ============================================================
# ROOT
# ============================================================

@app.get("/")
def read_root():
    return {
        "message": "Proactive Guard API is running!"
    }


# ============================================================
# PING / HEALTH CHECK
# ============================================================

@app.get("/ping")
def check_status():
    return {
        "status": "I am ok",
        "message": "Proactive Guard API is running and ready to receive telemetry data."
    }


# ============================================================
# TELEMETRY
# ============================================================

@app.post("/api/v1/telemetry", response_model=IncidentResponse)
@limiter.limit("10/minute")
async def receive_telemetry(request: Request, data: TelemetryData):

    start_time = time.time()
    
    # Day 3: Run NLP threat analysis on audio transcript if provided
    transcript_threat = None
    if data.audio_transcript:
        transcript_result = analyze_audio_transcript(data.audio_transcript)
        transcript_threat = transcript_result.get("is_threat", False)

    # Evaluate risk using AI engine (Day 3: includes struggle + transcript overrides)
    risk_data = evaluate_risk(
        audio_level=int(data.audio_score),
        motion_speed=int(data.motion_score),
        time_of_day=22,
        is_off_route=data.distance_off_route_m > 0,
        location_name="Unknown Location",
        distance_off_route_m=data.distance_off_route_m,
        previous_motion=int(data.previous_motion_score) if data.previous_motion_score is not None else None,
        audio_transcript_threat=transcript_threat,
    )

    # Determine language for summary based on location
    language = "English"
    try:
        from ai_engine.risk import get_language_for_location
        language = get_language_for_location(data.latitude, data.longitude)
    except Exception:
        pass

    # Generate police summary
    summary_text = generate_police_summary(
        audio_score=data.audio_score,
        motion_score=data.motion_score,
        distance_off_route=data.distance_off_route_m,
        risk_level=risk_data["risk_level"],
        risk_score=risk_data["risk_score"],
        language=language,
    )

    # Generate incident ID
    incident_id = f"INC-{int(datetime.now().timestamp())}"

    # Save high-risk incidents to Supabase
    if risk_data["risk_level"] in ["CRITICAL", "HIGH RISK"]:

        if supabase_db is not None:

            incident_record = {
                "incident_id": incident_id,
                "user_id": data.user_id,
                "severity": risk_data["risk_level"],
                "risk_score": int(risk_data["risk_score"]),
                "latitude": data.latitude,
                "longitude": data.longitude,
                "summary": summary_text,
            }

            try:
                supabase_db.table("incidents").insert(
                    incident_record
                ).execute()

                print(
                    f"Successfully saved incident {incident_id} to Supabase!"
                )
                
                # Broadcast the incident to all connected dashboards via WebSocket!
                await manager.broadcast(incident_record)

            except Exception as e:
                print(
                    f"Failed to save incident to Supabase: {e}"
                )

    # Record AI metrics
    latency_ms = (time.time() - start_time) * 1000
    ai_metrics.record_prediction(
        risk_level=risk_data["risk_level"],
        language=language,
        latency_ms=latency_ms,
    )

    return {
        "incident_id": incident_id,
        "severity": risk_data["risk_level"],
        "risk_score": int(risk_data["risk_score"]),
        "summary": summary_text,
    }


# ============================================================
# GET INCIDENTS
# ============================================================

@app.get("/incidents")
def get_incidents():

    # Try Supabase first
    if supabase_db is not None:

        try:
            response = (
                supabase_db
                .table("incidents")
                .select("*")
                .order("risk_score", desc=True)
                .execute()
            )

            if response.data:
                return response.data

        except Exception as e:
            print(
                f"Could not fetch incidents from Supabase: {e}"
            )

    # Fallback demo incidents
    return [
        {
            "incident_id": "INC-1001",
            "severity": "CRITICAL",
            "risk_score": 92,
            "latitude": 19.123,
            "longitude": 72.891,
            "summary": (
                "Possible physical distress detected. "
                "Audio score is very high."
            ),
        },
        {
            "incident_id": "INC-1002",
            "severity": "MONITOR",
            "risk_score": 45,
            "latitude": 19.125,
            "longitude": 72.895,
            "summary": (
                "User deviated slightly from the planned route."
            ),
        },
    ]


# ============================================================
# START JOURNEY
# ============================================================

@app.post("/api/v1/journey/start")
def start_journey(request: JourneyRequest):

    journey_id = f"JRN-{int(datetime.now().timestamp())}"

    journey_data = {
        "journey_id": journey_id,
        "user_id": request.user_id,
        "status": "active",
        "start_time": str(datetime.now()),
    }

    if supabase_db is not None:

        try:
            supabase_db.table("journeys").insert(
                journey_data
            ).execute()

        except Exception as e:
            raise HTTPException(
                status_code=500,
                detail=f"Database error: {str(e)}",
            )

    return {
        "message": "Journey started successfully!",
        "journey_id": journey_id,
        "user_id": request.user_id,
        "status": "active",
        "start_time": journey_data["start_time"],
    }


# ============================================================
# STOP JOURNEY
# ============================================================

@app.post("/api/v1/journey/stop")
def stop_journey(journey_id: str):

    if supabase_db is None:
        return {
            "message": f"Journey {journey_id} has safely concluded.",
            "journey_id": journey_id,
            "status": "completed",
        }

    try:

        supabase_db.table("journeys").update(
            {
                "status": "completed",
                "end_time": str(datetime.now()),
            }
        ).eq(
            "journey_id",
            journey_id
        ).execute()

        return {
            "message": f"Journey {journey_id} has safely concluded.",
            "journey_id": journey_id,
            "status": "completed",
        }

    except Exception as e:

        raise HTTPException(
            status_code=500,
            detail=f"Could not stop journey: {str(e)}",
        )


# ============================================================
# AI METRICS ENDPOINT (Day 5)
# ============================================================

@app.get("/api/v1/metrics/ai")
def get_ai_metrics():
    """
    Returns AI model performance metrics for monitoring.
    
    Includes:
    - Total predictions made
    - False positive rate
    - Average latency
    - Language distribution
    - Risk level distribution
    """
    return ai_metrics.get_metrics()


@app.get("/api/v1/health/ai")
def ai_health_check():
    """
    Health check for AI components.
    """
    return {
        "gemini_configured": gemini_enabled(),
        "model": "gemini-2.5-flash" if gemini_enabled() else "rule-based fallback",
        "risk_engine": "v2.0 - temporal smoothing + confidence thresholds + multi-language",
        "geo_engine": "Haversine formula with 500m off-route threshold",
    }


# ============================================================
# AUTHENTICATION (Day 4)
# ============================================================
from pydantic import BaseModel
class AuthRequest(BaseModel):
    username: str
    password: str

@app.post("/api/v1/auth/register")
def register_user(request: AuthRequest):
    # Hackathon mock: normally you'd save to DB with hashed password
    return {"message": "User registered successfully"}

@app.post("/api/v1/auth/login")
def login_user(request: AuthRequest):
    # Hackathon mock: any password works
    access_token = create_access_token(data={"sub": request.username})
    return {"access_token": access_token, "token_type": "bearer"}


# ============================================================
# WEBSOCKET (Day 4)
# ============================================================
@app.websocket("/ws/incidents")
async def websocket_endpoint(ws: WebSocket):
    await manager.connect(ws)
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(ws)


# ============================================================
# DAY 4 - RESOLVE & ASSIGN ENDPOINTS
# ============================================================
@app.delete("/api/v1/incidents/{incident_id}")
async def resolve_incident(incident_id: str):
    if supabase_db is not None:
        try:
            supabase_db.table("incidents").delete().eq("incident_id", incident_id).execute()
            return {"message": "Incident resolved"}
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    return {"message": "Incident resolved (mock)"}

class AssignRequest(BaseModel):
    responder: str

@app.patch("/api/v1/incidents/{incident_id}/assign")
async def assign_responder(incident_id: str, request: AssignRequest):
    if supabase_db is not None:
        try:
            # Assuming you add a responder column in Supabase!
            supabase_db.table("incidents").update({"responder": request.responder}).eq("incident_id", incident_id).execute()
            return {"message": f"Assigned {request.responder}"}
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
    return {"message": f"Assigned {request.responder} (mock)"}

