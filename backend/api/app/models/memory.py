"""Memory entity model for Personal Memory Bank."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Text, Boolean, Integer, DateTime, ForeignKey, UniqueConstraint
from backend.api.app.db.base import Base

class Memory(Base):
    __tablename__ = "memories"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    local_id = Column(String(36), nullable=False, index=True)
    title = Column(String(255), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(String(50), nullable=False, default="other")
    relationship = Column(String(100), nullable=True)
    person_name = Column(String(255), nullable=True)
    location = Column(String(255), nullable=True)
    event_date = Column(DateTime, nullable=True)
    image_path = Column(String(500), nullable=True)
    audio_path = Column(String(500), nullable=True)
    media_uri = Column(String(500), nullable=True)
    language = Column(String(10), nullable=False, default="en")
    region = Column(String(100), nullable=True)
    tags = Column(String(500), nullable=True)
    source = Column(String(50), nullable=False, default="personal")
    is_favorite = Column(Boolean, nullable=False, default=False)
    is_archived = Column(Boolean, nullable=False, default=False)
    version = Column(Integer, nullable=False, default=1)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    __table_args__ = (
        UniqueConstraint("patient_id", "local_id", name="uq_patient_memory_local_id"),
    )
