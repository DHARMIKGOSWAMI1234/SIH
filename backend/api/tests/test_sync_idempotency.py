"""Tests for synchronization and operation-level idempotency."""
import pytest
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.db.base import Base
from backend.api.app.db.session import engine, SessionLocal
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder
from backend.api.app.models.routine import Routine
from datetime import datetime, timezone

from backend.api.app.models.sync_operation import SyncOperation
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient

@pytest.fixture(autouse=True)
def setup_db():
    db = SessionLocal()
    try:
        db.query(SyncOperation).delete()
        db.query(Memory).delete()
        db.query(GameSession).delete()
        db.query(Reminder).delete()
        db.query(Routine).delete()
        db.query(Patient).delete()
        db.query(User).delete()
        db.commit()
    finally:
        db.close()
    yield

@pytest.fixture
def client():
    return TestClient(app)

def test_sync_batch_and_idempotency(client):
    # 1. Register a patient and obtain token
    reg_resp = client.post("/api/v1/auth/register", json={
        "email": "sync_patient@example.com",
        "password": "password123",
        "full_name": "Sync Patient",
        "role": "PATIENT",
    })
    assert reg_resp.status_code == 201
    auth_data = reg_resp.json()
    token = auth_data["access_token"]
    patient_id = auth_data["patient_id"]
    headers = {"Authorization": f"Bearer {token}"}

    # 2. Prepare batch payload with distinct operation_id for each operation
    batch_payload = {
        "patient_id": patient_id,
        "items": [
            {
                "operation_id": "op-create-memory-001",
                "entity_type": "Memories",
                "operation": "CREATE",
                "local_id": "mem-local-01",
                "payload": {
                    "title": "Bihu Celebration",
                    "description": "Family celebration with folk music",
                    "category": "festivals",
                },
                "client_updated_at": datetime.now(timezone.utc).isoformat(),
            },
            {
                "operation_id": "op-create-game-002",
                "entity_type": "GameSessions",
                "operation": "CREATE",
                "local_id": "game-local-01",
                "payload": {
                    "gameType": "Memory Match",
                    "score": 120,
                    "accuracy": 0.95,
                    "mistakes": 1,
                    "responseTimeMs": 1450.0,
                    "difficulty": 1,
                    "hintCount": 0,
                    "startedAt": datetime.now(timezone.utc).isoformat(),
                    "completedAt": datetime.now(timezone.utc).isoformat(),
                },
                "client_updated_at": datetime.now(timezone.utc).isoformat(),
            },
            {
                "operation_id": "op-create-reminder-003",
                "entity_type": "Reminders",
                "operation": "CREATE",
                "local_id": "rem-local-01",
                "payload": {
                    "title": "Drink Water",
                    "reminderType": "hydration",
                    "scheduledTime": "10:00",
                    "enabled": True,
                },
                "client_updated_at": datetime.now(timezone.utc).isoformat(),
            },
            {
                "operation_id": "op-create-routine-004",
                "entity_type": "Routines",
                "operation": "CREATE",
                "local_id": "rot-local-01",
                "payload": {
                    "title": "Morning Routine",
                    "stepsJson": "[\"Step 1\", \"Step 2\"]",
                    "preferredTime": "08:00 AM",
                    "enabled": True,
                },
                "client_updated_at": datetime.now(timezone.utc).isoformat(),
            },
        ],
    }

    # 3. First sync call -> All should return "synced"
    resp1 = client.post("/api/v1/sync", json=batch_payload, headers=headers)
    assert resp1.status_code == 200
    res1_data = resp1.json()
    assert res1_data["processed_count"] == 4
    for item in res1_data["results"]:
        assert item["status"] == "synced"
        assert item["server_id"] is not None

    # Verify DB counts
    db = SessionLocal()
    assert db.query(Memory).count() == 1
    assert db.query(GameSession).count() == 1
    assert db.query(Reminder).count() == 1
    assert db.query(Routine).count() == 1
    db.close()

    # 4. IDEMPOTENCY RETRY: Send exact same batch with same operation_id
    resp2 = client.post("/api/v1/sync", json=batch_payload, headers=headers)
    assert resp2.status_code == 200
    res2_data = resp2.json()
    assert res2_data["processed_count"] == 4
    for item in res2_data["results"]:
        assert item["status"] == "already_processed"

    # Verify NO DUPLICATES were created
    db = SessionLocal()
    assert db.query(Memory).count() == 1
    assert db.query(GameSession).count() == 1
    assert db.query(Reminder).count() == 1
    assert db.query(Routine).count() == 1
    db.close()
