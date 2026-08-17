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
import json
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


def generate_police_summary(
    audio_score: float = 0.0,
    distance_off_route: float = 0.0,
    motion_score: float = 0.0,
    risk_level: str = "MONITOR",
    risk_score: float = 0.0,
    language: str = "English",
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
    - language (str): Target language for summary (English, Hindi, Kannada, Tamil, Marathi, Bengali, Telugu)
    """
    if _client is not None:
        try:
            language_instruction = {
                "English": "Write in English.",
                "Hindi": "हिंदी में लिखें।",
                "Kannada": "ಕನ್ನಡದಲ್ಲಿ ಬರೆyin.",
                "Tamil": "தமிழில் எழுதுக.",
                "Marathi": "मराठीत लिहा.",
                "Bengali": "বাংলায় লিখুন।",
                "Telugu": "తెలుగులో వ్రాయండి.",
            }.get(language, "Write in English.")
            
            prompt = f"""
You are an emergency dispatcher AI.
A user's phone just triggered an alert.
The audio danger score is {audio_score}/10.
The motion danger score is {motion_score}/10.
They are {distance_off_route:.0f} meters off their expected route.
The computed risk level is {risk_level} with a risk score of {risk_score}/100.
Write a strict, 2-sentence emergency summary for the police dashboard.
{language_instruction}
"""
            chat = _client.chats.create(model=GEMINI_MODEL)
            response = chat.send_message(prompt)
            text = response.text.strip()
            if text:
                return text
        except Exception:
            pass

    return _fallback_summary(audio_score, motion_score, distance_off_route, risk_level, risk_score, language)


def _fallback_summary(
    audio_score: float,
    motion_score: float,
    distance_off_route: float,
    risk_level: str,
    risk_score: float,
    language: str = "English",
) -> str:
    """Deterministic template used when Gemini is not available. Supports multiple languages."""
    templates = {
        "English": {
            "on_route": "Subject is on the expected route.",
            "off_route": "Subject has deviated {dist:.0f} meters from the expected route.",
            "high_audio": "Severe background noise ({audio}/10) indicates immediate physical distress;",
            "high_motion": "Rapid movement detected ({motion}/10) suggests a fall or struggle;",
            "baseline": "Baseline distress indicators are elevated;",
            "risk": "Risk level {level} (score {score}/100). Dispatch units immediately.",
        },
        "Hindi": {
            "on_route": "विषय अपेक्षित मार्ग पर है।",
            "off_route": "विषय अपेक्षित मार्ग से {dist:.0f} मीटर भटक गया है।",
            "high_audio": "गंभीर पृष्ठभूमि शोर ({audio}/10) तत्काल शारीरिक संकट दर्शाता है;",
            "high_motion": "तीव्र गति का पता चला ({motion}/10) गिरने या संघर्ष का संकेत देता है;",
            "baseline": "आधारभूत संकट संकेत बढ़े हुए हैं;",
            "risk": "जोखिम स्तर {level} (स्कोर {score}/100)। इकाइयों को तुरंत भेजें।",
        },
        "Kannada": {
            "on_route": "ವಿಷಯ ಅನುಮಾನಿತ ಮಾರ್ಗದಲ್ಲಿದೆ।",
            "off_route": "ವಿಷಯ {dist:.0f} ಮೀಟರ್‌ಗಳು ದೂರastore ಅನುಮಾನಿತ ಮಾರ್ಗದಿಂದ ಬಿಟ್ಟೆಯಾಗಿದೆ।",
            "high_audio": "ತೀವ್ರ ಹಿನ್ನೆಲೆ ಶಬ್ದ ({audio}/10) ತತ್ಕಾಳ ಶಾರೀರಿಕ ವಿಪತ್ತನ್ನು ಸೂಚಿಸುತ್ತದೆ;",
            "high_motion": "ತ್ವರಿತ ಚಲನೆ ಪತ್ತೆಯಾಗಿದೆ ({motion}/10) ಸotto ಅಥವಾ ಸಂಸರಸ್ಯನ್ನು ಸೂಚಿಸುತ್ತದೆ;",
            "baseline": "ಮೂಲಭೂತ ವಿಪತ್ತಿನ ಲಕ್ಷಣಗಳು ಹೆಚ್ಚಾಗಿವೆ;",
            "risk": "ಝಪದ ಮಟ್ಟ {level} (স্কೋರ್ {score}/100)। ಒಕ್ಕೂಟಗಳನ್ನು ತಕ್ಷಣ ಕಳುಹಿಸಿ।",
        },
        "Tamil": {
            "on_route": "பொருள் انتظار मार्गத்தில் உள்ளது।",
            "off_route": "பொருள் எதிர்பார்க்கப்பட்ட வழியிலிருந்து {dist:.0f} மீட்டர்கள் விலகியுள்ளது।",
            "high_audio": "தீவிர பின்னணி முகரempuan ({audio}/10) உடனடி உடல்விபத்தைக் குறிப்பிடுகிறது;",
            "high_motion": "தீவிர அசைவு கண்டறியப்பட்டது ({motion}/10) விழுதல் அல்லது கூட்டுக்கலக்கத்தைச் சూചிக்கிறது;",
            "baseline": "அடிப்படை விபத்து குறிக்கள் அதிகரித்துள்ளன;",
            "risk": "ஆபத்து மಟ್ಟம் {level} (எண்கள் {score}/100)। அவசரமாக அலகுகளை அனுப்பவும்।",
        },
        "Marathi": {
            "on_route": "विषय अपेक्षित मार्गावर आहे।",
            "off_route": "विषय अपेक्षित मार्गापासून {dist:.0f} मीटर वेचले आहे।",
            "high_audio": "तीव्र पार्श्वभूमी ध्वनी ({audio}/10) तात्काळ शारीरिक संकट दर्शवते;",
            "high_motion": "तीव्र चाल आढळली ({motion}/10) ढकल किंवा संघर्षाचे संकेत देते;",
            "baseline": "मूलभूत संकट निर्देशक वाढलेले आहेत;",
            "risk": "जोखीम स्तर {level} (गुण {score}/100)। दल तात्काळ रवाना करा।",
        },
        "Bengali": {
            "on_route": "বিষয় প্রত্যাশিত রুটে রয়েছে।",
            "off_route": "বিষয় প্রত্যাশিত রুট থেকে {dist:.0f} মিটার দূরে চলে গেছে।",
            "high_audio": "গভীর পটভূমি শব্দ ({audio}/10) তাৎক্ষণিক শারীরিক দুর্ঘটনা নির্দেশ করে;",
            "high_motion": "তীব্র গতি সনাক্ত ({motion}/10) পতন বা সংঘর্ষের ইঙ্গিত দেয়;",
            "baseline": "মৌলিক দুর্ঘটনার সংকেতগুলি বেড়ে গেছে;",
            "risk": "ঝুঁকির স্তর {level} (স্কোর {score}/100)। অবিলম্বে ইউনিট প্রস্থান করান।",
        },
        "Telugu": {
            "on_route": "విషయం అనుమానిత మార్గంలో ఉంది।",
            "off_route": "విషయం అనుమానిత మార్గం నుండి {dist:.0f} మీటర్లు దూరంగా వెళ్లిపోయింది।",
            "high_audio": "తీవ్ర పট� neurite ({audio}/10) తత్కాల శారీరక విపత్తును సూచిస్తుంది;",
            "high_motion": "తీవ్ర చలనం కనుగొనబడింది ({motion}/10) పడుకోవడం లేదా సంగرسی సూచిస్తుంది;",
            "baseline": "మూలభూత విపత్తు సూచనలు పెసiences ఉన్నాయి;",
            "risk": "అపాయ స్థాయి {level} (స్కోర్ {score}/100)। యూనిట்களை తత్కాలते పంపండి।",
        },
    }
    
    t = templates.get(language, templates["English"])
    
    parts = []
    if distance_off_route > 0:
        parts.append(t["off_route"].format(dist=distance_off_route))
    else:
        parts.append(t["on_route"])
    if audio_score >= 7:
        parts.append(t["high_audio"].format(audio=audio_score))
    elif motion_score >= 7:
        parts.append(t["high_motion"].format(motion=motion_score))
    else:
        parts.append(t["baseline"])
    parts.append(t["risk"].format(level=risk_level, score=risk_score))
    return " ".join(parts)


def analyze_audio_transcript(transcript: str) -> dict:
    """
    Uses Gemini to analyze transcribed audio from the phone's microphone.
    Returns a JSON dict with a threat level.

    Day 3 upgrade: reads live speech-to-text output and determines whether
    the user is in danger based on keywords and conversational context.

    Parameters:
    - transcript (str): The speech-to-text output from the user's phone.

    Returns:
    - dict: {"is_threat": bool, "threat_reason": str}
    """
    if _client is not None:
        try:
            prompt = f"""
You are an AI safety analyst. Read the following audio transcript from a user's phone.
Determine if the user is in danger.
Look for keywords like "help", "stop", "leave me alone", or signs of a struggle.

Transcript: "{transcript}"

Reply ONLY with a valid JSON in this exact format:
{{"is_threat": true/false, "threat_reason": "your reasoning"}}
"""
            chat = _client.chats.create(model=GEMINI_MODEL)
            response = chat.send_message(prompt)
            raw = response.text.strip().replace("```json", "").replace("```", "")
            return json.loads(raw)
        except Exception:
            return {"is_threat": False, "threat_reason": "AI Error - could not analyze transcript"}
    else:
        return _fallback_transcript_analysis(transcript)


def _fallback_transcript_analysis(transcript: str) -> dict:
    """
    Deterministic keyword-based fallback when Gemini is not available.
    Scans for common distress keywords.
    """
    danger_keywords = [
        "help", "stop", "leave me alone", "go away", "don't touch me",
        "back off", "no", "please stop", "let me go", "calling police",
        "emergency", "rape", "murder", "kill", "stab", "weapon",
        "help me", "save me", "someone", "attack",
    ]
    lower = transcript.lower()
    for keyword in danger_keywords:
        if keyword in lower:
            return {"is_threat": True, "threat_reason": f"Distress keyword detected: '{keyword}'"}
    return {"is_threat": False, "threat_reason": "No distress indicators found in transcript"}


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

    print("\n--- NLP THREAT ANALYSIS (Day 3) ---")
    safe = analyze_audio_transcript("Hey, do you want to grab coffee later?")
    print(f"Safe transcript:   {safe}")

    threat = analyze_audio_transcript("Hey man, back off! I don't know you!")
    print(f"Threat transcript: {threat}")

    print("\n" + "=" * 65)
    print("LLM TEST SIMULATION COMPLETED")
    print("=" * 65)
