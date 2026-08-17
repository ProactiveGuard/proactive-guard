# Proactive Guard - AI Risk Engine
# Person 5: The "AI" & Logic Thinker

"""
Risk calculation engine and AI summary generator for Proactive Guard.

This module evaluates sensor inputs (audio level, motion speed, time of day, route status)
to calculate a risk score (0-100) and determine the safety level.
It also generates human-readable incident summaries for emergency dashboards.

Day 2 rule: if the user is more than OFF_ROUTE_THRESHOLD_M (500 meters) from the
planned route, add +3 to the total danger score.
"""

import sys
from pathlib import Path
from typing import Dict, Any, Optional

# Make backend/ importable so this script works when run directly
# (python ai_engine/risk.py) AND when imported by app/main.py.
sys.path.append(str(Path(__file__).resolve().parent.parent))

from ai_engine.geo import OFF_ROUTE_THRESHOLD_M


def detect_struggle(previous_motion: int, current_motion: int) -> bool:
    """
    Detects sudden, violent changes in movement (e.g., a phone dropping or a struggle).

    Day 3 upgrade: compares the delta between the previous and current motion score.
    A spike of 6+ points in a single reading indicates a fall, shove, or violent act.

    Parameters:
    - previous_motion (int): The user's last recorded motion score (1-10).
    - current_motion (int): The user's current motion score (1-10).

    Returns:
    - bool: True if a sudden anomaly is detected.
    """
    motion_spike = abs(current_motion - previous_motion)

    if motion_spike >= 6:
        print("ANOMALY DETECTED: Sudden violent movement/fall!")
        return True

    return False


def calculate_risk(
    audio_level: int,
    motion_speed: int,
    time_of_day: Optional[int] = None,
    is_off_route: bool = False,
    distance_off_route_m: Optional[float] = None,
    previous_motion: Optional[int] = None,
) -> str:
    """
    Beginner-friendly risk calculation function (Day 1 Playbook baseline).

    Parameters:
    - audio_level (int): 1 to 10 scale (1 = Silent, 10 = Screaming/Loud noise)
    - motion_speed (int): 1 to 10 scale (1 = Still, 10 = Running/Falling)
    - time_of_day (int, optional): Hour in 24-hour format (0-23). 2 AM - 6 AM adds sensitivity.
    - is_off_route (bool, optional): True if user deviated from planned route.
    - distance_off_route_m (float, optional): Distance from route in meters.
      If greater than 500, the user is treated as off-route (+3 danger score, Day 2 rule).

    - previous_motion (int, optional): Previous motion score for Day 3 struggle detection.
      If provided and a sudden spike is detected, risk is instantly set to CRITICAL.

    Returns:
    - str: Risk assessment decision string.
    """
    # Day 3: Struggle detection override - if a violent motion spike is detected,
    # bypass all normal math and instantly classify as CRITICAL (+25 points).
    if previous_motion is not None and detect_struggle(previous_motion, motion_speed):
        return "CRITICAL! Call Police immediately. Sudden anomaly detected (possible fall/struggle)."

    # Step 1: Weight the inputs (Audio 60%, Motion 40%)
    audio_score = audio_level * 0.6
    motion_score = motion_speed * 0.4
    total_score = audio_score + motion_score

    # Step 2: Nighttime sensitivity adjustment (2 AM to 6 AM adds +2, 10 PM to 2 AM adds +1)
    if time_of_day is not None:
        if 2 <= time_of_day <= 6:
            total_score += 2.0
        elif time_of_day >= 22 or time_of_day < 2:
            total_score += 1.0

    # Step 3: Off-route bonus (Day 2 rule: +3 if more than 500 meters off route)
    if distance_off_route_m is not None:
        is_off_route = distance_off_route_m > OFF_ROUTE_THRESHOLD_M
    if is_off_route:
        total_score += 3.0

    # Step 4: Decision thresholding
    if total_score >= 8.0:
        return "CRITICAL! Call Police immediately."
    elif total_score >= 6.0:
        return "HIGH RISK! Notify parents."
    elif total_score >= 4.0:
        return "MONITOR. User is moving fast or there is background noise."
    else:
        return "SAFE. Everything is normal."


def evaluate_risk(
    audio_level: int,
    motion_speed: int,
    time_of_day: Optional[int] = None,
    is_off_route: bool = False,
    location_name: str = "Unknown Location",
    distance_off_route_m: Optional[float] = None,
    previous_motion: Optional[int] = None,
    audio_transcript_threat: Optional[bool] = None,
) -> Dict[str, Any]:
    """
    Advanced risk evaluation returning detailed metrics, score out of 100, and recommended actions.

    Day 2 rule: if the user is more than OFF_ROUTE_THRESHOLD_M (500 meters)
    from the planned route, add +3 to the total danger score.

    Parameters:
    - distance_off_route_m (float, optional): Precomputed distance from the
      planned route in meters (compute it with geo.calculate_distance).
    - previous_motion (int, optional): Previous motion score for struggle detection (Day 3).
    - audio_transcript_threat (bool, optional): True if NLP analysis detected a threat
      in the user's transcribed audio (Day 3).

    Returns dict with keys:
    - risk_score (float): 0-100 scale
    - risk_level (str): SAFE | MONITOR | HIGH RISK | CRITICAL
    - decision_text (str): Short summary recommendation
    - action_recommended (str): Action to take
    - metrics (dict): Context parameters
    """
    # Clamp input values between 1 and 10
    audio = max(1, min(10, audio_level))
    motion = max(1, min(10, motion_speed))

    # Day 2: derive off-route status from GPS distance (500m rule)
    if distance_off_route_m is not None:
        is_off_route = distance_off_route_m > OFF_ROUTE_THRESHOLD_M

    # Day 3: Struggle detection override - instant CRITICAL
    if previous_motion is not None and detect_struggle(previous_motion, motion):
        return {
            "risk_score": 100.0,
            "risk_level": "CRITICAL",
            "decision_text": "CRITICAL! Call Police immediately. Sudden anomaly detected (possible fall/struggle).",
            "action_recommended": "Dispatch Emergency Services & Notify Police Immediately",
            "metrics": {
                "audio_level": audio,
                "motion_speed": motion,
                "time_of_day": time_of_day,
                "is_off_route": is_off_route,
                "location_name": location_name,
                "distance_off_route_m": distance_off_route_m,
                "struggle_detected": True,
                "transcript_threat": audio_transcript_threat,
            },
        }

    # Day 3: NLP transcript threat override - jump to CRITICAL
    if audio_transcript_threat is True:
        return {
            "risk_score": 95.0,
            "risk_level": "CRITICAL",
            "decision_text": "CRITICAL! Threat detected from audio analysis. Call Police immediately.",
            "action_recommended": "Dispatch Emergency Services & Notify Police Immediately",
            "metrics": {
                "audio_level": audio,
                "motion_speed": motion,
                "time_of_day": time_of_day,
                "is_off_route": is_off_route,
                "location_name": location_name,
                "distance_off_route_m": distance_off_route_m,
                "struggle_detected": False,
                "transcript_threat": True,
            },
        }

    # Base weighted score out of 10
    base_score = (audio * 0.6) + (motion * 0.4)

    # Multipliers & bonuses
    time_bonus = 0.0
    if time_of_day is not None:
        if 2 <= time_of_day <= 6:
            time_bonus = 2.0  # High night risk (2 AM - 6 AM)
        elif time_of_day >= 22 or time_of_day < 2:
            time_bonus = 1.0  # Moderate night risk (10 PM - 2 AM)

    route_bonus = 3.0 if is_off_route else 0.0  # Day 2 rule: +3 when off route

    # Scaled total score (max possible ~ 14.0 -> normalized to 100)
    raw_total = base_score + time_bonus + route_bonus
    risk_score_100 = round(min(100.0, (raw_total / 10.0) * 100.0), 1)

    # Classify Risk Level
    if risk_score_100 >= 75.0:
        risk_level = "CRITICAL"
        action = "Dispatch Emergency Services & Notify Police Immediately"
        decision_text = "CRITICAL! Call Police immediately."
    elif risk_score_100 >= 55.0:
        risk_level = "HIGH RISK"
        action = "Alert Emergency Contacts & Family"
        decision_text = "HIGH RISK! Notify parents."
    elif risk_score_100 >= 35.0:
        risk_level = "MONITOR"
        action = "Monitor Location & Send Check-in Prompt"
        decision_text = "MONITOR. User is moving fast or there is background noise."
    else:
        risk_level = "SAFE"
        action = "No action required"
        decision_text = "SAFE. Everything is normal."

    return {
        "risk_score": risk_score_100,
        "risk_level": risk_level,
        "decision_text": decision_text,
        "action_recommended": action,
        "metrics": {
            "audio_level": audio,
            "motion_speed": motion,
            "time_of_day": time_of_day,
            "is_off_route": is_off_route,
            "location_name": location_name,
            "distance_off_route_m": distance_off_route_m,
            "struggle_detected": False,
            "transcript_threat": audio_transcript_threat,
        }
    }


def generate_ai_summary(
    user_id: str,
    risk_data: Dict[str, Any],
) -> str:
    """
    Generates a clear human-readable narrative incident summary for police/parents.
    Simulates LLM / Gemini output for hackathon demonstration.
    """
    metrics = risk_data.get("metrics", {})
    risk_level = risk_data.get("risk_level", "UNKNOWN")
    risk_score = risk_data.get("risk_score", 0.0)
    location = metrics.get("location_name", "Unknown Location")
    time_val = metrics.get("time_of_day")
    time_str = f"{time_val}:00" if time_val is not None else "Unknown Time"
    is_off_route = metrics.get("is_off_route", False)

    summary_parts = [f"User {user_id} detected in {risk_level} state (Risk Score: {risk_score}/100) near {location}."]

    if is_off_route:
        summary_parts.append(f"User deviated off-route at {time_str}.")

    if metrics.get("audio_level", 0) >= 7:
        summary_parts.append(f"Loud distress/ambient audio recorded ({metrics.get('audio_level')}/10).")

    if metrics.get("motion_speed", 0) >= 7:
        summary_parts.append(f"Rapid movement/running detected ({metrics.get('motion_speed')}/10).")

    if risk_level in ["CRITICAL", "HIGH RISK"]:
        summary_parts.append("Immediate attention and verification required.")

    return " ".join(summary_parts)


class RiskTracker:
    """
    Temporal smoothing for risk scores using a moving average window.
    Reduces false positives from momentary sensor spikes.
    
    Day 4: Moving average over last N readings.
    """
    def __init__(self, window: int = 5):
        self.window = window
        self.history: list[float] = []

    def update(self, score: float) -> float:
        self.history.append(score)
        if len(self.history) > self.window:
            self.history.pop(0)
        return sum(self.history) / len(self.history)

    def get_trend(self) -> str:
        if len(self.history) < 3:
            return "stable"
        recent = self.history[-3:]
        if all(recent[i] < recent[i+1] for i in range(len(recent)-1)):
            return "rising"
        if all(recent[i] > recent[i+1] for i in range(len(recent)-1)):
            return "falling"
        return "stable"

    def get_confidence(self) -> float:
        """Confidence based on consistency of recent readings."""
        if len(self.history) < 2:
            return 0.3
        variance = sum((x - sum(self.history)/len(self.history))**2 for x in self.history) / len(self.history)
        return max(0.0, min(1.0, 1.0 - (variance / 100.0)))


def calculate_risk_with_confidence(
    audio_level: int,
    motion_speed: int,
    time_of_day: Optional[int] = None,
    is_off_route: bool = False,
    distance_off_route_m: Optional[float] = None,
    previous_motion: Optional[int] = None,
    audio_available: bool = True,
    motion_available: bool = True,
    gps_available: bool = True,
) -> Dict[str, Any]:
    """
    Enhanced risk calculation with per-signal confidence thresholds.
    
    Day 4: Each signal contributes to confidence. Missing sensors reduce confidence
    and increase weight of available signals.
    
    Returns dict with risk_score, risk_level, confidence, signals_used.
    """
    audio = max(1, min(10, audio_level)) if audio_available else 0
    motion = max(1, min(10, motion_speed)) if motion_available else 0
    
    # Count available signals for confidence
    signals_available = sum([audio_available, motion_available, gps_available])
    base_confidence = signals_available / 3.0
    
    # Day 2: derive off-route status from GPS distance (500m rule)
    if distance_off_route_m is not None and gps_available:
        is_off_route = distance_off_route_m > OFF_ROUTE_THRESHOLD_M
    elif not gps_available:
        is_off_route = False
    
    # Day 3: Struggle detection override - instant CRITICAL
    if previous_motion is not None and detect_struggle(previous_motion, motion):
        return {
            "risk_score": 100.0,
            "risk_level": "CRITICAL",
            "confidence": 0.95,
            "decision_text": "CRITICAL! Call Police immediately. Sudden anomaly detected (possible fall/struggle).",
            "action_recommended": "Dispatch Emergency Services & Notify Police Immediately",
            "signals_used": {"audio": audio_available, "motion": motion_available, "gps": gps_available},
            "metrics": {
                "audio_level": audio,
                "motion_speed": motion,
                "time_of_day": time_of_day,
                "is_off_route": is_off_route,
                "distance_off_route_m": distance_off_route_m,
                "struggle_detected": True,
            },
        }

    # Base weighted score out of 10
    audio_weight = 0.6 if audio_available else 0.0
    motion_weight = 0.4 if motion_available else 0.0
    
    # Redistribute weights if sensors missing
    total_weight = audio_weight + motion_weight
    if total_weight > 0:
        audio_weight = audio_weight / total_weight
        motion_weight = motion_weight / total_weight
    
    base_score = (audio * audio_weight) + (motion * motion_weight) if total_weight > 0 else 5.0

    # Multipliers & bonuses
    time_bonus = 0.0
    if time_of_day is not None:
        if 2 <= time_of_day <= 6:
            time_bonus = 2.0
        elif time_of_day >= 22 or time_of_day < 2:
            time_bonus = 1.0

    route_bonus = 3.0 if is_off_route else 0.0

    raw_total = base_score + time_bonus + route_bonus
    risk_score_100 = round(min(100.0, (raw_total / 10.0) * 100.0), 1)

    # Confidence: base * consistency (will be updated by RiskTracker)
    confidence = base_confidence

    # Classify Risk Level
    if risk_score_100 >= 75.0:
        risk_level = "CRITICAL"
        action = "Dispatch Emergency Services & Notify Police Immediately"
        decision_text = "CRITICAL! Call Police immediately."
    elif risk_score_100 >= 55.0:
        risk_level = "HIGH RISK"
        action = "Alert Emergency Contacts & Family"
        decision_text = "HIGH RISK! Notify parents."
    elif risk_score_100 >= 35.0:
        risk_level = "MONITOR"
        action = "Monitor Location & Send Check-in Prompt"
        decision_text = "MONITOR. User is moving fast or there is background noise."
    else:
        risk_level = "SAFE"
        action = "No action required"
        decision_text = "SAFE. Everything is normal."

    return {
        "risk_score": risk_score_100,
        "risk_level": risk_level,
        "confidence": confidence,
        "decision_text": decision_text,
        "action_recommended": action,
        "signals_used": {"audio": audio_available, "motion": motion_available, "gps": gps_available},
        "metrics": {
            "audio_level": audio,
            "motion_speed": motion,
            "time_of_day": time_of_day,
            "is_off_route": is_off_route,
            "distance_off_route_m": distance_off_route_m,
            "struggle_detected": False,
        }
    }


def get_language_for_location(lat: float, lng: float) -> str:
    """
    Determine language for AI summary based on geographic location.
    Day 4: Multi-language support for Indian regions.
    """
    # India bounding box (approximate)
    if 6.0 <= lat <= 38.0 and 68.0 <= lng <= 98.0:
        # Major language regions
        if 26.0 <= lat <= 31.0 and 72.0 <= lng <= 80.0:  # North India (Hindi belt)
            return "Hindi"
        elif 12.0 <= lat <= 18.0 and 76.0 <= lng <= 82.0:  # Karnataka
            return "Kannada"
        elif 10.0 <= lat <= 14.0 and 76.0 <= lng <= 80.0:  # Tamil Nadu
            return "Tamil"
        elif 16.0 <= lat <= 20.0 and 72.0 <= lng <= 77.0:  # Maharashtra
            return "Marathi"
        elif 22.0 <= lat <= 25.0 and 86.0 <= lng <= 89.0:  # West Bengal
            return "Bengali"
        elif 16.0 <= lat <= 19.0 and 78.0 <= lng <= 82.0:  # Telangana/AP
            return "Telugu"
        return "Hindi"  # Default for India
    return "English"


def generate_ai_summary(
    user_id: str,
    risk_data: Dict[str, Any],
    lat: Optional[float] = None,
    lng: Optional[float] = None,
) -> str:
    """
    Generates a clear human-readable narrative incident summary for police/parents.
    Day 4: Now supports multi-language summaries based on location.
    """
    metrics = risk_data.get("metrics", {})
    risk_level = risk_data.get("risk_level", "UNKNOWN")
    risk_score = risk_data.get("risk_score", 0.0)
    location = metrics.get("location_name", "Unknown Location")
    time_val = metrics.get("time_of_day")
    time_str = f"{time_val}:00" if time_val is not None else "Unknown Time"
    is_off_route = metrics.get("is_off_route", False)
    
    # Determine language from location
    language = "English"
    if lat is not None and lng is not None:
        language = get_language_for_location(lat, lng)

    summary_parts = [f"User {user_id} detected in {risk_level} state (Risk Score: {risk_score}/100) near {location}."]

    if is_off_route:
        summary_parts.append(f"User deviated off-route at {time_str}.")

    if metrics.get("audio_level", 0) >= 7:
        summary_parts.append(f"Loud distress/ambient audio recorded ({metrics.get('audio_level')}/10).")

    if metrics.get("motion_speed", 0) >= 7:
        summary_parts.append(f"Rapid movement/running detected ({metrics.get('motion_speed')}/10).")

    if risk_level in ["CRITICAL", "HIGH RISK"]:
        if language == "Hindi":
            summary_parts.append("तत्काल ध्यान और सत्यापन आवश्यक।")
        elif language == "Kannada":
            summary_parts.append("ತಕ್ಷಣ ಗಮನ ಮತ್ತು ಪರಿಶೀಲನೆ ಅಗತ್ಯ।")
        elif language == "Tamil":
            summary_parts.append("உடனடி கவனம் மற்றும் சரிபார்க்கல் அவசியம்।")
        elif language == "Marathi":
            summary_parts.append("तात्काळ लक्ष आणि पडताळणी आवश्यक।")
        elif language == "Bengali":
            summary_parts.append("তাত্ক্ষণিক মনোযোগ এবং যাচাই প্রয়োজন।")
        elif language == "Telugu":
            summary_parts.append("తత్కాల శ్రద్ధ మరియు ధృవీకరణ అవసరం।")
        else:
            summary_parts.append("Immediate attention and verification required.")

    return " ".join(summary_parts)


# --- AUTOMATED SIMULATION & TESTING ---
if __name__ == "__main__":
    print("=" * 65)
    print("PROACTIVE GUARD - AI RISK ENGINE (PERSON 5)")
    print("=" * 65)

    scenarios = [
        {"name": "Quiet Library", "audio": 1, "motion": 1, "time": 14, "off_route": False, "loc": "Central Library", "dist": None, "lat": 28.6139, "lng": 77.2090},
        {"name": "Jogging in Park", "audio": 4, "motion": 7, "time": 16, "off_route": False, "loc": "City Park", "dist": None, "lat": 28.6139, "lng": 77.2090},
        {"name": "Off-Route Night Walk", "audio": 6, "motion": 4, "time": 23, "off_route": True, "loc": "Main Street Alley", "dist": None, "lat": 28.6139, "lng": 77.2090},
        {"name": "Screaming & Running at 3 AM", "audio": 10, "motion": 9, "time": 3, "off_route": True, "loc": "Outer Ring Road", "dist": None, "lat": 28.6139, "lng": 77.2090},
        {"name": "Dragged Into Car (Silent)", "audio": 2, "motion": 3, "time": 2, "off_route": False, "loc": "Unknown Route", "dist": 1200.0, "lat": 28.6139, "lng": 77.2090},
        {"name": "Bangalore - Kannada Region", "audio": 8, "motion": 6, "time": 22, "off_route": True, "loc": "Koramangala", "dist": 800.0, "lat": 12.9716, "lng": 77.5946},
        {"name": "Chennai - Tamil Region", "audio": 9, "motion": 5, "time": 1, "off_route": False, "loc": "T Nagar", "dist": None, "lat": 13.0827, "lng": 80.2707},
    ]

    tracker = RiskTracker(window=5)
    
    for idx, s in enumerate(scenarios, 1):
        print(f"\nScenario {idx}: {s['name']}")
        decision = calculate_risk(s["audio"], s["motion"], s["time"], s["off_route"], s["dist"])
        eval_data = evaluate_risk(s["audio"], s["motion"], s["time"], s["off_route"], s["loc"], s["dist"])
        
        # Test temporal smoothing
        smoothed = tracker.update(eval_data['risk_score'])
        trend = tracker.get_trend()
        
        ai_summary = generate_ai_summary("U-047", eval_data, s.get("lat"), s.get("lng"))

        print(f"  Inputs      : Audio={s['audio']}/10 | Motion={s['motion']}/10 | Time={s['time']}:00 | Off-Route={s['off_route']} | Dist={s['dist']}")
        print(f"  Decision    : {decision}")
        print(f"  Risk Score  : {eval_data['risk_score']}/100 [{eval_data['risk_level']}]")
        print(f"  Smoothed    : {smoothed}/100 (trend: {trend})")
        print(f"  Action      : {eval_data['action_recommended']}")
        print(f"  AI Summary  : \"{ai_summary}\"")

    print("\n" + "=" * 65)
    print("TESTING CONFIDENCE & MISSING SENSORS")
    print("=" * 65)
    
    # Test missing sensors
    test_cases = [
        {"name": "All sensors", "audio": 8, "motion": 7, "audio_avail": True, "motion_avail": True, "gps_avail": True},
        {"name": "No audio", "audio": 0, "motion": 7, "audio_avail": False, "motion_avail": True, "gps_avail": True},
        {"name": "No motion", "audio": 8, "motion": 0, "audio_avail": True, "motion_avail": False, "gps_avail": True},
        {"name": "No GPS", "audio": 8, "motion": 7, "audio_avail": True, "motion_avail": True, "gps_avail": False},
        {"name": "Only motion", "audio": 0, "motion": 9, "audio_avail": False, "motion_avail": True, "gps_avail": False},
    ]
    
    for tc in test_cases:
        result = calculate_risk_with_confidence(
            tc["audio"], tc["motion"], 23, False, None, None,
            tc["audio_avail"], tc["motion_avail"], tc["gps_avail"]
        )
        print(f"\n{tc['name']}: Score={result['risk_score']}, Level={result['risk_level']}, Confidence={result['confidence']:.2f}")

    print("\n" + "=" * 65)
    print("AI RISK ENGINE TEST SIMULATION COMPLETED SUCCESSFULLY")
    print("=" * 65)
