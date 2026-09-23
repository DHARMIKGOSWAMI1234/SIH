"""Tests for Caregiver ↔ Patient Pairing and Multi-Patient Data Isolation."""
import pytest
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient
from sqlalchemy.orm import Session

from backend.api.app.main import app
from backend.api.app.db.session import get_db, SessionLocal
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.pairing_request import CaregiverPairingRequest
from backend.api.app.models.game_session import GameSession
from backend.api.app.auth.security import create_access_token, get_password_hash

client = TestClient(app)

@pytest.fixture
def db_session():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@pytest.fixture
def test_caregiver_auth(db_session: Session):
    """Fixture providing an authenticated caregiver token and caregiver model."""
    user = db_session.query(User).filter(User.email == "test_cg_pair@smriti.care").first()
    if not user:
        user = User(
            id="test-cg-pair-user",
            email="test_cg_pair@smriti.care",
            password_hash=get_password_hash("Caregiver123!"),
            full_name="Dr. Pairing Caregiver",
            role=UserRole.CAREGIVER.value,
        )
        db_session.add(user)
        db_session.commit()

    caregiver = db_session.query(Caregiver).filter(Caregiver.user_id == user.id).first()
    if not caregiver:
        caregiver = Caregiver(
            id="test-cg-pair-id",
            user_id=user.id,
            full_name="Dr. Pairing Caregiver",
            relationship_to_patient="Physician / Caregiver",
        )
        db_session.add(caregiver)
        db_session.commit()

    token = create_access_token(
        data={"sub": user.id, "role": user.role, "user_id": user.id, "caregiver_id": caregiver.id}
    )
    return {"token": token, "caregiver": caregiver, "user": user}

@pytest.fixture
def test_patients(db_session: Session):
    """Fixture providing two distinct patients."""
    # Patient A
    user_a = db_session.query(User).filter(User.email == "patient_alpha@smriti.care").first()
    if not user_a:
        user_a = User(
            id="patient-alpha-user",
            email="patient_alpha@smriti.care",
            password_hash=get_password_hash("Patient123!"),
            full_name="Patient Alpha",
            role=UserRole.PATIENT.value,
        )
        db_session.add(user_a)
        db_session.commit()

    patient_a = db_session.query(Patient).filter(Patient.id == "patient-alpha-id").first()
    if not patient_a:
        patient_a = Patient(
            id="patient-alpha-id",
            user_id=user_a.id,
            anonymous_alias="Patient Alpha",
        )
        db_session.add(patient_a)
        db_session.commit()

    # Patient B
    user_b = db_session.query(User).filter(User.email == "patient_beta@smriti.care").first()
    if not user_b:
        user_b = User(
            id="patient-beta-user",
            email="patient_beta@smriti.care",
            password_hash=get_password_hash("Patient123!"),
            full_name="Patient Beta",
            role=UserRole.PATIENT.value,
        )
        db_session.add(user_b)
        db_session.commit()

    patient_b = db_session.query(Patient).filter(Patient.id == "patient-beta-id").first()
    if not patient_b:
        patient_b = Patient(
            id="patient-beta-id",
            user_id=user_b.id,
            anonymous_alias="Patient Beta",
        )
        db_session.add(patient_b)
        db_session.commit()

    token_a = create_access_token(
        data={"sub": user_a.id, "role": user_a.role, "user_id": user_a.id, "patient_id": patient_a.id}
    )
    token_b = create_access_token(
        data={"sub": user_b.id, "role": user_b.role, "user_id": user_b.id, "patient_id": patient_b.id}
    )

    return {
        "patient_a": patient_a,
        "token_a": token_a,
        "patient_b": patient_b,
        "token_b": token_b,
    }


def test_caregiver_create_pairing_request(test_caregiver_auth):
    """Test generating a pairing request returns a 4-digit code and QR payload."""
    headers = {"Authorization": f"Bearer {test_caregiver_auth['token']}"}
    response = client.post("/api/v1/caregivers/pairing/create", headers=headers)
    assert response.status_code == 201
    data = response.json()

    assert "request_id" in data
    assert "short_code" in data
    assert len(data["short_code"]) == 4
    assert data["short_code"].isdigit()
    assert "pairing_token" in data
    assert data["qr_payload"].startswith("smriti://pair?token=")
    assert data["caregiver_name"] == "Dr. Pairing Caregiver"
    assert data["expires_in_seconds"] == 600


def test_validate_pairing_with_short_code(test_caregiver_auth):
    """Test patient validating a pairing request using the 4-digit code."""
    # 1. Caregiver creates request
    headers = {"Authorization": f"Bearer {test_caregiver_auth['token']}"}
    create_resp = client.post("/api/v1/caregivers/pairing/create", headers=headers)
    code = create_resp.json()["short_code"]

    # 2. Patient validates code
    val_resp = client.post("/api/v1/patient/pairing/validate", json={"short_code": code})
    assert val_resp.status_code == 200
    val_data = val_resp.json()
    assert val_data["valid"] is True
    assert val_data["caregiver_name"] == "Dr. Pairing Caregiver"
    assert "pairing_token" in val_data


def test_validate_pairing_with_qr_payload(test_caregiver_auth):
    """Test patient validating a pairing request using full QR payload."""
    headers = {"Authorization": f"Bearer {test_caregiver_auth['token']}"}
    create_resp = client.post("/api/v1/caregivers/pairing/create", headers=headers)
    qr_payload = create_resp.json()["qr_payload"]

    val_resp = client.post("/api/v1/patient/pairing/validate", json={"qr_payload": qr_payload})
    assert val_resp.status_code == 200
    assert val_resp.json()["valid"] is True


def test_validate_invalid_and_expired_code(db_session, test_caregiver_auth):
    """Test invalid or expired codes are safely rejected."""
    # Invalid code
    resp = client.post("/api/v1/patient/pairing/validate", json={"short_code": "0000"})
    assert resp.status_code == 404

    # Expired code
    req = CaregiverPairingRequest(
        caregiver_id=test_caregiver_auth["caregiver"].id,
        short_code="9991",
        pairing_token="expired-token-12345",
        qr_payload="smriti://pair?token=expired-token-12345&code=9991",
        created_at=datetime.now(timezone.utc) - timedelta(minutes=20),
        expires_at=datetime.now(timezone.utc) - timedelta(minutes=10),
        status="PENDING",
    )
    db_session.add(req)
    db_session.commit()

    resp_expired = client.post("/api/v1/patient/pairing/validate", json={"pairing_token": "expired-token-12345"})
    assert resp_expired.status_code == 400
    assert "expired" in resp_expired.json()["detail"].lower()


def test_confirm_pairing_links_patient(test_caregiver_auth, test_patients, db_session):
    """Test patient confirming pairing successfully links caregiver and patient."""
    headers = {"Authorization": f"Bearer {test_caregiver_auth['token']}"}
    create_resp = client.post("/api/v1/caregivers/pairing/create", headers=headers)
    token = create_resp.json()["pairing_token"]
    req_id = create_resp.json()["request_id"]

    patient_a = test_patients["patient_a"]

    # Confirm pairing
    conf_resp = client.post(
        "/api/v1/patient/pairing/confirm",
        json={"pairing_token": token, "patient_id": patient_a.id},
    )
    assert conf_resp.status_code == 200
    assert conf_resp.json()["success"] is True
    assert conf_resp.json()["caregiver_name"] == "Dr. Pairing Caregiver"

    # Verify link exists in database
    link = (
        db_session.query(PatientCaregiver)
        .filter(
            PatientCaregiver.patient_id == patient_a.id,
            PatientCaregiver.caregiver_id == test_caregiver_auth["caregiver"].id,
        )
        .first()
    )
    assert link is not None
    assert link.can_view is True

    # Check status endpoint from dashboard perspective
    status_resp = client.get(f"/api/v1/caregivers/pairing/{req_id}/status", headers=headers)
    assert status_resp.status_code == 200
    assert status_resp.json()["is_used"] is True
    assert status_resp.json()["patient_id"] == patient_a.id


def test_multi_patient_monitoring_and_data_isolation(test_caregiver_auth, test_patients, db_session):
    """Test caregiver monitoring multiple patients and verify strict data isolation."""
    caregiver = test_caregiver_auth["caregiver"]
    patient_a = test_patients["patient_a"]
    patient_b = test_patients["patient_b"]

    # Link both patients to caregiver
    for p in [patient_a, patient_b]:
        existing = (
            db_session.query(PatientCaregiver)
            .filter(PatientCaregiver.patient_id == p.id, PatientCaregiver.caregiver_id == caregiver.id)
            .first()
        )
        if not existing:
            db_session.add(
                PatientCaregiver(patient_id=p.id, caregiver_id=caregiver.id, can_view=True, can_edit=False)
            )
    db_session.commit()

    # Verify caregiver has both patients in authorized list
    cg_headers = {"Authorization": f"Bearer {test_caregiver_auth['token']}"}
    patients_resp = client.get("/api/v1/caregivers/patients", headers=cg_headers)
    assert patients_resp.status_code == 200
    patient_ids = [p["id"] for p in patients_resp.json()]
    assert patient_a.id in patient_ids
    assert patient_b.id in patient_ids

    # Patient A plays a game session
    now = datetime.now(timezone.utc)
    sess_a = GameSession(
        patient_id=patient_a.id,
        local_id="local-sess-alpha-1",
        game_type="MEMORY_MATCH",
        score=100,
        accuracy=95.0,
        mistakes=1,
        response_time_ms=1200,
        difficulty=1,
        started_at=now - timedelta(minutes=5),
        completed_at=now,
    )
    db_session.add(sess_a)
    db_session.commit()

    # Query Patient A's game sessions
    resp_a = client.get(f"/api/v1/caregivers/patients/{patient_a.id}/game-sessions", headers=cg_headers)
    assert resp_a.status_code == 200
    sessions_a = resp_a.json()
    assert len(sessions_a) >= 1
    assert any(s["local_id"] == "local-sess-alpha-1" for s in sessions_a)

    # CRITICAL: Query Patient B's game sessions - MUST NOT contain Patient A's session!
    resp_b = client.get(f"/api/v1/caregivers/patients/{patient_b.id}/game-sessions", headers=cg_headers)
    assert resp_b.status_code == 200
    sessions_b = resp_b.json()
    assert not any(s["local_id"] == "local-sess-alpha-1" for s in sessions_b)

    # Summary isolation
    sum_a = client.get(f"/api/v1/caregivers/patients/{patient_a.id}/summary", headers=cg_headers).json()
    sum_b = client.get(f"/api/v1/caregivers/patients/{patient_b.id}/summary", headers=cg_headers).json()
    assert sum_a["total_sessions"] >= 1
    # Patient B has 0 sessions
    assert sum_b["total_sessions"] == 0
