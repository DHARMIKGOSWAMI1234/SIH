"""Test suite for SMRITI Backend API health endpoints."""
import pytest
from httpx import AsyncClient, ASGITransport
from backend.api.app.main import app

@pytest.mark.asyncio
async def test_root_health_endpoint():
    """Verify GET /health returns 200 and {'status': 'ok'}."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

@pytest.mark.asyncio
async def test_api_v1_health_endpoint():
    """Verify GET /api/v1/health returns 200 and {'status': 'ok'}."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.get("/api/v1/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}

@pytest.mark.asyncio
async def test_cors_headers():
    """Verify CORS middleware permits allowed local origins."""
    headers = {
        "Origin": "http://localhost:8080",
        "Access-Control-Request-Method": "GET",
    }
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        response = await client.options("/health", headers=headers)
    assert response.status_code == 200
    assert response.headers.get("access-control-allow-origin") == "http://localhost:8080"
