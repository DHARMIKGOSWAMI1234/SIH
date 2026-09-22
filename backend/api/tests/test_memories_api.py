"""Tests for memories REST endpoints."""
import pytest
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.db.base import Base
from backend.api.app.db.session import engine, SessionLocal
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.memory import Memory
from backend.api.app.models.sync_operation import SyncOperation

@pytest.fixture(autouse=True)
def setup_db():
    db = SessionLocal()
    try:
        db.query(SyncOperation).delete()
        db.query(Memory).delete()
        db.query(Patient).delete()
        db.query(User).delete()
        db.commit()
    finally:
        db.close()
    yield

@pytest.fixture
def client():
    return TestClient(app)

def test_memories_crud_endpoints(client):
    # Register patient
    reg_resp = client.post("/api/v1/auth/register", json={
        "email": "mem_patient@example.com",
        "password": "password123",
        "full_name": "Memory Patient",
        "role": "PATIENT",
    })
    token = reg_resp.json()["access_token"]
    patient_id = reg_resp.json()["patient_id"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Sync create memory
    sync_resp = client.post("/api/v1/sync", json={
        "patient_id": patient_id,
        "items": [{
            "operation_id": "op-mem-01",
            "entity_type": "Memories",
            "operation": "CREATE",
            "local_id": "mem-local-101",
            "payload": {
                "title": "Bihu Fest",
                "description": "Celebrating Rongali Bihu",
                "category": "festivals",
            },
        }],
    }, headers=headers)
    assert sync_resp.status_code == 200
    server_mem_id = sync_resp.json()["results"][0]["server_id"]
    assert server_mem_id is not None

    # 2. List memories
    list_resp = client.get("/api/v1/memories", headers=headers)
    assert list_resp.status_code == 200
    memories = list_resp.json()
    assert len(memories) == 1
    assert memories[0]["title"] == "Bihu Fest"

    # 3. Get single memory
    get_resp = client.get(f"/api/v1/memories/{server_mem_id}", headers=headers)
    assert get_resp.status_code == 200
    assert get_resp.json()["id"] == server_mem_id

    # 4. Update memory
    put_resp = client.put(
        f"/api/v1/memories/{server_mem_id}",
        json={"title": "Updated Bihu Fest", "is_favorite": True},
        headers=headers,
    )
    assert put_resp.status_code == 200
    assert put_resp.json()["title"] == "Updated Bihu Fest"
    assert put_resp.json()["is_favorite"] is True

    # 5. Delete memory
    del_resp = client.delete(f"/api/v1/memories/{server_mem_id}", headers=headers)
    assert del_resp.status_code == 204

    # Confirm deleted
    get_after = client.get(f"/api/v1/memories/{server_mem_id}", headers=headers)
    assert get_after.status_code == 404
