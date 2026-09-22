"""Tests for authentication and identity endpoints."""
import pytest
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.db.base import Base
from backend.api.app.db.session import engine, SessionLocal
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver

@pytest.fixture(autouse=True)
def setup_db():
    db = SessionLocal()
    try:
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

def test_register_patient_success(client):
    payload = {
        "email": "patient@example.com",
        "password": "securepassword123",
        "full_name": "Test Patient",
        "role": "PATIENT",
        "anonymous_alias": "Patient 01",
        "preferred_language": "en",
    }
    response = client.post("/api/v1/auth/register", json=payload)
    assert response.status_code == 201
    data = response.json()
    assert "access_token" in data
    assert data["role"] == "PATIENT"
    assert data["patient_id"] is not None

def test_register_duplicate_email_fails(client):
    payload = {
        "email": "duplicate@example.com",
        "password": "password123",
        "full_name": "First User",
        "role": "PATIENT",
    }
    r1 = client.post("/api/v1/auth/register", json=payload)
    assert r1.status_code == 201

    r2 = client.post("/api/v1/auth/register", json=payload)
    assert r2.status_code == 400
    assert "already exists" in r2.json()["detail"]

def test_login_success_and_failure(client):
    register_payload = {
        "email": "login_user@example.com",
        "password": "correctpassword",
        "full_name": "Login User",
        "role": "CAREGIVER",
    }
    client.post("/api/v1/auth/register", json=register_payload)

    # Valid login
    login_resp = client.post("/api/v1/auth/login", json={
        "email": "login_user@example.com",
        "password": "correctpassword",
    })
    assert login_resp.status_code == 200
    assert "access_token" in login_resp.json()
    assert login_resp.json()["role"] == "CAREGIVER"

    # Invalid password
    bad_resp = client.post("/api/v1/auth/login", json={
        "email": "login_user@example.com",
        "password": "wrongpassword",
    })
    assert bad_resp.status_code == 401

def test_get_me_protected_endpoint(client):
    # Register & get token
    reg_resp = client.post("/api/v1/auth/register", json={
        "email": "me_user@example.com",
        "password": "password123",
        "full_name": "Me User",
        "role": "PATIENT",
    })
    token = reg_resp.json()["access_token"]

    # Without token
    unauth_resp = client.get("/api/v1/auth/me")
    assert unauth_resp.status_code == 401

    # With valid token
    auth_resp = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {token}"},
    )
    assert auth_resp.status_code == 200
    user_data = auth_resp.json()
    assert user_data["email"] == "me_user@example.com"
    assert user_data["role"] == "PATIENT"
    assert user_data["patient_id"] is not None
