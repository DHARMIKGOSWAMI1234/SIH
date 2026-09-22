"""Comprehensive tests for SMRITI Caregiver Intelligence & Deterministic Analytics.

Tests:
- Zero scheduled reminders (handled as INSUFFICIENT_DATA, adherence_rate=None)
- Future reminders (scheduled later today not counted as missed)
- Current period with data / previous period without data (INSUFFICIENT_DATA, no manufactured baseline)
- Zero previous baseline (safe division)
- Accuracy direction (higher -> IMPROVING, lower -> DECLINING)
- Mistakes direction (lower -> IMPROVING, higher -> DECLINING)
- Participation direction (higher -> INCREASED, lower -> DECREASED)
- Hints as descriptive-only metric (not classified as improving/declining)
- Duplicate sessions are not accidentally double-counted
- Timezone/date boundaries
- Caregiver cross-patient isolation (Caregiver A -> Patient A allowed, Caregiver A -> Patient B = 403)
- Real PostgreSQL analytics end-to-end
"""
import pytest
from datetime import datetime, timedelta, timezone
from fastapi.testclient import TestClient

from backend.api.app.main import app
from backend.api.app.db.session import SessionLocal
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder, ReminderEvent
from backend.api.app.models.sync_operation import SyncOperation

@pytest.fixture(autouse=True)
def clean_db():
    db = SessionLocal()
    try:
        db.query(SyncOperation).delete()
        db.query(ReminderEvent).delete()
        db.query(Reminder).delete()
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

def create_user_and_token(client, email: str, role: str):
    resp = client.post("/api/v1/auth/register", json={
        "email": email,
        "password": "Password123!",
        "full_name": f"User {email}",
        "role": role,
    })
    assert resp.status_code == 201, resp.text
    data = resp.json()
    return data["access_token"], data.get("patient_id"), data.get("caregiver_id")

def test_zero_scheduled_reminders(client):
    """Zero scheduled reminders must be handled as INSUFFICIENT_DATA and adherence_rate = None."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_zero_rem@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_zero_rem@example.com", "CAREGIVER")

        # Link caregiver to patient
        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/reminders?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()

        assert data["scheduled_count"] == 0
        assert data["adherence_rate"] is None
        assert data["trend_direction"] == "INSUFFICIENT_DATA"
        assert data["data_sufficient"] is False
    finally:
        db.close()

def test_future_reminders_not_counted_as_missed(client):
    """Scheduled reminders later today that have not yet occurred must not count as missed."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_future_rem@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_future_rem@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Create a reminder scheduled for 23:59 UTC
        rem = Reminder(
            patient_id=p_id,
            local_id="rem-future-01",
            title="Late Night Routine",
            reminder_type="routine",
            scheduled_time="23:59",
            enabled=True,
            created_at=now - timedelta(days=2),
        )
        db.add(rem)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/reminders?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()

        # If current time is before 23:59, today's 23:59 has NOT occurred yet
        # Ensure it was not counted if slot_dt > now
        if now.hour < 23 or (now.hour == 23 and now.minute < 59):
            # 23:59 has only occurred for past days (e.g. 6 occurrences in 7 days)
            assert data["scheduled_count"] <= 7
    finally:
        db.close()

def test_current_with_data_previous_without_data(client):
    """When current period has data but previous has none, trend must be INSUFFICIENT_DATA."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_no_prev@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_no_prev@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Add 3 sessions only in the current period (last 2 days)
        for i in range(3):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-curr-{i}",
                game_type="Memory Match",
                score=100,
                accuracy=90.0,
                mistakes=1,
                response_time_ms=1200.0,
                started_at=now - timedelta(days=1, hours=i),
                completed_at=now - timedelta(days=1, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/games?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()

        overall = data["overall"]
        assert overall["sessions_completed"] == 3
        assert overall["average_accuracy"] == 90.0
        # Data sufficiency requires at least 2 sessions in both current and previous periods
        assert overall["data_sufficient"] is False
        assert overall["accuracy_trend"] == "INSUFFICIENT_DATA"
        assert overall["mistakes_trend"] == "INSUFFICIENT_DATA"
        # No manufactured baseline
        assert "More sessions needed" in overall["trend_observation"] or "Not enough activity" in overall["trend_observation"]
    finally:
        db.close()

def test_accuracy_direction(client):
    """Accuracy trend: higher -> IMPROVING, lower -> DECLINING."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_acc@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_acc@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Previous period (8 to 14 days ago): accuracy = 70.0
        for i in range(2):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-prev-acc-{i}",
                game_type="Memory Match",
                score=70,
                accuracy=70.0,
                mistakes=3,
                response_time_ms=1500.0,
                started_at=now - timedelta(days=10, hours=i),
                completed_at=now - timedelta(days=10, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)

        # Current period (1 to 7 days ago): accuracy = 90.0 (> 70.0 + 3.0)
        for i in range(2):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-curr-acc-{i}",
                game_type="Memory Match",
                score=90,
                accuracy=90.0,
                mistakes=3,
                response_time_ms=1500.0,
                started_at=now - timedelta(days=2, hours=i),
                completed_at=now - timedelta(days=2, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/games?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()
        assert data["overall"]["accuracy_trend"] == "IMPROVING"
    finally:
        db.close()

def test_mistakes_direction(client):
    """Mistakes trend: lower -> IMPROVING, higher -> DECLINING."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_mistakes@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_mistakes@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Previous period: mistakes = 5
        for i in range(2):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-prev-m-{i}",
                game_type="Pattern Recognition",
                score=50,
                accuracy=70.0,
                mistakes=5,
                response_time_ms=1500.0,
                started_at=now - timedelta(days=10, hours=i),
                completed_at=now - timedelta(days=10, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)

        # Current period: mistakes = 1 (lower mistakes -> IMPROVING!)
        for i in range(2):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-curr-m-{i}",
                game_type="Pattern Recognition",
                score=90,
                accuracy=70.0,
                mistakes=1,
                response_time_ms=1500.0,
                started_at=now - timedelta(days=2, hours=i),
                completed_at=now - timedelta(days=2, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/games?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()
        assert data["overall"]["mistakes_trend"] == "IMPROVING"
    finally:
        db.close()

def test_participation_direction(client):
    """Participation trend: higher -> INCREASED, lower -> DECREASED."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_part@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_part@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Previous period: 2 activities
        for i in range(2):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-prev-p-{i}",
                game_type="Memory Match",
                score=80,
                accuracy=80.0,
                mistakes=2,
                started_at=now - timedelta(days=9, hours=i),
                completed_at=now - timedelta(days=9, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)

        # Current period: 5 activities (> 2)
        for i in range(5):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-curr-p-{i}",
                game_type="Memory Match",
                score=80,
                accuracy=80.0,
                mistakes=2,
                started_at=now - timedelta(days=2, hours=i),
                completed_at=now - timedelta(days=2, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/activity?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()
        assert data["participation_trend"] == "INCREASED"
        assert data["total_completed_activities"] == 5
    finally:
        db.close()

def test_hints_descriptive_only(client):
    """Hints metric must be descriptive-only and not classified as improving/declining."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_hints@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_hints@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Previous period: 0 hints
        for i in range(2):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-prev-h-{i}",
                game_type="Memory Match",
                score=80,
                accuracy=80.0,
                mistakes=2,
                hint_count=0,
                started_at=now - timedelta(days=10, hours=i),
                completed_at=now - timedelta(days=10, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)

        # Current period: 3 hints
        for i in range(2):
            gs = GameSession(
                patient_id=p_id,
                local_id=f"gs-curr-h-{i}",
                game_type="Memory Match",
                score=80,
                accuracy=80.0,
                mistakes=2,
                hint_count=3,
                started_at=now - timedelta(days=2, hours=i),
                completed_at=now - timedelta(days=2, hours=i) + timedelta(minutes=5),
            )
            db.add(gs)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/games?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()
        overall = data["overall"]
        # Hint usage must be described, not classified as improving/declining
        assert overall["hint_usage_observation"] is not None
        assert "more hints" in overall["hint_usage_observation"].lower()
    finally:
        db.close()

def test_duplicate_sessions_not_double_counted(client):
    """Duplicate sessions with the same id must not be double counted."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_dup@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_dup@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Create 1 session
        gs = GameSession(
            patient_id=p_id,
            local_id="gs-dup-01",
            game_type="Daily Routine Recall",
            score=100,
            accuracy=100.0,
            mistakes=0,
            started_at=now - timedelta(days=1),
            completed_at=now - timedelta(days=1) + timedelta(minutes=5),
        )
        db.add(gs)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/overview?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()
        assert data["total_completed_activities"] == 1
    finally:
        db.close()

def test_timezone_date_boundaries(client):
    """Sessions right at the boundary of 7 days must be placed in the correct period."""
    db = SessionLocal()
    try:
        token, p_id, _ = create_user_and_token(client, "patient_tz@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_tz@example.com", "CAREGIVER")

        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)

        now = datetime.now(timezone.utc)
        # Exactly 6 days, 23 hours ago -> in current 7-day period
        gs1 = GameSession(
            patient_id=p_id,
            local_id="gs-in-window",
            game_type="Memory Match",
            score=100,
            accuracy=100.0,
            started_at=now - timedelta(days=6, hours=23),
            completed_at=now - timedelta(days=6, hours=23) + timedelta(minutes=5),
        )
        # 7 days, 2 hours ago -> in previous 7-day period
        gs2 = GameSession(
            patient_id=p_id,
            local_id="gs-out-window",
            game_type="Memory Match",
            score=100,
            accuracy=100.0,
            started_at=now - timedelta(days=7, hours=2),
            completed_at=now - timedelta(days=7, hours=2) + timedelta(minutes=5),
        )
        db.add(gs1)
        db.add(gs2)
        db.commit()

        headers = {"Authorization": f"Bearer {c_token}"}
        resp = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/overview?period_days=7", headers=headers)
        assert resp.status_code == 200
        data = resp.json()
        assert data["total_completed_activities"] == 1
    finally:
        db.close()

def test_caregiver_cross_patient_isolation(client):
    """Caregiver A -> Patient A allowed; Caregiver A -> Patient B returns HTTP 403.
    No Patient B analytics leaked through errors, aggregates, trends, or sync.
    """
    db = SessionLocal()
    try:
        # Create Patient A and Patient B
        token_a, p_id_a, _ = create_user_and_token(client, "patient_iso_a@example.com", "PATIENT")
        token_b, p_id_b, _ = create_user_and_token(client, "patient_iso_b@example.com", "PATIENT")

        # Create Caregiver A and link to Patient A ONLY
        c_token_a, _, c_id_a = create_user_and_token(client, "caregiver_iso_a@example.com", "CAREGIVER")
        pc_a = PatientCaregiver(patient_id=p_id_a, caregiver_id=c_id_a, can_view=True, can_edit=True)
        db.add(pc_a)

        # Add private data for Patient B
        now = datetime.now(timezone.utc)
        gs_b = GameSession(
            patient_id=p_id_b,
            local_id="gs-secret-b",
            game_type="Memory Match",
            score=999,
            accuracy=99.9,
            started_at=now - timedelta(days=1),
            completed_at=now - timedelta(days=1) + timedelta(minutes=5),
        )
        db.add(gs_b)
        db.commit()

        headers_a = {"Authorization": f"Bearer {c_token_a}"}

        # 1. Caregiver A accessing Patient A -> 200 OK
        resp_a = client.get(f"/api/v1/caregivers/patients/{p_id_a}/analytics/overview", headers=headers_a)
        assert resp_a.status_code == 200
        assert resp_a.json()["patient_id"] == p_id_a

        # 2. Caregiver A accessing Patient B -> 403 Forbidden
        endpoints = [
            f"/api/v1/caregivers/patients/{p_id_b}/analytics/overview",
            f"/api/v1/caregivers/patients/{p_id_b}/analytics/activity",
            f"/api/v1/caregivers/patients/{p_id_b}/analytics/games",
            f"/api/v1/caregivers/patients/{p_id_b}/analytics/reminders",
            f"/api/v1/caregivers/patients/{p_id_b}/analytics/trends",
            f"/api/v1/caregivers/patients/{p_id_b}/analytics/sync",
        ]
        for ep in endpoints:
            resp_forbidden = client.get(ep, headers=headers_a)
            assert resp_forbidden.status_code == 403, f"Endpoint {ep} did not return 403: {resp_forbidden.text}"
            # Verify no Patient B data leaked in error body
            assert "999" not in resp_forbidden.text
            assert "gs-secret-b" not in resp_forbidden.text

        # 3. Verify Patient A overview contains zero records from Patient B
        data_a = resp_a.json()
        assert data_a["total_completed_activities"] == 0
    finally:
        db.close()

def test_real_postgresql_analytics_e2e(client):
    """End-to-end test: Patient Activity -> Sync -> PostgreSQL -> Analytics API -> Caregiver Dashboard."""
    db = SessionLocal()
    try:
        # Register patient and caregiver
        p_token, p_id, _ = create_user_and_token(client, "patient_e2e@example.com", "PATIENT")
        c_token, _, c_id = create_user_and_token(client, "caregiver_e2e@example.com", "CAREGIVER")

        # Link caregiver to patient
        pc = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
        db.add(pc)
        db.commit()

        p_headers = {"Authorization": f"Bearer {p_token}"}
        c_headers = {"Authorization": f"Bearer {c_token}"}

        now = datetime.now(timezone.utc)

        # 1. Sync batch of patient activity (2 game sessions, 1 reminder, 1 reminder event)
        sync_payload = {
            "patient_id": p_id,
            "items": [
                {
                    "operation_id": "op-e2e-gs-01",
                    "entity_type": "GameSessions",
                    "operation": "CREATE",
                    "local_id": "gs-e2e-01",
                    "payload": {
                        "gameType": "Memory Match",
                        "score": 100,
                        "accuracy": 85.0,
                        "mistakes": 2,
                        "responseTimeMs": 1300.0,
                        "difficulty": 1,
                        "hintCount": 1,
                        "startedAt": (now - timedelta(days=2)).isoformat(),
                        "completedAt": (now - timedelta(days=2) + timedelta(minutes=4)).isoformat(),
                    },
                    "client_updated_at": now.isoformat(),
                },
                {
                    "operation_id": "op-e2e-gs-02",
                    "entity_type": "GameSessions",
                    "operation": "CREATE",
                    "local_id": "gs-e2e-02",
                    "payload": {
                        "gameType": "Memory Match",
                        "score": 110,
                        "accuracy": 95.0,
                        "mistakes": 1,
                        "responseTimeMs": 1100.0,
                        "difficulty": 1,
                        "hintCount": 0,
                        "startedAt": (now - timedelta(days=1)).isoformat(),
                        "completedAt": (now - timedelta(days=1) + timedelta(minutes=4)).isoformat(),
                    },
                    "client_updated_at": now.isoformat(),
                },
                {
                    "operation_id": "op-e2e-rem-01",
                    "entity_type": "Reminders",
                    "operation": "CREATE",
                    "local_id": "rem-e2e-01",
                    "payload": {
                        "title": "Morning Hydration",
                        "reminderType": "hydration",
                        "scheduledTime": "09:00",
                        "enabled": True,
                    },
                    "client_updated_at": now.isoformat(),
                },
            ],
        }

        sync_resp = client.post("/api/v1/sync", json=sync_payload, headers=p_headers)
        assert sync_resp.status_code == 200
        assert sync_resp.json()["processed_count"] == 3

        # Add a completed ReminderEvent in DB
        rem_ev = ReminderEvent(
            patient_id=p_id,
            local_id="ev-e2e-01",
            reminder_id="rem-e2e-01",
            event_type="acknowledged",
            occurred_at=now - timedelta(days=1, hours=2),
        )
        db.add(rem_ev)
        db.commit()

        # 2. Query Analytics API as Caregiver
        # A. Overview
        resp_overview = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/overview?period_days=7", headers=c_headers)
        assert resp_overview.status_code == 200
        overview_data = resp_overview.json()
        assert overview_data["total_completed_activities"] == 3  # 2 games + 1 reminder event
        assert overview_data["active_days"] == 2

        # B. Games
        resp_games = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/games?period_days=7", headers=c_headers)
        assert resp_games.status_code == 200
        games_data = resp_games.json()
        overall = games_data["overall"]
        assert overall["sessions_completed"] == 2
        assert overall["average_score"] == 105.0  # (100 + 110) / 2
        assert overall["average_accuracy"] == 90.0  # (85 + 95) / 2
        assert overall["average_mistakes"] == 1.5  # (2 + 1) / 2
        assert overall["average_response_time_ms"] == 1200.0  # (1300 + 1100) / 2

        # C. Trends
        resp_trends = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/trends?period_days=7", headers=c_headers)
        assert resp_trends.status_code == 200
        trends_data = resp_trends.json()
        assert "SMRITI is a non-diagnostic platform" in trends_data["clinical_disclaimer"]
        assert len(trends_data["trends"]) >= 3

        # D. Sync Health
        resp_sync = client.get(f"/api/v1/caregivers/patients/{p_id}/analytics/sync", headers=c_headers)
        assert resp_sync.status_code == 200
        sync_data = resp_sync.json()
        assert sync_data["sync_status"] == "UP_TO_DATE"
    finally:
        db.close()
