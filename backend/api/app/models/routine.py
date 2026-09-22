"""Routine model for daily sequence guidance."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, Boolean, Integer, DateTime, ForeignKey, UniqueConstraint
from backend.api.app.db.base import Base

class Routine(Base):
    __tablename__ = "routines"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    local_id = Column(String(36), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    steps_json = Column(Text, nullable=False)  # JSON array of steps
    preferred_time = Column(String(50), nullable=False)  # e.g. "08:00 AM"
    enabled = Column(Boolean, nullable=False, default=True)
    version = Column(Integer, nullable=False, default=1)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    __table_args__ = (
        UniqueConstraint("patient_id", "local_id", name="uq_patient_routine_local_id"),
    )
