"""Tests for Phase 06B Real Authentication, Role-Based Access, and Caregiver-Patient Linking."""
import pytest
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.db.session import SessionLocal
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.sync_operation import SyncOperation
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession

@pytest.fixture(autouse=True)
def clean_db():
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

def test_patient_and_caregiver_registration_and_linking(client):
    # 1. Register Patient A
    p_resp = client.post("/api/v1/auth/register", json={
        "email": "patient_a@example.com",
        "password": "Password123!",
        "full_name": "Patient Alpha",
        "role": "PATIENT",
        "anonymous_alias": "Alpha Alias",
        "preferred_language": "hi",
    })
    assert p_resp.status_code == 201
    p_data = p_resp.json()
    assert p_data["role"] == "PATIENT"
    assert p_data["patient_id"] is not None
    p_token = p_data["access_token"]
    p_id = p_data["patient_id"]

    # 2. Verify Patient Profile via /auth/me
    p_me = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {p_token}"})
    assert p_me.status_code == 200
    assert p_me.json()["email"] == "patient_a@example.com"
    assert p_me.json()["preferred_language"] == "hi"
    assert p_me.json()["anonymous_alias"] == "Alpha Alias"

    # 3. Patient updates profile preferences
    up_resp = client.put("/api/v1/auth/patient-profile", json={
        "preferred_language": "as",
        "contrast_preference": "high",
        "font_scale_preference": 1.25,
    }, headers={"Authorization": f"Bearer {p_token}"})
    assert up_resp.status_code == 200
    assert up_resp.json()["preferred_language"] == "as"
    assert up_resp.json()["contrast_preference"] == "high"

    # 4. Register Caregiver C1
    c_resp = client.post("/api/v1/auth/register", json={
        "email": "caregiver_c1@example.com",
        "password": "Password123!",
        "full_name": "Caregiver One",
        "role": "CAREGIVER",
        "relationship_to_patient": "Daughter",
        "phone_number": "+919876543210",
    })
    assert c_resp.status_code == 201
    c_data = c_resp.json()
    assert c_data["role"] == "CAREGIVER"
    assert c_data["caregiver_id"] is not None
    c_token = c_data["access_token"]

    # 5. Initially Caregiver C1 has no authorized patients
    patients_resp = client.get("/api/v1/caregivers/patients", headers={"Authorization": f"Bearer {c_token}"})
    assert patients_resp.status_code == 200
    assert len(patients_resp.json()) == 0

    # 6. Caregiver C1 attempts to link nonexistent patient email -> 404 with generic message
    bad_link = client.post("/api/v1/caregivers/link-patient", json={
        "patient_email": "nonexistent_patient@example.com",
    }, headers={"Authorization": f"Bearer {c_token}"})
    assert bad_link.status_code == 404
    assert "Unable to link patient" in bad_link.json()["detail"]

    # 7. Caregiver C1 links Patient A via valid email
    link_resp = client.post("/api/v1/caregivers/link-patient", json={
        "patient_email": "patient_a@example.com",
        "relationship_type": "Primary Daughter",
    }, headers={"Authorization": f"Bearer {c_token}"})
    assert link_resp.status_code == 200
    assert link_resp.json()["id"] == p_id

    # 8. Caregiver C1 now sees Patient A in authorized list
    patients_resp2 = client.get("/api/v1/caregivers/patients", headers={"Authorization": f"Bearer {c_token}"})
    assert patients_resp2.status_code == 200
    assert len(patients_resp2.json()) == 1
    assert patients_resp2.json()[0]["id"] == p_id

    # 9. Caregiver C1 can view Patient A summary
    sum_resp = client.get(f"/api/v1/caregivers/patients/{p_id}/summary", headers={"Authorization": f"Bearer {c_token}"})
    assert sum_resp.status_code == 200
    assert sum_resp.json()["patient_id"] == p_id

    # 10. Register Caregiver C2 (unauthorized intruder)
    c2_resp = client.post("/api/v1/auth/register", json={
        "email": "caregiver_intruder@example.com",
        "password": "Password123!",
        "full_name": "Intruder Caregiver",
        "role": "CAREGIVER",
    })
    c2_token = c2_resp.json()["access_token"]

    # 11. Caregiver C2 attempting to access Patient A summary -> 403 Forbidden!
    forbidden_resp = client.get(f"/api/v1/caregivers/patients/{p_id}/summary", headers={"Authorization": f"Bearer {c2_token}"})
    assert forbidden_resp.status_code == 403
    assert "not authorized" in forbidden_resp.json()["detail"]

    # 12. Patient attempting to call caregiver endpoints -> 403 Forbidden!
    patient_call_caregiver = client.get("/api/v1/caregivers/patients", headers={"Authorization": f"Bearer {p_token}"})
    assert patient_call_caregiver.status_code == 403

    # 13. Unauthenticated request to protected endpoint -> 401 Unauthorized!
    unauth_resp = client.get(f"/api/v1/caregivers/patients/{p_id}/summary")
    assert unauth_resp.status_code == 401
