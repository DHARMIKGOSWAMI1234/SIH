"""Repositories for Memories, GameSessions, Reminders, and Routines."""
from typing import Optional, List
from datetime import datetime, timezone
from sqlalchemy.orm import Session
from backend.api.app.models.memory import Memory
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder, ReminderEvent
from backend.api.app.models.routine import Routine

class MemoryRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, memory_id: str) -> Optional[Memory]:
        return self.db.query(Memory).filter(Memory.id == memory_id).first()

    def get_by_local_id(self, patient_id: str, local_id: str) -> Optional[Memory]:
        return self.db.query(Memory).filter(
            Memory.patient_id == patient_id,
            Memory.local_id == local_id,
        ).first()

    def list_by_patient(
        self,
        patient_id: str,
        category: Optional[str] = None,
        is_favorite: Optional[bool] = None,
        include_archived: bool = False,
    ) -> List[Memory]:
        query = self.db.query(Memory).filter(Memory.patient_id == patient_id)
        if not include_archived:
            query = query.filter(Memory.is_archived == False)
        if category and category != "all":
            query = query.filter(Memory.category == category)
        if is_favorite is not None:
            query = query.filter(Memory.is_favorite == is_favorite)
        return query.order_by(Memory.created_at.desc()).all()

    def create(self, memory: Memory) -> Memory:
        self.db.add(memory)
        self.db.commit()
        self.db.refresh(memory)
        return memory

    def update(self, memory: Memory, updated_at: Optional[datetime] = None) -> Memory:
        memory.updated_at = updated_at or datetime.now(timezone.utc)
        memory.version += 1
        self.db.commit()
        self.db.refresh(memory)
        return memory

    def delete(self, memory: Memory) -> None:
        self.db.delete(memory)
        self.db.commit()

class GameRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_local_id(self, patient_id: str, local_id: str) -> Optional[GameSession]:
        return self.db.query(GameSession).filter(
            GameSession.patient_id == patient_id,
            GameSession.local_id == local_id,
        ).first()

    def list_by_patient(
        self,
        patient_id: str,
        limit: int = 20,
        offset: int = 0,
    ) -> List[GameSession]:
        return (
            self.db.query(GameSession)
            .filter(GameSession.patient_id == patient_id)
            .order_by(GameSession.completed_at.desc())
            .offset(offset)
            .limit(limit)
            .all()
        )

    def count_by_patient(self, patient_id: str) -> int:
        return self.db.query(GameSession).filter(GameSession.patient_id == patient_id).count()

    def create(self, session: GameSession) -> GameSession:
        self.db.add(session)
        self.db.commit()
        self.db.refresh(session)
        return session

class ReminderRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_local_id(self, patient_id: str, local_id: str) -> Optional[Reminder]:
        return self.db.query(Reminder).filter(
            Reminder.patient_id == patient_id,
            Reminder.local_id == local_id,
        ).first()

    def list_by_patient(self, patient_id: str) -> List[Reminder]:
        return self.db.query(Reminder).filter(Reminder.patient_id == patient_id).order_by(Reminder.scheduled_time.asc()).all()

    def create(self, reminder: Reminder) -> Reminder:
        self.db.add(reminder)
        self.db.commit()
        self.db.refresh(reminder)
        return reminder

    def update(self, reminder: Reminder) -> Reminder:
        reminder.updated_at = datetime.now(timezone.utc)
        reminder.version += 1
        self.db.commit()
        self.db.refresh(reminder)
        return reminder

    def delete(self, reminder: Reminder) -> None:
        self.db.delete(reminder)
        self.db.commit()

    def record_event(self, event: ReminderEvent) -> ReminderEvent:
        self.db.add(event)
        self.db.commit()
        self.db.refresh(event)
        return event

    def list_events_by_patient(self, patient_id: str, limit: int = 20) -> List[ReminderEvent]:
        return (
            self.db.query(ReminderEvent)
            .filter(ReminderEvent.patient_id == patient_id)
            .order_by(ReminderEvent.occurred_at.desc())
            .limit(limit)
            .all()
        )

class RoutineRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_local_id(self, patient_id: str, local_id: str) -> Optional[Routine]:
        return self.db.query(Routine).filter(
            Routine.patient_id == patient_id,
            Routine.local_id == local_id,
        ).first()

    def list_by_patient(self, patient_id: str) -> List[Routine]:
        return self.db.query(Routine).filter(Routine.patient_id == patient_id).all()

    def create(self, routine: Routine) -> Routine:
        self.db.add(routine)
        self.db.commit()
        self.db.refresh(routine)
        return routine

    def update(self, routine: Routine) -> Routine:
        routine.updated_at = datetime.now(timezone.utc)
        routine.version += 1
        self.db.commit()
        self.db.refresh(routine)
        return routine

    def delete(self, routine: Routine) -> None:
        self.db.delete(routine)
        self.db.commit()
