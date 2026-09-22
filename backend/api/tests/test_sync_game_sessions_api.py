"""Comprehensive automated tests for GameSession sync endpoint, validation, idempotency, and RBAC authorization."""
import pytest
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.db.session import SessionLocal
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.sync_operation import SyncOperation

@pytest.fixture(autouse=True)
def cleanup_database():
    db = SessionLocal()
    try:
        db.query(SyncOperation).delete()
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

def create_patient(client, email: str, name: str = "Test Patient"):
    resp = client.post("/api/v1/auth/register", json={
        "email": email,
        "password": "Password123!",
        "full_name": name,
        "role": "PATIENT",
        "anonymous_alias": f"Alias {name}",
    })
    assert resp.status_code == 201
    data = resp.json()
    return data["access_token"], data["patient_id"], data["user_id"]

def create_caregiver(client, email: str, name: str = "Test Caregiver"):
    resp = client.post("/api/v1/auth/register", json={
        "email": email,
        "password": "Password123!",
        "full_name": name,
        "role": "CAREGIVER",
    })
    assert resp.status_code == 201
    data = resp.json()
    return data["access_token"], data["caregiver_id"], data["user_id"]

def test_sync_game_session_success_and_idempotency(client):
    """Test successful GameSession sync and idempotency on repeat calls."""
    token, patient_id, _ = create_patient(client, "patient_sync@example.com")
    headers = {"Authorization": f"Bearer {token}"}

    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=2)).isoformat()

    item_payload = {
        "operation_id": "op-gs-pr-001",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-gs-pr-001",
        "payload": {
            "gameType": "Pattern Recognition",
            "score": 100,
            "accuracy": 1.0,
            "mistakes": 0,
            "responseTimeMs": 1200.0,
            "difficulty": 1,
            "hintCount": 0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
        "client_updated_at": completed_at,
    }

    # 1. First sync call -> returns "synced"
    resp1 = client.post(
        "/api/v1/sync/game-sessions",
        json=item_payload,
        headers=headers,
    )
    assert resp1.status_code == 200
    res1 = resp1.json()
    assert res1["status"] == "synced"
    assert res1["server_id"] is not None
    assert res1["operation_id"] == "op-gs-pr-001"
    server_id_1 = res1["server_id"]

    # Verify DB has exactly 1 GameSession
    db = SessionLocal()
    assert db.query(GameSession).filter(GameSession.patient_id == patient_id).count() == 1
    session_row = db.query(GameSession).filter(GameSession.patient_id == patient_id).first()
    assert session_row.game_type == "Pattern Recognition"
    assert session_row.score == 100
    assert session_row.accuracy == 1.0
    db.close()

    # 2. CRITICAL IDEMPOTENCY TEST: Repeat identical request -> returns "already_processed"
    resp2 = client.post(
        "/api/v1/sync/game-sessions",
        json=item_payload,
        headers=headers,
    )
    assert resp2.status_code == 200
    res2 = resp2.json()
    assert res2["status"] == "already_processed"
    assert res2["server_id"] == server_id_1

    # Verify DB STILL has EXACTLY 1 GameSession (ZERO duplicates)
    db = SessionLocal()
    assert db.query(GameSession).filter(GameSession.patient_id == patient_id).count() == 1
    db.close()

def test_sync_game_session_validation_rejections(client):
    """Test server-side validation rejecting malformed payloads with HTTP 422."""
    token, patient_id, _ = create_patient(client, "patient_val@example.com")
    headers = {"Authorization": f"Bearer {token}"}

    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=2)).isoformat()

    base_payload = {
        "operation_id": "op-val-001",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-val-001",
        "payload": {
            "gameType": "Pattern Recognition",
            "score": 100,
            "accuracy": 0.95,
            "mistakes": 1,
            "responseTimeMs": 1200.0,
            "difficulty": 1,
            "hintCount": 0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
    }

    # Case A: Invalid game type
    bad_game = dict(base_payload)
    bad_game["operation_id"] = "op-bad-game"
    bad_game["local_id"] = "loc-bad-game"
    bad_game["payload"] = dict(base_payload["payload"], gameType="Poker Game")
    resp_a = client.post("/api/v1/sync/game-sessions", json=bad_game, headers=headers)
    assert resp_a.status_code == 422
    assert "Invalid game type" in resp_a.json()["detail"]

    # Case B: Negative score
    bad_score = dict(base_payload)
    bad_score["operation_id"] = "op-bad-score"
    bad_score["local_id"] = "loc-bad-score"
    bad_score["payload"] = dict(base_payload["payload"], score=-50)
    resp_b = client.post("/api/v1/sync/game-sessions", json=bad_score, headers=headers)
    assert resp_b.status_code == 422
    assert "Score must be non-negative" in resp_b.json()["detail"]

    # Case C: Out-of-bounds accuracy (> 100)
    bad_acc = dict(base_payload)
    bad_acc["operation_id"] = "op-bad-acc"
    bad_acc["local_id"] = "loc-bad-acc"
    bad_acc["payload"] = dict(base_payload["payload"], accuracy=150.0)
    resp_c = client.post("/api/v1/sync/game-sessions", json=bad_acc, headers=headers)
    assert resp_c.status_code == 422
    assert "Accuracy must be between" in resp_c.json()["detail"]

    # Case D: Inverted timestamps (completed_at < started_at)
    bad_time = dict(base_payload)
    bad_time["operation_id"] = "op-bad-time"
    bad_time["local_id"] = "loc-bad-time"
    bad_time["payload"] = dict(
        base_payload["payload"],
        startedAt="2026-09-21T12:00:00",
        completedAt="2026-09-21T11:00:00",
    )
    resp_d = client.post("/api/v1/sync/game-sessions", json=bad_time, headers=headers)
    assert resp_d.status_code == 422
    assert "Completed time cannot be earlier than started time" in resp_d.json()["detail"]

    # Case E: Missing local_id
    bad_local = dict(base_payload)
    bad_local["operation_id"] = "op-bad-local"
    bad_local["local_id"] = ""
    resp_e = client.post("/api/v1/sync/game-sessions", json=bad_local, headers=headers)
    assert resp_e.status_code == 422

def test_rbac_caregiver_authorization(client):
    """Test Caregiver RBAC authorization enforcement.
    
    Caregiver A requesting Patient A -> 200 OK
    Caregiver A requesting Patient B -> 403 Forbidden
    Patient attempting caregiver endpoint -> 403 Forbidden
    Patient attempting to sync for another patient -> 403 Forbidden
    """
    pA_token, pA_id, _ = create_patient(client, "patient_a@example.com", "Patient A")
    pB_token, pB_id, _ = create_patient(client, "patient_b@example.com", "Patient B")
    cA_token, cA_id, _ = create_caregiver(client, "caregiver_a@example.com", "Caregiver A")

    # Link Caregiver A to Patient A ONLY
    db = SessionLocal()
    assignment = PatientCaregiver(patient_id=pA_id, caregiver_id=cA_id, can_view=True, can_edit=True)
    db.add(assignment)
    db.commit()
    db.close()

    cA_headers = {"Authorization": f"Bearer {cA_token}"}
    pA_headers = {"Authorization": f"Bearer {pA_token}"}

    # 1. Caregiver A requests Patient A game-sessions -> Allowed (200)
    resp_ok = client.get(f"/api/v1/caregivers/patients/{pA_id}/game-sessions", headers=cA_headers)
    assert resp_ok.status_code == 200

    # 2. Caregiver A requests Patient B game-sessions -> Forbidden (403)
    resp_forbidden = client.get(f"/api/v1/caregivers/patients/{pB_id}/game-sessions", headers=cA_headers)
    assert resp_forbidden.status_code == 403

    # 3. Patient attempts caregiver endpoint -> Forbidden (403)
    resp_pat_on_cg = client.get("/api/v1/caregivers/patients", headers=pA_headers)
    assert resp_pat_on_cg.status_code == 403

    # 4. Patient A attempts to sync data using Patient B's ID -> Forbidden (403)
    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=1)).isoformat()
    impersonation_payload = {
        "operation_id": "op-impersonate-01",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-impersonate-01",
        "payload": {
            "gameType": "Memory Match",
            "score": 100,
            "accuracy": 1.0,
            "mistakes": 0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
    }
    resp_impersonate = client.post(
        f"/api/v1/sync/game-sessions?patient_id={pB_id}",
        json=impersonation_payload,
        headers=pA_headers,
    )
    assert resp_impersonate.status_code == 403
