"""Patient-Caregiver relationship model for access authorization."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Boolean, DateTime, ForeignKey, UniqueConstraint
from backend.api.app.db.base import Base

class PatientCaregiver(Base):
    __tablename__ = "patient_caregivers"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    caregiver_id = Column(String(36), ForeignKey("caregivers.id", ondelete="CASCADE"), nullable=False, index=True)
    can_view = Column(Boolean, nullable=False, default=True)
    can_edit = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)

    __table_args__ = (
        UniqueConstraint("patient_id", "caregiver_id", name="uq_patient_caregiver"),
    )
