"""Direct PostgreSQL 18 Verification Suite for SMRITI Phase 04 Final Verification.

Verifies:
1. Real PostgreSQL database connection and engine dialect.
2. Direct SQL validation via psycopg2 in smriti_db on PostgreSQL 18.
3. Real sync pipeline: API -> PostgreSQL -> verified via raw SQL.
4. Idempotency on repeat operation_id: verified via raw SQL COUNT = 1.
5. Duplicate local_id protection: verified via raw SQL COUNT = 1.
6. Server-side validation against PostgreSQL: HTTP 422, verified raw SQL COUNT = 0.
7. Caregiver RBAC authorization enforcement against PostgreSQL.
8. Caregiver Dashboard API reading live PostgreSQL data and empty states.
"""
import pytest
import psycopg2
from datetime import datetime, timezone, timedelta
from fastapi.testclient import TestClient
from backend.api.app.main import app
from backend.api.app.core.config import settings
from backend.api.app.db.session import engine, SessionLocal
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.sync_operation import SyncOperation

POSTGRES_DSN = "postgresql://smriti_user:1234@localhost:5432/smriti_db"

def get_raw_pg_connection():
    return psycopg2.connect(POSTGRES_DSN)

@pytest.fixture(autouse=True)
def clean_postgres_test_data():
    """Ensure clean database state before each test in PostgreSQL."""
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

# ==============================================================================
# 1. PostgreSQL Engine & Database Connection Verification
# ==============================================================================

def test_postgresql_connection_and_version():
    """Verify that backend uses PostgreSQL and direct psycopg2 connection reports PostgreSQL 18."""
    # Check SQLAlchemy active engine dialect
    assert engine.dialect.name == "postgresql", f"Expected postgresql dialect, got: {engine.dialect.name}"

    # Check direct psycopg2 connection to PostgreSQL
    conn = get_raw_pg_connection()
    try:
        cur = conn.cursor()
        cur.execute("SELECT version();")
        version_str = cur.fetchone()[0]
        assert "PostgreSQL 18" in version_str, f"Expected PostgreSQL 18, got: {version_str}"

        # Verify required tables exist in public schema
        cur.execute("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            AND table_name IN ('users', 'patients', 'caregivers', 'patient_caregivers', 'game_sessions', 'sync_operations');
        """)
        tables = {r[0] for r in cur.fetchall()}
        required = {'users', 'patients', 'caregivers', 'patient_caregivers', 'game_sessions', 'sync_operations'}
        assert required.issubset(tables), f"Missing tables in PostgreSQL: {required - tables}"
    finally:
        conn.close()

# ==============================================================================
# 2. Real PostgreSQL Sync Pipeline (API -> PostgreSQL -> verified via raw SQL)
# ==============================================================================

def test_real_postgresql_sync_flow_and_direct_sql_verification(client):
    """Verify end-to-end sync through FastAPI persisted into PostgreSQL and verified via raw SQL."""
    p_token, p_id, _ = create_patient(client, "pg_sync_patient@example.com", "PG Patient")
    c_token, c_id, _ = create_caregiver(client, "pg_sync_caregiver@example.com", "PG Caregiver")

    # Link Caregiver to Patient
    db = SessionLocal()
    assignment = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
    db.add(assignment)
    db.commit()
    db.close()

    p_headers = {"Authorization": f"Bearer {p_token}"}
    c_headers = {"Authorization": f"Bearer {c_token}"}

    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=3)).isoformat()

    # Create legitimate Pattern Recognition session
    session_payload = {
        "operation_id": "op-pg-pr-100",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-pg-pr-100",
        "payload": {
            "gameType": "Pattern Recognition",
            "score": 120,
            "accuracy": 1.0,
            "mistakes": 0,
            "responseTimeMs": 1350.0,
            "difficulty": 1,
            "hintCount": 0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
        "client_updated_at": completed_at,
    }

    # Submit via dedicated endpoint
    resp = client.post("/api/v1/sync/game-sessions", json=session_payload, headers=p_headers)
    assert resp.status_code == 200
    res_data = resp.json()
    assert res_data["status"] == "synced"
    server_id = res_data["server_id"]
    assert server_id is not None

    # DIRECT RAW SQL VERIFICATION IN POSTGRESQL 18:
    conn = get_raw_pg_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT id, patient_id, local_id, game_type, score, accuracy, difficulty 
            FROM game_sessions 
            WHERE id = %s;
        """, (server_id,))
        row = cur.fetchone()
        assert row is not None, "Record was not found in PostgreSQL!"
        assert row[0] == server_id
        assert row[1] == p_id
        assert row[2] == "loc-pg-pr-100"
        assert row[3] == "Pattern Recognition"
        assert row[4] == 120
        assert row[5] == 1.0
        assert row[6] == 1

        # Verify sync_operations audit record in PostgreSQL
        cur.execute("""
            SELECT operation_id, status, server_id 
            FROM sync_operations 
            WHERE operation_id = %s;
        """, ("op-pg-pr-100",))
        op_row = cur.fetchone()
        assert op_row is not None
        assert op_row[0] == "op-pg-pr-100"
        assert op_row[1] == "synced"
        assert op_row[2] == server_id
    finally:
        conn.close()

# ==============================================================================
# 3. PostgreSQL Idempotency Test (repeat operation_id -> COUNT = 1)
# ==============================================================================

def test_postgresql_idempotency_duplicate_safe(client):
    """Verify that retrying with identical operation_id returns already_processed and leaves COUNT = 1 in PostgreSQL."""
    p_token, p_id, _ = create_patient(client, "pg_idemp_patient@example.com")
    headers = {"Authorization": f"Bearer {p_token}"}

    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=2)).isoformat()

    payload = {
        "operation_id": "op-pg-idemp-001",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-pg-idemp-001",
        "payload": {
            "gameType": "Pattern Recognition",
            "score": 100,
            "accuracy": 0.9,
            "mistakes": 1,
            "responseTimeMs": 1400.0,
            "difficulty": 1,
            "hintCount": 0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
    }

    # Request 1
    resp1 = client.post("/api/v1/sync/game-sessions", json=payload, headers=headers)
    assert resp1.status_code == 200
    server_id = resp1.json()["server_id"]

    # Request 2 (Retry: network response lost)
    resp2 = client.post("/api/v1/sync/game-sessions", json=payload, headers=headers)
    assert resp2.status_code == 200
    assert resp2.json()["status"] == "already_processed"
    assert resp2.json()["server_id"] == server_id

    # Verify directly via SQL in PostgreSQL that COUNT = 1
    conn = get_raw_pg_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT COUNT(*) 
            FROM game_sessions 
            WHERE patient_id = %s AND local_id = %s;
        """, (p_id, "loc-pg-idemp-001"))
        count = cur.fetchone()[0]
        assert count == 1, f"Expected exactly 1 record in PostgreSQL, found: {count}"

        cur.execute("""
            SELECT COUNT(*) 
            FROM sync_operations 
            WHERE operation_id = %s;
        """, ("op-pg-idemp-001",))
        op_count = cur.fetchone()[0]
        assert op_count == 1, f"Expected exactly 1 sync_operation, found: {op_count}"
    finally:
        conn.close()

# ==============================================================================
# 4. Local_ID Duplicate Test (same patient_id + local_id -> COUNT = 1)
# ==============================================================================

def test_postgresql_local_id_duplicate_prevention(client):
    """Verify that a second operation with a different operation_id but the same local_id returns existing record."""
    p_token, p_id, _ = create_patient(client, "pg_localid_patient@example.com")
    headers = {"Authorization": f"Bearer {p_token}"}

    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=2)).isoformat()

    payload_1 = {
        "operation_id": "op-initial-uuid",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-shared-uuid",
        "payload": {
            "gameType": "Memory Match",
            "score": 100,
            "accuracy": 1.0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
    }
    resp1 = client.post("/api/v1/sync/game-sessions", json=payload_1, headers=headers)
    assert resp1.status_code == 200
    server_id_1 = resp1.json()["server_id"]

    # Operation 2: Different operation_id, but SAME local_id for same patient
    payload_2 = {
        "operation_id": "op-different-uuid-retry",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-shared-uuid",
        "payload": {
            "gameType": "Memory Match",
            "score": 100,
            "accuracy": 1.0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
    }
    resp2 = client.post("/api/v1/sync/game-sessions", json=payload_2, headers=headers)
    assert resp2.status_code == 200
    assert resp2.json()["status"] == "synced"
    assert resp2.json()["server_id"] == server_id_1

    # Verify directly via SQL in PostgreSQL that COUNT = 1
    conn = get_raw_pg_connection()
    try:
        cur = conn.cursor()
        cur.execute("""
            SELECT COUNT(*) 
            FROM game_sessions 
            WHERE patient_id = %s AND local_id = %s;
        """, (p_id, "loc-shared-uuid"))
        count = cur.fetchone()[0]
        assert count == 1, f"Expected exactly 1 record in PostgreSQL, found: {count}"
    finally:
        conn.close()

# ==============================================================================
# 5. Validation Tests Against PostgreSQL (rejections persist 0 rows in DB)
# ==============================================================================

def test_postgresql_validation_rejections(client):
    """Verify that all invalid inputs return HTTP 422 and result in ZERO records in PostgreSQL."""
    p_token, p_id, _ = create_patient(client, "pg_validation_patient@example.com")
    headers = {"Authorization": f"Bearer {p_token}"}

    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=2)).isoformat()

    valid_base = {
        "operation_id": "op-val-test",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-val-test",
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
    }

    test_cases = [
        ("invalid_game_type", dict(valid_base["payload"], gameType="Unapproved Casino Game")),
        ("negative_score", dict(valid_base["payload"], score=-10)),
        ("accuracy_greater_than_100", dict(valid_base["payload"], accuracy=120.0)),
        ("accuracy_negative", dict(valid_base["payload"], accuracy=-0.5)),
        ("negative_mistakes", dict(valid_base["payload"], mistakes=-2)),
        ("negative_response_time", dict(valid_base["payload"], responseTimeMs=-500.0)),
        ("difficulty_less_than_1", dict(valid_base["payload"], difficulty=0)),
        ("negative_hints", dict(valid_base["payload"], hintCount=-1)),
        ("inverted_timestamps", dict(valid_base["payload"], startedAt=completed_at, completedAt=started_at)),
    ]

    for label, bad_payload in test_cases:
        item = dict(valid_base, operation_id=f"op-{label}", local_id=f"loc-{label}", payload=bad_payload)
        resp = client.post("/api/v1/sync/game-sessions", json=item, headers=headers)
        assert resp.status_code == 422, f"Expected 422 for {label}, got: {resp.status_code}"

    # Missing operation_id or local_id
    resp_no_op = client.post("/api/v1/sync/game-sessions", json=dict(valid_base, operation_id=""), headers=headers)
    assert resp_no_op.status_code == 422

    resp_no_loc = client.post("/api/v1/sync/game-sessions", json=dict(valid_base, local_id=""), headers=headers)
    assert resp_no_loc.status_code == 422

    # Direct raw SQL check: ZERO game sessions must exist in PostgreSQL
    conn = get_raw_pg_connection()
    try:
        cur = conn.cursor()
        cur.execute("SELECT COUNT(*) FROM game_sessions WHERE patient_id = %s;", (p_id,))
        count = cur.fetchone()[0]
        assert count == 0, f"Expected 0 records in PostgreSQL after validation failures, found: {count}"
    finally:
        conn.close()

# ==============================================================================
# 6. Authorization Tests Against PostgreSQL (Caregiver RBAC & Patient Privacy)
# ==============================================================================

def test_postgresql_authorization_and_rbac(client):
    """Verify backend enforces role-based access control directly against PostgreSQL records."""
    pA_token, pA_id, _ = create_patient(client, "pg_patient_a@example.com", "Patient A")
    pB_token, pB_id, _ = create_patient(client, "pg_patient_b@example.com", "Patient B")
    cA_token, cA_id, _ = create_caregiver(client, "pg_caregiver_a@example.com", "Caregiver A")

    # Link Caregiver A to Patient A in PostgreSQL
    db = SessionLocal()
    assignment = PatientCaregiver(patient_id=pA_id, caregiver_id=cA_id, can_view=True, can_edit=True)
    db.add(assignment)
    db.commit()
    db.close()

    cA_headers = {"Authorization": f"Bearer {cA_token}"}
    pA_headers = {"Authorization": f"Bearer {pA_token}"}

    # 1. Caregiver A accessing linked Patient A -> Allowed (200)
    resp1 = client.get(f"/api/v1/caregivers/patients/{pA_id}/game-sessions", headers=cA_headers)
    assert resp1.status_code == 200

    # 2. Caregiver A accessing unlinked Patient B -> Forbidden (403)
    resp2 = client.get(f"/api/v1/caregivers/patients/{pB_id}/game-sessions", headers=cA_headers)
    assert resp2.status_code == 403

    # 3. Patient accessing caregiver endpoint -> Forbidden (403)
    resp3 = client.get("/api/v1/caregivers/patients", headers=pA_headers)
    assert resp3.status_code == 403

    # 4. Patient A attempting to sync data targeting Patient B's ID -> Forbidden (403)
    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=1)).isoformat()
    impersonate_item = {
        "operation_id": "op-impersonate-pg",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-impersonate-pg",
        "payload": {
            "gameType": "Pattern Recognition",
            "score": 100,
            "accuracy": 1.0,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
    }
    resp4 = client.post(
        f"/api/v1/sync/game-sessions?patient_id={pB_id}",
        json=impersonate_item,
        headers=pA_headers,
    )
    assert resp4.status_code == 403

# ==============================================================================
# 7. Caregiver Dashboard Endpoints Backed by PostgreSQL
# ==============================================================================

def test_caregiver_dashboard_data_and_empty_state_against_postgresql(client):
    """Verify caregiver dashboard endpoints read real PostgreSQL data and handle empty states."""
    p_token, p_id, _ = create_patient(client, "pg_dash_patient@example.com", "Dash Patient")
    c_token, c_id, _ = create_caregiver(client, "pg_dash_caregiver@example.com", "Dash Caregiver")

    # Link Caregiver to Patient
    db = SessionLocal()
    assignment = PatientCaregiver(patient_id=p_id, caregiver_id=c_id, can_view=True, can_edit=True)
    db.add(assignment)
    db.commit()
    db.close()

    c_headers = {"Authorization": f"Bearer {c_token}"}
    p_headers = {"Authorization": f"Bearer {p_token}"}

    # A. EMPTY STATE: 0 sessions synchronized
    summary_resp = client.get(f"/api/v1/caregivers/patients/{p_id}/summary", headers=c_headers)
    assert summary_resp.status_code == 200
    summary = summary_resp.json()
    assert summary["total_sessions"] == 0
    assert summary["recent_activity_status"] == "Awaiting Initial Activity"


    sessions_resp = client.get(f"/api/v1/caregivers/patients/{p_id}/game-sessions", headers=c_headers)
    assert sessions_resp.status_code == 200
    assert sessions_resp.json() == []

    # B. SYNC REAL PATTERN RECOGNITION SESSION
    started_at = datetime.now(timezone.utc).isoformat()
    completed_at = (datetime.now(timezone.utc) + timedelta(minutes=2)).isoformat()
    sync_item = {
        "operation_id": "op-dash-real-01",
        "entity_type": "GameSessions",
        "operation": "CREATE",
        "local_id": "loc-dash-real-01",
        "payload": {
            "gameType": "Pattern Recognition",
            "score": 110,
            "accuracy": 0.95,
            "mistakes": 1,
            "responseTimeMs": 1450.0,
            "difficulty": 1,
            "hintCount": 1,
            "startedAt": started_at,
            "completedAt": completed_at,
        },
    }
    sync_resp = client.post("/api/v1/sync/game-sessions", json=sync_item, headers=p_headers)
    assert sync_resp.status_code == 200

    # C. REAL DATA VERIFICATION: Caregiver retrieves live session
    live_sessions_resp = client.get(f"/api/v1/caregivers/patients/{p_id}/game-sessions", headers=c_headers)
    assert live_sessions_resp.status_code == 200
    live_sessions = live_sessions_resp.json()
    assert len(live_sessions) == 1
    session_data = live_sessions[0]
    assert session_data["game_type"] == "Pattern Recognition"
    assert session_data["score"] == 110
    assert session_data["accuracy"] == 0.95
    assert session_data["difficulty"] == 1
    assert session_data["mistakes"] == 1
    assert session_data["hint_count"] == 1
    assert session_data["response_time_ms"] == 1450.0

    # D. Summary reflects 1 completed session
    updated_summary = client.get(f"/api/v1/caregivers/patients/{p_id}/summary", headers=c_headers).json()
    assert updated_summary["total_sessions"] == 1
    assert updated_summary["recent_activity_status"] == "Active & Engaged"
