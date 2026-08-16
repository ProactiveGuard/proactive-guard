# Proactive Guard - GPS / Geography Engine
# Person 5: The "AI" & Logic Thinker (Day 2)

"""
Geography math for Proactive Guard.

Uses the Haversine formula to compute the great-circle distance between two
GPS coordinates in METERS (the Earth is round, so simple subtraction is wrong).

Main public functions:
- calculate_distance(lat1, lon1, lat2, lon2) -> meters
- distance_from_route(lat, lon, route) -> minimum meters from the planned route
- is_off_route(lat, lon, route, threshold_m) -> (bool, meters)
"""

import math
from typing import List, Optional, Tuple

# Day 2 Playbook rule: more than 500 meters from the expected route = off route
OFF_ROUTE_THRESHOLD_M = 500.0

EARTH_RADIUS_M = 6371000.0


def calculate_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
    """
    Haversine formula: distance in METERS between two GPS points.
    """
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    delta_phi = math.radians(lat2 - lat1)
    delta_lambda = math.radians(lon2 - lon1)

    a = (
        math.sin(delta_phi / 2.0) ** 2
        + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2.0) ** 2
    )
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1.0 - a))

    return EARTH_RADIUS_M * c


def distance_from_route(
    lat: float,
    lon: float,
    route: List[Tuple[float, float]],
) -> float:
    """
    Minimum distance (meters) from the user's current position to the nearest
    point along the planned route.
    """
    if not route:
        return 0.0

    return min(
        calculate_distance(lat, lon, r_lat, r_lon) for r_lat, r_lon in route
    )


def is_off_route(
    lat: float,
    lon: float,
    route: Optional[List[Tuple[float, float]]] = None,
    threshold_m: float = OFF_ROUTE_THRESHOLD_M,
) -> Tuple[bool, float]:
    """
    Returns (off_route: bool, distance_m: float).

    If no route is provided, the user is considered ON route (0 meters off).
    """
    if not route:
        return False, 0.0

    distance_m = distance_from_route(lat, lon, route)
    return distance_m > threshold_m, distance_m


# --- AUTOMATED SIMULATION & TESTING ---
if __name__ == "__main__":
    print("=" * 65)
    print("PROACTIVE GUARD - GPS/GEO ENGINE (PERSON 5)")
    print("=" * 65)

    test_cases = [
        ("Same point", 28.6139, 77.2090, 28.6139, 77.2090),
        ("~466m apart", 19.123, 72.891, 19.125, 72.895),
        ("~1km apart", 28.6000, 77.2000, 28.6139, 77.2090),
    ]

    for name, la1, lo1, la2, lo2 in test_cases:
        dist = calculate_distance(la1, lo1, la2, lo2)
        print(f"{name:12s}: {dist:.1f} meters")

    delhi_route = [(28.6110, 77.2050), (28.6125, 77.2075), (28.6139, 77.2090)]
    user_on_route = is_off_route(28.6120, 77.2065, delhi_route)
    user_strayed = is_off_route(28.6500, 77.2400, delhi_route)

    print(f"\nOn route    -> off_route={user_on_route[0]}, distance={user_on_route[1]:.1f}m")
    print(f"Strayed     -> off_route={user_strayed[0]}, distance={user_strayed[1]:.1f}m")
    print(f"\nOff-route threshold: {OFF_ROUTE_THRESHOLD_M} meters (Day 2 rule: +3 danger score)")

    print("\n" + "=" * 65)
    print("GPS/GEO ENGINE TEST SIMULATION COMPLETED SUCCESSFULLY")
    print("=" * 65)
