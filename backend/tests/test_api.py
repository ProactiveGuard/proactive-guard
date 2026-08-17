import pytest
import pytest_asyncio
from httpx import AsyncClient, ASGITransport
from app.main import app


@pytest_asyncio.fixture
async def client():
    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as c:
        yield c


@pytest.mark.asyncio
async def test_ping(client):
    res = await client.get("/ping")
    assert res.status_code == 200
    assert res.json()["status"] == "I am ok"


@pytest.mark.asyncio
async def test_root(client):
    res = await client.get("/")
    assert res.status_code == 200
    assert "Proactive Guard" in res.json()["message"]


@pytest.mark.asyncio
async def test_health_ai(client):
    res = await client.get("/api/v1/health/ai")
    assert res.status_code == 200
    data = res.json()
    assert "gemini_configured" in data
    assert "model" in data
    assert "risk_engine" in data


@pytest.mark.asyncio
async def test_ai_metrics(client):
    res = await client.get("/api/v1/metrics/ai")
    assert res.status_code == 200
    data = res.json()
    assert "total_predictions" in data
    assert "false_positive_rate" in data
    assert "avg_latency_ms" in data


@pytest.mark.asyncio
async def test_auth_register(client):
    res = await client.post("/api/v1/auth/register", json={"username": "test1", "password": "pass1"})
    assert res.status_code == 200
    assert "registered" in res.json()["message"].lower()


@pytest.mark.asyncio
async def test_auth_login(client):
    res = await client.post("/api/v1/auth/login", json={"username": "test1", "password": "pass1"})
    assert res.status_code == 200
    data = res.json()
    assert "access_token" in data
    assert data["token_type"] == "bearer"


@pytest.mark.asyncio
async def test_telemetry_safe(client):
    res = await client.post("/api/v1/telemetry", json={
        "user_id": "U-TEST-SAFE",
        "latitude": 28.6139,
        "longitude": 77.209,
        "motion_score": 1,
        "audio_score": 1,
        "distance_off_route_m": 0,
    })
    assert res.status_code == 200
    data = res.json()
    assert data["severity"] in ["SAFE", "MONITOR"]
    assert "incident_id" in data
    assert "summary" in data


@pytest.mark.asyncio
async def test_telemetry_critical(client):
    res = await client.post("/api/v1/telemetry", json={
        "user_id": "U-TEST-CRIT",
        "latitude": 28.65,
        "longitude": 77.24,
        "motion_score": 10,
        "audio_score": 10,
        "distance_off_route_m": 800,
    })
    assert res.status_code == 200
    data = res.json()
    assert data["severity"] == "CRITICAL"
    assert data["risk_score"] >= 75


@pytest.mark.asyncio
async def test_incidents(client):
    res = await client.get("/incidents")
    assert res.status_code == 200
    assert isinstance(res.json(), list)


@pytest.mark.asyncio
async def test_journey_start_and_stop(client):
    res = await client.post("/api/v1/journey/start", json={"user_id": "U-JOURNEY-TEST"})
    assert res.status_code == 200
    data = res.json()
    assert data["status"] == "active"
    jid = data["journey_id"]

    res = await client.post(f"/api/v1/journey/stop?journey_id={jid}")
    assert res.status_code == 200
    assert "safely concluded" in res.json()["message"]


@pytest.mark.asyncio
async def test_resolve_incident(client):
    res = await client.delete("/api/v1/incidents/INC-FAKE-TEST")
    assert res.status_code == 200
    assert "resolved" in res.json()["message"].lower()


@pytest.mark.asyncio
async def test_assign_responder(client):
    res = await client.patch(
        "/api/v1/incidents/INC-FAKE-TEST/assign",
        json={"responder": "Officer Singh"},
    )
    assert res.status_code == 200
    assert "Officer Singh" in res.json()["message"]
