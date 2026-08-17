from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

from ai_engine.risk import evaluate_risk, generate_ai_summary, detect_struggle
from app.services.llm import generate_police_summary, analyze_audio_transcript
from app.services.supabase import supabase_db


app = FastAPI(title="Proactive Guard API")


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
def receive_telemetry(data: TelemetryData):

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

    # Generate police summary
    summary_text = generate_police_summary(
        audio_score=data.audio_score,
        motion_score=data.motion_score,
        distance_off_route=data.distance_off_route_m,
        risk_level=risk_data["risk_level"],
        risk_score=risk_data["risk_score"],
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

            except Exception as e:
                print(
                    f"Failed to save incident to Supabase: {e}"
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
