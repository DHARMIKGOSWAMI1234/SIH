"""Reminder and ReminderEvent models for daily schedules and routine events."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, Integer, DateTime, ForeignKey, UniqueConstraint
from backend.api.app.db.base import Base

class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    local_id = Column(String(36), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    reminder_type = Column(String(50), nullable=False)  # medication, hydration, routine, rest
    scheduled_time = Column(String(20), nullable=False)  # e.g. "09:00"
    enabled = Column(Boolean, nullable=False, default=True)
    version = Column(Integer, nullable=False, default=1)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    __table_args__ = (
        UniqueConstraint("patient_id", "local_id", name="uq_patient_reminder_local_id"),
    )

class ReminderEvent(Base):
    __tablename__ = "reminder_events"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    local_id = Column(String(36), nullable=False, index=True)
    reminder_id = Column(String(36), nullable=False)  # local or server reminder reference
    event_type = Column(String(50), nullable=False)  # acknowledged, snoozed, missed
    occurred_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    __table_args__ = (
        UniqueConstraint("patient_id", "local_id", name="uq_patient_reminder_event_local_id"),
    )
