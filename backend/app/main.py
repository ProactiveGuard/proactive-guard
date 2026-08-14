import sys
from pathlib import Path
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
import datetime

# Add root backend directory to sys.path to import ai-engine
sys.path.append(str(Path(__file__).resolve().parent.parent))
from ai_engine.risk import calculate_risk, evaluate_risk, generate_ai_summary

app = FastAPI(
    title="Proactive Guard API",
    description="Backend API for Proactive Guard emergency monitoring system",
    version="1.0.0"
)

# Enable CORS for Mobile App and Next.js Dashboard
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage for hackathon demonstration
incidents_db = [
    {
        "id": "INC-1001",
        "user_id": "U-047",
        "timestamp": "2026-08-15 00:10:00",
        "type": "Physical Distress",
        "status": "CRITICAL",
        "latitude": 28.6139,
        "longitude": 77.2090,
        "location_name": "Connaught Place, New Delhi",
        "audio_level": 9,
        "motion_speed": 8,
        "risk_score": 92.0,
        "summary": "User U-047 detected in CRITICAL state (Risk Score: 92.0/100) near Connaught Place. Loud distress/ambient audio recorded (9/10). Rapid movement/running detected (8/10). Immediate attention required.",
        "action_recommended": "Dispatch Emergency Services & Notify Police Immediately"
    }
]

journeys_db = []

# --- Data Models ---
class SOSRequest(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    location_name: Optional[str] = "Current Location"
    audio_level: Optional[int] = 8
    motion_speed: Optional[int] = 7

class JourneyStartRequest(BaseModel):
    user_id: str
    destination: str
    start_latitude: float
    start_longitude: float

class TelemetryRequest(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    audio_level: int
    motion_speed: int
    is_off_route: Optional[bool] = False
    location_name: Optional[str] = "En Route"

# --- Endpoints ---

@app.get("/")
def read_root():
    return {
        "app": "Proactive Guard API",
        "status": "Online",
        "version": "1.0.0",
        "docs": "/docs"
    }

@app.get("/ping")
def check_status():
    return {
        "status": "I am alive!",
        "message": "The backend boss has successfully added a new feature."
    }

@app.get("/incidents")
def get_incidents():
    """Retrieve list of active incidents for the Command Center dashboard."""
    return incidents_db

@app.post("/sos")
def trigger_sos(request: SOSRequest):
    """Trigger manual SOS alert from Mobile App."""
    now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    hour = datetime.datetime.now().hour
    
    # Calculate AI risk score
    eval_data = evaluate_risk(
        audio_level=request.audio_level,
        motion_speed=request.motion_speed,
        time_of_day=hour,
        is_off_route=False,
        location_name=request.location_name
    )
    
    summary_text = generate_ai_summary(request.user_id, eval_data)
    
    incident_id = f"INC-{1000 + len(incidents_db) + 1}"
    new_incident = {
        "id": incident_id,
        "user_id": request.user_id,
        "timestamp": now,
        "type": "Manual SOS Trigger",
        "status": "CRITICAL",
        "latitude": request.latitude,
        "longitude": request.longitude,
        "location_name": request.location_name,
        "audio_level": request.audio_level,
        "motion_speed": request.motion_speed,
        "risk_score": eval_data["risk_score"],
        "summary": f"MANUAL SOS BUTTON PRESSED! {summary_text}",
        "action_recommended": eval_data["action_recommended"]
    }
    
    incidents_db.insert(0, new_incident)
    return {
        "message": "SOS Alert Broadcasted to Command Center Successfully",
        "incident": new_incident
    }

@app.post("/journey/start")
def start_journey(request: JourneyStartRequest):
    """Start tracking user journey."""
    journey = {
        "journey_id": f"JRN-{len(journeys_db) + 101}",
        "user_id": request.user_id,
        "destination": request.destination,
        "status": "ACTIVE",
        "started_at": datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S"),
        "current_location": [request.start_latitude, request.start_longitude]
    }
    journeys_db.append(journey)
    return {
        "message": "Journey started safely",
        "journey": journey
    }

@app.post("/journey/stop")
def stop_journey(user_id: str):
    """Stop active user journey."""
    for j in journeys_db:
        if j["user_id"] == user_id and j["status"] == "ACTIVE":
            j["status"] = "COMPLETED"
            j["stopped_at"] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            return {"message": "Journey ended safely", "journey": j}
    return {"message": "No active journey found"}

@app.post("/telemetry")
def receive_telemetry(request: TelemetryRequest):
    """Receive periodic telemetry from Mobile app and evaluate risk using AI engine."""
    hour = datetime.datetime.now().hour
    
    eval_data = evaluate_risk(
        audio_level=request.audio_level,
        motion_speed=request.motion_speed,
        time_of_day=hour,
        is_off_route=request.is_off_route,
        location_name=request.location_name
    )
    
    # If high risk or critical, automatically convert to incident
    if eval_data["risk_level"] in ["HIGH RISK", "CRITICAL"]:
        summary_text = generate_ai_summary(request.user_id, eval_data)
        now = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        incident_id = f"INC-{1000 + len(incidents_db) + 1}"
        
        new_incident = {
            "id": incident_id,
            "user_id": request.user_id,
            "timestamp": now,
            "type": "Automated Anomaly Detection",
            "status": eval_data["risk_level"],
            "latitude": request.latitude,
            "longitude": request.longitude,
            "location_name": request.location_name,
            "audio_level": request.audio_level,
            "motion_speed": request.motion_speed,
            "risk_score": eval_data["risk_score"],
            "summary": summary_text,
            "action_recommended": eval_data["action_recommended"]
        }
        incidents_db.insert(0, new_incident)
        
    return {
        "user_id": request.user_id,
        "evaluation": eval_data
    }
