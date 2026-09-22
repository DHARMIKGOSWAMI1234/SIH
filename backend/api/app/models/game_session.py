"""GameSession entity model. Strictly non-clinical cognitive activity performance."""
import uuid
from datetime import datetime, timezone
from sqlalchemy import Column, String, Integer, Float, DateTime, ForeignKey, UniqueConstraint
from backend.api.app.db.base import Base

class GameSession(Base):
    __tablename__ = "game_sessions"

    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    patient_id = Column(String(36), ForeignKey("patients.id", ondelete="CASCADE"), nullable=False, index=True)
    local_id = Column(String(36), nullable=False, index=True)
    game_type = Column(String(100), nullable=False)  # Memory Match, Pattern Recognition, Daily Routine Recall
    score = Column(Integer, nullable=False)
    accuracy = Column(Float, nullable=False)
    mistakes = Column(Integer, nullable=False, default=0)
    response_time_ms = Column(Float, nullable=False, default=0.0)
    difficulty = Column(Integer, nullable=False, default=1)
    hint_count = Column(Integer, nullable=False, default=0)
    started_at = Column(DateTime, nullable=False)
    completed_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), nullable=False)
    updated_at = Column(DateTime, default=lambda: datetime.now(timezone.utc), onupdate=lambda: datetime.now(timezone.utc), nullable=False)

    __table_args__ = (
        UniqueConstraint("patient_id", "local_id", name="uq_patient_game_session_local_id"),
    )
