# Proactive Guard - LLM (Gemini) Integration
# Person 5: The "AI" & Logic Thinker (Day 2)

"""
AI summary generator using Google Gemini.

Why this matters: judges love seeing real LLMs in action. This module reads raw
sensor data (audio score, distance off route, motion) and asks Gemini to write a
clean, 2-sentence emergency summary for the police dashboard.

Graceful fallback: if no GEMINI_API_KEY is set (or the library is not installed),
generate_police_summary() returns a deterministic template so the demo never breaks.

Setup:
1. Get a free API key from https://aistudio.google.com/
2. Set GEMINI_API_KEY in backend/.env (copy from .env.example)

Uses the current `google-genai` SDK (the old `google-generativeai` package is deprecated).
"""

import os
from pathlib import Path

# Load backend/.env (GEMINI_API_KEY) so the script works standalone too.
try:
    from dotenv import load_dotenv
    load_dotenv(Path(__file__).resolve().parent.parent.parent / ".env")
except ImportError:
    pass

try:
    from google import genai
    GEMINI_AVAILABLE = True
except ImportError:
    GEMINI_AVAILABLE = False

API_KEY: str = os.getenv("GEMINI_API_KEY", "").strip()

# Configurable model; falls back gracefully if the model is unavailable.
GEMINI_MODEL: str = os.getenv("GEMINI_MODEL", "gemini-2.5-flash")

_client = None
if GEMINI_AVAILABLE and API_KEY:
    try:
        _client = genai.Client(api_key=API_KEY)
    except Exception:
        _client = None


def gemini_enabled() -> bool:
    """True when a real Gemini call can be made."""
    return _client is not None


def _fallback_summary(
    audio_score: float,
    motion_score: float,
    distance_off_route: float,
    risk_level: str,
    risk_score: float,
) -> str:
    """Deterministic template used when Gemini is not available."""
    parts = []
    if distance_off_route > 0:
        parts.append(
            f"Subject has deviated {distance_off_route:.0f} meters from the expected route."
        )
    else:
        parts.append("Subject is on the expected route.")
    if audio_score >= 7:
        parts.append(f"Severe background noise ({audio_score}/10) indicates immediate physical distress;")
    elif motion_score >= 7:
        parts.append(f"Rapid movement detected ({motion_score}/10) suggests a fall or struggle;")
    else:
        parts.append("Baseline distress indicators are elevated;")
    parts.append(
        f"risk level {risk_level} (score {risk_score}/100). Dispatch units immediately."
    )
    return " ".join(parts)


def generate_police_summary(
    audio_score: float = 0.0,
    distance_off_route: float = 0.0,
    motion_score: float = 0.0,
    risk_level: str = "MONITOR",
    risk_score: float = 0.0,
) -> str:
    """
    Generate a 2-sentence emergency summary for the police dashboard.

    Uses Gemini when configured; otherwise returns a deterministic template.

    Parameters:
    - audio_score (float): 0-10 ambient audio danger score
    - distance_off_route (float): meters off the expected route
    - motion_score (float): 0-10 motion danger score
    - risk_level (str): SAFE | MONITOR | HIGH RISK | CRITICAL
    - risk_score (float): 0-100 composite risk score
    """
    if _client is not None:
        try:
            prompt = f"""
You are an emergency dispatcher AI.
A user's phone just triggered an alert.
The audio danger score is {audio_score}/10.
The motion danger score is {motion_score}/10.
They are {distance_off_route:.0f} meters off their expected route.
The computed risk level is {risk_level} with a risk score of {risk_score}/100.
Write a strict, 2-sentence emergency summary for the police dashboard.
"""
            chat = _client.chats.create(model=GEMINI_MODEL)
            response = chat.send_message(prompt)
            text = response.text.strip()
            if text:
                return text
        except Exception:
            # Fall back to the template if the API call fails (offline demo, etc.)
            pass

    return _fallback_summary(audio_score, motion_score, distance_off_route, risk_level, risk_score)


# --- AUTOMATED SIMULATION & TESTING ---
if __name__ == "__main__":
    print("=" * 65)
    print("PROACTIVE GUARD - LLM SUMMARY GENERATOR (PERSON 5)")
    print("=" * 65)
    print(f"Gemini configured: {gemini_enabled()}")
    print()

    summary = generate_police_summary(
        audio_score=9,
        distance_off_route=850,
        motion_score=8,
        risk_level="CRITICAL",
        risk_score=92,
    )
    print("--- AI SUMMARY GENERATOR ---")
    print(summary)

    print("\n" + "=" * 65)
    print("LLM TEST SIMULATION COMPLETED")
    print("=" * 65)
