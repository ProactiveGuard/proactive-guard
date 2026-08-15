from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime

app = FastAPI(title="Proactive Guard API (Mock Version)")

# Mock Data Models
class TelemetryData(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    motion_score: float
    audio_score: float

class IncidentResponse(BaseModel):
    incident_id: str
    severity: str
    risk_score: int
    summary: str

@app.get("/")
def read_root():
    return {"message": "Proactive Guard API is running!"}

@app.post("/api/v1/telemetry", response_model=IncidentResponse)
def receive_telemetry(data: TelemetryData):
    # This is our "Fake AI" for Day 1
    # We calculate a simple risk score based on the inputs
    risk = int((data.audio_score * 0.6 + data.motion_score * 0.4) * 100)
    
    severity = "SAFE"
    if risk > 80:
        severity = "CRITICAL"
    elif risk > 60:
        severity = "HIGH"
    elif risk > 30:
        severity = "MONITOR"

    return {
        "incident_id": f"INC-{int(datetime.now().timestamp())}",
        "severity": severity,
        "risk_score": risk,
        "summary": f"Received telemetry for user {data.user_id}. Audio and motion levels indicate {severity} status."
    }

@app.get("/incidents")
def get_incidents():
    # Return some fake incidents so the Dashboard team can start building the UI
    return [
        {
            "incident_id": "INC-1001",
            "severity": "CRITICAL",
            "risk_score": 92,
            "latitude": 19.123,
            "longitude": 72.891,
            "summary": "Possible physical distress detected. Audio score is very high."
        },
        {
            "incident_id": "INC-1002",
            "severity": "MONITOR",
            "risk_score": 45,
            "latitude": 19.125,
            "longitude": 72.895,
            "summary": "User deviated slightly from the planned route."
        }
    ]
@app.get("/ping")
def check_status():
    return{
        "status": "I am ok ",
        "message": "Proactive Guard API is running and ready to receive telemetry data."
    }