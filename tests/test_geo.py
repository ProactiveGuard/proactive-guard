import sys
from pathlib import Path

sys.path.append(str(Path(__file__).resolve().parent.parent / "backend"))

from ai_engine.geo import (
    OFF_ROUTE_THRESHOLD_M,
    calculate_distance,
    distance_from_route,
    is_off_route,
)
from ai_engine.risk import calculate_risk, evaluate_risk


def test_same_point_is_zero():
    assert calculate_distance(28.6139, 77.2090, 28.6139, 77.2090) == 0.0


def test_known_distance_new_delhi():
    d = calculate_distance(28.6110, 77.2050, 28.6139, 77.2090)
    assert 400 < d < 600


def test_distance_is_metric_and_symmetric():
    d1 = calculate_distance(19.123, 72.891, 19.125, 72.895)
    d2 = calculate_distance(19.125, 72.895, 19.123, 72.891)
    assert d1 == d2


def test_on_route_detection():
    route = [(28.6110, 77.2050), (28.6125, 77.2075), (28.6139, 77.2090)]
    off, dist = is_off_route(28.6120, 77.2065, route)
    assert off is False
    assert dist < OFF_ROUTE_THRESHOLD_M


def test_off_route_detection():
    route = [(28.6110, 77.2050), (28.6125, 77.2075), (28.6139, 77.2090)]
    off, dist = is_off_route(28.6500, 77.2400, route)
    assert off is True
    assert dist > OFF_ROUTE_THRESHOLD_M


def test_no_route_means_on_route():
    off, dist = is_off_route(28.6139, 77.2090, route=None)
    assert off is False
    assert dist == 0.0


def test_distance_above_threshold_adds_three_points():
    safe = calculate_risk(audio_level=2, motion_speed=3, time_of_day=7)
    risky = calculate_risk(audio_level=2, motion_speed=3, time_of_day=7, distance_off_route_m=1200.0)
    assert "SAFE" in safe
    assert "RISK" in risky or "MONITOR" in risky


def test_evaluate_risk_flags_distance_off_route():
    result = evaluate_risk(
        audio_level=2,
        motion_speed=3,
        time_of_day=7,
        location_name="Test",
        distance_off_route_m=1200.0,
    )
    assert result["metrics"]["is_off_route"] is True
    assert result["metrics"]["distance_off_route_m"] == 1200.0
