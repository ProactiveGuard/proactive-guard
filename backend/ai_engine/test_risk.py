import sys
from pathlib import Path
sys.path.append(str(Path(__file__).resolve().parent.parent))

from ai_engine.risk import (
    detect_struggle,
    calculate_risk,
    evaluate_risk,
    generate_ai_summary,
    RiskTracker,
    calculate_risk_with_confidence,
    get_language_for_location,
)


def test_detect_struggle_spike():
    assert detect_struggle(2, 9) is True


def test_detect_struggle_no_spike():
    assert detect_struggle(5, 7) is False


def test_detect_struggle_boundary():
    assert detect_struggle(2, 8) is True
    assert detect_struggle(2, 7) is False


def test_calculate_risk_safe():
    result = calculate_risk(1, 1, time_of_day=14)
    assert "SAFE" in result


def test_calculate_risk_critical():
    result = calculate_risk(10, 10, time_of_day=3, is_off_route=True)
    assert "CRITICAL" in result


def test_calculate_risk_high_risk():
    result = calculate_risk(7, 5, time_of_day=23, is_off_route=False)
    assert "HIGH RISK" in result


def test_calculate_risk_night_bonus():
    day = evaluate_risk(5, 5, time_of_day=14)
    night = evaluate_risk(5, 5, time_of_day=3)
    assert night["risk_score"] > day["risk_score"]


def test_calculate_risk_off_route_bonus():
    on_route = evaluate_risk(5, 5, is_off_route=False)
    off_route = evaluate_risk(5, 5, is_off_route=True)
    assert off_route["risk_score"] > on_route["risk_score"]


def test_evaluate_risk_safe():
    result = evaluate_risk(1, 1, time_of_day=14, location_name="Library")
    assert result["risk_level"] == "SAFE"
    assert result["risk_score"] < 35.0


def test_evaluate_risk_critical():
    result = evaluate_risk(10, 10, time_of_day=3, is_off_route=True, location_name="Dark Alley")
    assert result["risk_level"] == "CRITICAL"
    assert result["risk_score"] >= 75.0


def test_evaluate_risk_struggle_override():
    result = evaluate_risk(2, 9, previous_motion=1, audio_transcript_threat=False)
    assert result["risk_level"] == "CRITICAL"
    assert result["risk_score"] == 100.0
    assert result["metrics"]["struggle_detected"] is True


def test_evaluate_risk_transcript_threat_override():
    result = evaluate_risk(3, 2, audio_transcript_threat=True)
    assert result["risk_level"] == "CRITICAL"
    assert result["risk_score"] == 95.0
    assert result["metrics"]["transcript_threat"] is True


def test_evaluate_risk_clamp_values():
    result = evaluate_risk(100, -50, time_of_day=14)
    assert 1 <= result["metrics"]["audio_level"] <= 10
    assert 1 <= result["metrics"]["motion_speed"] <= 10


def test_generate_ai_summary():
    risk_data = {
        "risk_level": "CRITICAL",
        "risk_score": 92.0,
        "metrics": {
            "location_name": "Park Road",
            "time_of_day": 23,
            "is_off_route": True,
            "audio_level": 9,
            "motion_speed": 8,
        },
    }
    summary = generate_ai_summary("U-TEST", risk_data, lat=28.6139, lng=77.209)
    assert "U-TEST" in summary
    assert "CRITICAL" in summary
    assert "Park Road" in summary


def test_generate_ai_summary_english():
    risk_data = {
        "risk_level": "HIGH RISK",
        "risk_score": 65.0,
        "metrics": {"location_name": "Main St", "time_of_day": 14, "is_off_route": False, "audio_level": 3, "motion_speed": 3},
    }
    summary = generate_ai_summary("U-EN", risk_data, lat=40.7128, lng=-74.006)
    assert "U-EN" in summary
    assert "Immediate attention" in summary


def test_risk_tracker_smoothing():
    tracker = RiskTracker(window=3)
    s1 = tracker.update(80.0)
    s2 = tracker.update(90.0)
    s3 = tracker.update(100.0)
    assert s3 == (80 + 90 + 100) / 3
    assert tracker.get_trend() == "rising"


def test_risk_tracker_trend_falling():
    tracker = RiskTracker(window=5)
    tracker.update(100.0)
    tracker.update(80.0)
    tracker.update(60.0)
    assert tracker.get_trend() == "falling"


def test_risk_tracker_trend_stable():
    tracker = RiskTracker(window=5)
    tracker.update(50.0)
    tracker.update(50.0)
    tracker.update(50.0)
    assert tracker.get_trend() == "stable"


def test_risk_tracker_window_limit():
    tracker = RiskTracker(window=3)
    for i in range(10):
        tracker.update(float(i * 10))
    assert len(tracker.history) == 3


def test_risk_tracker_confidence():
    tracker = RiskTracker(window=5)
    tracker.update(50.0)
    tracker.update(50.0)
    tracker.update(50.0)
    assert tracker.get_confidence() > 0.9

    tracker2 = RiskTracker(window=5)
    tracker2.update(10.0)
    tracker2.update(90.0)
    tracker2.update(50.0)
    assert tracker2.get_confidence() < 0.9


def test_confidence_all_sensors():
    result = calculate_risk_with_confidence(8, 7, 23, True, 600.0, None, True, True, True)
    assert result["confidence"] == 1.0
    assert result["signals_used"]["audio"] is True


def test_confidence_missing_sensors():
    result = calculate_risk_with_confidence(8, 7, 23, False, None, None, False, True, False)
    assert result["confidence"] < 1.0
    assert result["signals_used"]["audio"] is False
    assert result["signals_used"]["gps"] is False


def test_get_language_hindi():
    assert get_language_for_location(28.6, 77.2) == "Hindi"


def test_get_language_tamil():
    assert get_language_for_location(11.0, 79.0) == "Tamil"


def test_get_language_english():
    assert get_language_for_location(40.7, -74.0) == "English"


def test_get_language_kannada():
    assert get_language_for_location(12.97, 77.59) == "Kannada"


def test_get_language_telugu():
    assert get_language_for_location(18.5, 79.0) == "Telugu"
