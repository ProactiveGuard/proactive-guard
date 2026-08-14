# Proactive Guard - AI Risk Engine
# Person 5: The "AI" & Logic Thinker

"""
Risk calculation engine and AI summary generator for Proactive Guard.

This module evaluates sensor inputs (audio level, motion speed, time of day, route status)
to calculate a risk score (0-100) and determine the safety level.
It also generates human-readable incident summaries for emergency dashboards.
"""

from typing import Dict, Any, Optional


def calculate_risk(
    audio_level: int,
    motion_speed: int,
    time_of_day: Optional[int] = None,
    is_off_route: bool = False
) -> str:
    """
    Beginner-friendly risk calculation function (Day 1 Playbook baseline).

    Parameters:
    - audio_level (int): 1 to 10 scale (1 = Silent, 10 = Screaming/Loud noise)
    - motion_speed (int): 1 to 10 scale (1 = Still, 10 = Running/Falling)
    - time_of_day (int, optional): Hour in 24-hour format (0-23). 2 AM - 6 AM adds sensitivity.
    - is_off_route (bool, optional): True if user deviated from planned route.

    Returns:
    - str: Risk assessment decision string.
    """
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

    # Step 3: Off-route bonus
    if is_off_route:
        total_score += 1.5

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
    location_name: str = "Unknown Location"
) -> Dict[str, Any]:
    """
    Advanced risk evaluation returning detailed metrics, score out of 100, and recommended actions.

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

    # Base weighted score out of 10
    base_score = (audio * 0.6) + (motion * 0.4)

    # Multipliers & bonuses
    time_bonus = 0.0
    if time_of_day is not None:
        if 2 <= time_of_day <= 6:
            time_bonus = 2.0  # High night risk (2 AM - 6 AM)
        elif time_of_day >= 22 or time_of_day < 2:
            time_bonus = 1.0  # Moderate night risk (10 PM - 2 AM)

    route_bonus = 2.0 if is_off_route else 0.0

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


# --- AUTOMATED SIMULATION & TESTING ---
if __name__ == "__main__":
    print("=" * 65)
    print("PROACTIVE GUARD - AI RISK ENGINE (PERSON 5)")
    print("=" * 65)

    scenarios = [
        {"name": "Quiet Library", "audio": 1, "motion": 1, "time": 14, "off_route": False, "loc": "Central Library"},
        {"name": "Jogging in Park", "audio": 4, "motion": 7, "time": 16, "off_route": False, "loc": "City Park"},
        {"name": "Off-Route Night Walk", "audio": 6, "motion": 4, "time": 23, "off_route": True, "loc": "Main Street Alley"},
        {"name": "Screaming & Running at 3 AM", "audio": 10, "motion": 9, "time": 3, "off_route": True, "loc": "Outer Ring Road"},
    ]

    for idx, s in enumerate(scenarios, 1):
        print(f"\nScenario {idx}: {s['name']}")
        decision = calculate_risk(s["audio"], s["motion"], s["time"], s["off_route"])
        eval_data = evaluate_risk(s["audio"], s["motion"], s["time"], s["off_route"], s["loc"])
        ai_summary = generate_ai_summary("U-047", eval_data)

        print(f"  Inputs      : Audio={s['audio']}/10 | Motion={s['motion']}/10 | Time={s['time']}:00 | Off-Route={s['off_route']}")
        print(f"  Decision    : {decision}")
        print(f"  Risk Score  : {eval_data['risk_score']}/100 [{eval_data['risk_level']}]")
        print(f"  Action      : {eval_data['action_recommended']}")
        print(f"  AI Summary  : \"{ai_summary}\"")

    print("\n" + "=" * 65)
    print("AI RISK ENGINE TEST SIMULATION COMPLETED SUCCESSFULLY")
    print("=" * 65)