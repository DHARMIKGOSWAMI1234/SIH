"""Patient entity model."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Float, DateTime, ForeignKey
from backend.api.app.db.base import Base

class Patient(Base):
    __tablename__ = "patients"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    anonymous_alias = Column(String(100), nullable=False, default="Patient")
    preferred_language = Column(String(10), nullable=False, default="en")
    font_scale_preference = Column(Float, nullable=False, default=1.0)
    contrast_preference = Column(String(20), nullable=False, default="standard")
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)
