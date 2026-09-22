"""Caregiver entity model."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey
from backend.api.app.db.base import Base

class Caregiver(Base):
    __tablename__ = "caregivers"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    full_name = Column(String(255), nullable=False)
    phone_number = Column(String(50), nullable=True)
    relationship_to_patient = Column(String(100), nullable=False, default="Family Caregiver")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)
