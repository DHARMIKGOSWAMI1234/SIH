"""Caregiver-Patient Pairing Request Model for safe elderly onboarding."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, DateTime, ForeignKey, Index
from backend.api.app.db.base import Base

class CaregiverPairingRequest(Base):
    __tablename__ = "caregiver_pairing_requests"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    caregiver_id = Column(String(36), ForeignKey("caregivers.id", ondelete="CASCADE"), nullable=False, index=True)
    short_code = Column(String(4), nullable=False, index=True)
    pairing_token = Column(String(64), nullable=False, unique=True, index=True)
    qr_payload = Column(String(255), nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    expires_at = Column(DateTime, nullable=False, index=True)
    status = Column(String(20), nullable=False, default="PENDING", index=True)  # PENDING, USED, EXPIRED, CANCELLED
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="SET NULL"), nullable=True)
    used_at = Column(DateTime, nullable=True)

    __table_args__ = (
        Index("ix_pairing_code_status", "short_code", "status"),
    )
