"""Tests for database entities and relationships."""
import pytest
from backend.api.app.db.base import Base
from backend.api.app.db.session import engine, SessionLocal
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder, ReminderEvent
from backend.api.app.models.routine import Routine
from datetime import datetime, timezone

@pytest.fixture(autouse=True)
def setup_db():
    db = SessionLocal()
    try:
        db.query(ReminderEvent).delete()
        db.query(Reminder).delete()
        db.query(Routine).delete()
        db.query(GameSession).delete()
        db.query(Memory).delete()
        db.query(PatientCaregiver).delete()
        db.query(Patient).delete()
        db.query(Caregiver).delete()
        db.query(User).delete()
        db.commit()
    finally:
        db.close()
    yield

def test_database_entity_creation_and_relations():
    db = SessionLocal()
    try:
        # Create Patient User
        u_patient = User(
            email="p1@example.com",
            password_hash="hash1",
            full_name="Patient One",
            role=UserRole.PATIENT.value,
        )
        db.add(u_patient)
        db.commit()

        p = Patient(user_id=u_patient.id, anonymous_alias="P-01")
        db.add(p)
        db.commit()

        # Create Caregiver User
        u_caregiver = User(
            email="c1@example.com",
            password_hash="hash2",
            full_name="Caregiver One",
            role=UserRole.CAREGIVER.value,
        )
        db.add(u_caregiver)
        db.commit()

        c = Caregiver(user_id=u_caregiver.id, full_name="Caregiver One")
        db.add(c)
        db.commit()

        # Assign Caregiver to Patient
        pc = PatientCaregiver(patient_id=p.id, caregiver_id=c.id, can_view=True, can_edit=True)
        db.add(pc)
        db.commit()

        # Create Memory
        mem = Memory(
            patient_id=p.id,
            local_id="loc-mem-01",
            title="Bihu Festival",
            description="Bihu traditional celebration",
        )
        db.add(mem)

        # Create GameSession
        gs = GameSession(
            patient_id=p.id,
            local_id="loc-gs-01",
            game_type="Memory Match",
            score=100,
            accuracy=1.0,
            started_at=datetime.now(timezone.utc),
            completed_at=datetime.now(timezone.utc),
        )
        db.add(gs)

        # Create Reminder
        rem = Reminder(
            patient_id=p.id,
            local_id="loc-rem-01",
            title="Drink Water",
            reminder_type="hydration",
            scheduled_time="10:00",
        )
        db.add(rem)

        # Create Routine
        rot = Routine(
            patient_id=p.id,
            local_id="loc-rot-01",
            title="Morning Routine",
            steps_json='["Wake up", "Brush teeth", "Drink water"]',
            preferred_time="08:00 AM",
        )
        db.add(rot)
        db.commit()

        assert p.id is not None
        assert c.id is not None
        assert mem.id is not None
        assert gs.id is not None
        assert rem.id is not None
        assert rot.id is not None
    finally:
        db.close()
