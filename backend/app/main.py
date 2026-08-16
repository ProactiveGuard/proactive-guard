from fastapi import FastAPI
from pydantic import BaseModel
from datetime import datetime

# Import Member 5's amazing AI Engine!
from ai_engine.risk import evaluate_risk, generate_ai_summary
# Import Member 5's LLM summary generator (Gemini, with offline fallback)
from app.services.llm import generate_police_summary
# Import the Supabase connection we just created
from app.services.supabase import supabase_db

app = FastAPI(title="Proactive Guard API")

# Data Models
class TelemetryData(BaseModel):
    user_id: str
    latitude: float
    longitude: float
    motion_score: float
    audio_score: float
    distance_off_route_m: float = 0.0

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
    # 1. Ask Member 5's AI engine to evaluate the danger!
    # (Assuming time is 22:00 and they are slightly off route for testing)
    risk_data = evaluate_risk(
        audio_level=int(data.audio_score), 
        motion_speed=int(data.motion_score),
        time_of_day=22, 
        is_off_route=False, 
        location_name="Unknown Location",
        distance_off_route_m=data.distance_off_route_m
    )
    
    # 2. Get the beautiful AI summary (Gemini writes it; offline fallback included)
    summary_text = generate_police_summary(
        audio_score=data.audio_score,
        motion_score=data.motion_score,
        distance_off_route=data.distance_off_route_m,
        risk_level=risk_data["risk_level"],
        risk_score=risk_data["risk_score"],
    )
    
    incident_id = f"INC-{int(datetime.now().timestamp())}"
    
    # 3. If it's dangerous, SAVE it to Supabase!
    if risk_data["risk_level"] in ["CRITICAL", "HIGH RISK"]:
        if supabase_db is not None:
            incident_record = {
                "incident_id": incident_id,
                "user_id": data.user_id,
                "severity": risk_data["risk_level"],
                "risk_score": risk_data["risk_score"],
                "latitude": data.latitude,
                "longitude": data.longitude,
                "summary": summary_text
            }
            try:
                # Insert into the 'incidents' table
                supabase_db.table("incidents").insert(incident_record).execute()
                print(f"Successfully saved incident {incident_id} to Supabase!")
            except Exception as e:
                print(f"Failed to save to Supabase (duplicate alert or DB issue): {e}")

    return {
        "incident_id": incident_id,
        "severity": risk_data["risk_level"],
        "risk_score": int(risk_data["risk_score"]),
        "summary": summary_text
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