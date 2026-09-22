"""Critical End-to-End Test: Offline Action Simulation -> Backend Sync -> Idempotency -> Caregiver Dashboard.

Verifies against the live database:
1. Patient creates activities offline.
2. Synchronizes to backend via POST /api/v1/sync.
3. Idempotent replay: sends identical operation_ids -> verified zero duplicates.
4. Caregiver dashboard retrieves real synchronized patient metrics.
5. Server authorization ensures cross-patient privacy.
6. Verifies that the real database actually contains the synchronized records.
"""
import pytest
from datetime import datetime, timezone
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.db.session import engine, SessionLocal
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.sync_operation import SyncOperation

@pytest.fixture(autouse=True)
def clean_test_data():
    # Clean up previous test runs without dropping tables
    db = SessionLocal()
    try:
        users = db.query(User).filter(User.email.in_([
            "e2e_patient@example.com",
            "e2e_caregiver@example.com",
            "intruder_caregiver@example.com",
        ])).all()
        for u in users:
            # Cascade deletes patient/caregiver, memories, game_sessions, reminders, etc.
            db.delete(u)
        db.commit()
    finally:
        db.close()
    yield

@pytest.fixture
def client():
    return TestClient(app)

def test_full_offline_to_online_sync_scenario(client):
    # 1. Register Patient
    p_reg = client.post("/api/v1/auth/register", json={
        "email": "e2e_patient@example.com",
        "password": "patient_password_123",
        "full_name": "E2E Patient",
        "role": "PATIENT",
        "anonymous_alias": "Patient E2E",
    })
    assert p_reg.status_code == 201
    p_token = p_reg.json()["access_token"]
    patient_id = p_reg.json()["patient_id"]
    p_headers = {"Authorization": f"Bearer {p_token}"}

    # 2. Register Caregiver
    c_reg = client.post("/api/v1/auth/register", json={
        "email": "e2e_caregiver@example.com",
        "password": "caregiver_password_123",
        "full_name": "E2E Caregiver",
        "role": "CAREGIVER",
    })
    assert c_reg.status_code == 201
    c_token = c_reg.json()["access_token"]
    caregiver_id = c_reg.json()["caregiver_id"]
    c_headers = {"Authorization": f"Bearer {c_token}"}

    # 3. Assign Caregiver to Patient
    db = SessionLocal()
    assignment = PatientCaregiver(patient_id=patient_id, caregiver_id=caregiver_id, can_view=True, can_edit=True)
    db.add(assignment)
    db.commit()
    db.close()

    # 4. Simulate Offline Actions queued on device:
    # - 1 Memory created
    # - 1 Memory Match game played
    # - 1 Pattern Recognition game played
    # - 1 Daily Routine Recall game played
    # - 1 Reminder created
    t_offline = datetime.now(timezone.utc).isoformat()
    batch_items = [
        {
            "operation_id": "op-e2e-mem-001",
            "entity_type": "Memories",
            "operation": "CREATE",
            "local_id": "loc-mem-001",
            "payload": {
                "title": "Bihu Harvest Celebration",
                "description": "Family gathering with traditional Pitha and Dhol music",
                "category": "festivals",
                "language": "en",
            },
            "client_updated_at": t_offline,
        },
        {
            "operation_id": "op-e2e-game-mm-002",
            "entity_type": "GameSessions",
            "operation": "CREATE",
            "local_id": "loc-gs-mm-001",
            "payload": {
                "gameType": "Memory Match",
                "score": 100,
                "accuracy": 1.0,
                "mistakes": 0,
                "responseTimeMs": 1100.0,
                "difficulty": 1,
                "startedAt": t_offline,
                "completedAt": t_offline,
            },
            "client_updated_at": t_offline,
        },
        {
            "operation_id": "op-e2e-game-pr-003",
            "entity_type": "GameSessions",
            "operation": "CREATE",
            "local_id": "loc-gs-pr-001",
            "payload": {
                "gameType": "Pattern Recognition",
                "score": 90,
                "accuracy": 0.90,
                "mistakes": 1,
                "responseTimeMs": 1400.0,
                "difficulty": 1,
                "startedAt": t_offline,
                "completedAt": t_offline,
            },
            "client_updated_at": t_offline,
        },
        {
            "operation_id": "op-e2e-game-rr-004",
            "entity_type": "GameSessions",
            "operation": "CREATE",
            "local_id": "loc-gs-rr-001",
            "payload": {
                "gameType": "Daily Routine Recall",
                "score": 95,
                "accuracy": 0.95,
                "mistakes": 1,
                "responseTimeMs": 1250.0,
                "difficulty": 1,
                "startedAt": t_offline,
                "completedAt": t_offline,
            },
            "client_updated_at": t_offline,
        },
        {
            "operation_id": "op-e2e-rem-005",
            "entity_type": "Reminders",
            "operation": "CREATE",
            "local_id": "loc-rem-001",
            "payload": {
                "title": "Morning Tea & Hydration",
                "reminderType": "hydration",
                "scheduledTime": "08:30",
                "enabled": True,
            },
            "client_updated_at": t_offline,
        },
    ]

    # 5. Network available: Client executes batch sync
    sync_resp1 = client.post("/api/v1/sync", json={
        "patient_id": patient_id,
        "items": batch_items,
    }, headers=p_headers)

    assert sync_resp1.status_code == 200
    sync_data1 = sync_resp1.json()
    assert sync_data1["processed_count"] == 5

    # Confirm each operation has status "synced" with server_id
    server_ids = {}
    for res in sync_data1["results"]:
        assert res["status"] == "synced"
        assert res["server_id"] is not None
        server_ids[res["operation_id"]] = res["server_id"]

    # 6. Verify Database contains exactly 1 of each entity
    db = SessionLocal()
    assert db.query(Memory).filter(Memory.patient_id == patient_id).count() == 1
    assert db.query(GameSession).filter(GameSession.patient_id == patient_id).count() == 3
    assert db.query(Reminder).filter(Reminder.patient_id == patient_id).count() == 1
    db.close()

    # 7. CRITICAL IDEMPOTENCY TEST:
    # Repeat the identical sync request (e.g. client re-sends due to network timeout on response)
    sync_resp2 = client.post("/api/v1/sync", json={
        "patient_id": patient_id,
        "items": batch_items,
    }, headers=p_headers)

    assert sync_resp2.status_code == 200
    sync_data2 = sync_resp2.json()
    assert sync_data2["processed_count"] == 5

    # Confirm all operations return "already_processed" with the identical server_id
    for res in sync_data2["results"]:
        assert res["status"] == "already_processed"
        assert res["server_id"] == server_ids[res["operation_id"]]

    # Verify Database still contains EXACTLY 1 of each entity (ZERO duplicates)
    db = SessionLocal()
    assert db.query(Memory).filter(Memory.patient_id == patient_id).count() == 1
    assert db.query(GameSession).filter(GameSession.patient_id == patient_id).count() == 3
    assert db.query(Reminder).filter(Reminder.patient_id == patient_id).count() == 1
    db.close()

    # 8. CAREGIVER DASHBOARD VERIFICATION:
    # Caregiver retrieves summary for the authorized patient
    summary_resp = client.get(f"/api/v1/caregivers/patients/{patient_id}/summary", headers=c_headers)
    assert summary_resp.status_code == 200
    summary = summary_resp.json()
    assert summary["total_sessions"] == 3
    assert summary["memories_count"] == 1
    assert summary["active_reminders_count"] == 1
    assert summary["recent_activity_status"] == "Active & Engaged"

    # Caregiver retrieves session log
    sessions_resp = client.get(f"/api/v1/caregivers/patients/{patient_id}/game-sessions", headers=c_headers)
    assert sessions_resp.status_code == 200
    sessions = sessions_resp.json()
    assert len(sessions) == 3
    game_types = {s["game_type"] for s in sessions}
    assert "Memory Match" in game_types
    assert "Pattern Recognition" in game_types
    assert "Daily Routine Recall" in game_types

    # 9. PRIVACY CHECK: Unassigned caregiver is rejected with 403
    unauth_c = client.post("/api/v1/auth/register", json={
        "email": "intruder_caregiver@example.com",
        "password": "password123",
        "full_name": "Intruder",
        "role": "CAREGIVER",
    })
    unauth_token = unauth_c.json()["access_token"]
    intruder_resp = client.get(
        f"/api/v1/caregivers/patients/{patient_id}/summary",
        headers={"Authorization": f"Bearer {unauth_token}"},
    )
    assert intruder_resp.status_code == 403
