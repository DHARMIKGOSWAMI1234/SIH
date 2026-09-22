"""Export all SQLAlchemy models for Alembic and application discovery."""
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder, ReminderEvent
from backend.api.app.models.routine import Routine
from backend.api.app.models.sync_operation import SyncOperation

__all__ = [
    "User",
    "UserRole",
    "Patient",
    "Caregiver",
    "PatientCaregiver",
    "Memory",
    "GameSession",
    "Reminder",
    "ReminderEvent",
    "Routine",
    "SyncOperation",
]
