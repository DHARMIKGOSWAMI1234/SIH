"""User model for authentication and identity."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, Enum
import enum
from backend.api.app.db.base import Base

class UserRole(str, enum.Enum):
    PATIENT = "PATIENT"
    CAREGIVER = "CAREGIVER"
    ADMIN = "ADMIN"

class User(Base):
    __tablename__ = "users"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False, default=UserRole.PATIENT.value)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)
