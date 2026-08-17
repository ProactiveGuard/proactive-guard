import pytest
from httpx import AsyncClient
from app.main import app

@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as c:
        yield c

@pytest.mark.asyncio
async def test_ping(client):
    res = await client.get("/ping")
    assert res.status_code == 200
    assert res.json()["status"] == "I am ok"

@pytest.mark.asyncio
async def test_journey_lifecycle(client):
    res = await client.post("/api/v1/journey/start", json={"user_id": "U-1"})
    assert res.status_code == 200
    jid = res.json()["journey_id"]
    
    res = await client.post("/api/v1/journey/stop", params={"journey_id": jid})
    assert res.status_code == 200
