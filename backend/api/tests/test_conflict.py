"""Tests for conflict resolution and caregiver dashboard endpoints."""
import pytest
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.db.base import Base
from backend.api.app.db.session import engine, SessionLocal
from backend.api.app.models.patient_caregiver import PatientCaregiver
from datetime import datetime, timezone, timedelta

from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.sync_operation import SyncOperation

@pytest.fixture(autouse=True)
def setup_db():
    db = SessionLocal()
    try:
        db.query(SyncOperation).delete()
        db.query(Memory).delete()
        db.query(GameSession).delete()
        db.query(PatientCaregiver).delete()
        db.query(Patient).delete()
        db.query(Caregiver).delete()
        db.query(User).delete()
        db.commit()
    finally:
        db.close()
    yield

@pytest.fixture
def client():
    return TestClient(app)

def test_stale_update_conflict(client):
    # Register patient
    reg = client.post("/api/v1/auth/register", json={
        "email": "conflict_patient@example.com",
        "password": "password123",
        "full_name": "Conflict Patient",
        "role": "PATIENT",
    })
    token = reg.json()["access_token"]
    patient_id = reg.json()["patient_id"]
    headers = {"Authorization": f"Bearer {token}"}

    # 1. Create memory on server
    t_create = datetime.now(timezone.utc)
    client.post("/api/v1/sync", json={
        "patient_id": patient_id,
        "items": [{
            "operation_id": "op-create-01",
            "entity_type": "Memories",
            "operation": "CREATE",
            "local_id": "mem-c-01",
            "payload": {"title": "Original Title", "description": "Original Desc"},
            "client_updated_at": t_create.isoformat(),
        }],
    }, headers=headers)

    # 2. Server gets updated at t_now + 10s
    t_server_update = t_create + timedelta(seconds=10)
    client.post("/api/v1/sync", json={
        "patient_id": patient_id,
        "items": [{
            "operation_id": "op-update-server-02",
            "entity_type": "Memories",
            "operation": "UPDATE",
            "local_id": "mem-c-01",
            "payload": {"title": "Server Updated Title", "description": "Updated by server"},
            "client_updated_at": t_server_update.isoformat(),
        }],
    }, headers=headers)

    # 3. Client attempts to send stale update with older timestamp (t_create + 2s)
    t_stale = t_create + timedelta(seconds=2)
    resp = client.post("/api/v1/sync", json={
        "patient_id": patient_id,
        "items": [{
            "operation_id": "op-update-stale-03",
            "entity_type": "Memories",
            "operation": "UPDATE",
            "local_id": "mem-c-01",
            "payload": {"title": "Stale Title", "description": "Stale Desc"},
            "client_updated_at": t_stale.isoformat(),
        }],
    }, headers=headers)

    res = resp.json()["results"][0]
    assert res["status"] == "conflict"
    assert "Server record is newer" in res["message"]
    assert res["conflict_data"]["server_title"] == "Server Updated Title"

def test_caregiver_patient_authorization_and_data(client):
    # 1. Register Patient
    p_reg = client.post("/api/v1/auth/register", json={
        "email": "p_auth@example.com",
        "password": "password123",
        "full_name": "Auth Patient",
        "role": "PATIENT",
    })
    p_token = p_reg.json()["access_token"]
    patient_id = p_reg.json()["patient_id"]

    # 2. Register Caregiver
    c_reg = client.post("/api/v1/auth/register", json={
        "email": "c_auth@example.com",
        "password": "password123",
        "full_name": "Auth Caregiver",
        "role": "CAREGIVER",
    })
    c_token = c_reg.json()["access_token"]
    caregiver_id = c_reg.json()["caregiver_id"]
    c_headers = {"Authorization": f"Bearer {c_token}"}

    # 3. Unassigned caregiver attempts to access patient -> 403
    unauth_resp = client.get(f"/api/v1/caregivers/patients/{patient_id}/summary", headers=c_headers)
    assert unauth_resp.status_code == 403

    # 4. Assign Caregiver to Patient
    db = SessionLocal()
    assignment = PatientCaregiver(patient_id=patient_id, caregiver_id=caregiver_id, can_view=True, can_edit=True)
    db.add(assignment)
    db.commit()
    db.close()

    # 5. Assigned caregiver can now access patient summary
    auth_resp = client.get(f"/api/v1/caregivers/patients/{patient_id}/summary", headers=c_headers)
    assert auth_resp.status_code == 200
    summary = auth_resp.json()
    assert summary["patient_id"] == patient_id
    assert summary["total_sessions"] == 0

    # 6. Patient logs a game session via sync
    client.post("/api/v1/sync", json={
        "patient_id": patient_id,
        "items": [{
            "operation_id": "op-gs-caregiver-test",
            "entity_type": "GameSessions",
            "operation": "CREATE",
            "local_id": "gs-caregiver-01",
            "payload": {
                "gameType": "Daily Routine Recall",
                "score": 90,
                "accuracy": 0.90,
                "mistakes": 1,
                "responseTimeMs": 1200.0,
                "difficulty": 1,
                "startedAt": datetime.now(timezone.utc).isoformat(),
                "completedAt": datetime.now(timezone.utc).isoformat(),
            },
        }],
    }, headers={"Authorization": f"Bearer {p_token}"})

    # 7. Caregiver re-checks summary and game sessions
    summary2 = client.get(f"/api/v1/caregivers/patients/{patient_id}/summary", headers=c_headers).json()
    assert summary2["total_sessions"] == 1
    assert summary2["average_accuracy"] == 0.9

    sessions = client.get(f"/api/v1/caregivers/patients/{patient_id}/game-sessions", headers=c_headers).json()
    assert len(sessions) == 1
    assert sessions[0]["game_type"] == "Daily Routine Recall"
