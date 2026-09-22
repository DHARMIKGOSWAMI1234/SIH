"""Caregiver service providing authorized access to patient data, metrics, and history."""
from typing import List, Dict, Any, Optional
from sqlalchemy.orm import Session
from backend.api.app.repositories.user_repository import PatientRepository
from backend.api.app.repositories.entity_repository import (
    MemoryRepository,
    GameRepository,
    ReminderRepository,
    RoutineRepository,
)
from fastapi import HTTPException, status
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.patient import Patient
from backend.api.app.models.game_session import GameSession
from backend.api.app.models.memory import Memory
from backend.api.app.models.reminder import Reminder, ReminderEvent
from backend.api.app.models.routine import Routine
from backend.api.app.core.config import settings

class CaregiverService:
    def __init__(self, db: Session):
        self.db = db
        self.patient_repo = PatientRepository(db)
        self.memory_repo = MemoryRepository(db)
        self.game_repo = GameRepository(db)
        self.reminder_repo = ReminderRepository(db)
        self.routine_repo = RoutineRepository(db)

    def get_authorized_patients(self, caregiver_id: str) -> List[Patient]:
        """Return all patients assigned to this caregiver."""
        patients = self.patient_repo.get_patients_for_caregiver(caregiver_id)
        # Constraint 2: Strictly development/demo scoped automatic caregiver linking
        if settings.ENVIRONMENT == "development":
            demo_patient = self.patient_repo.get_by_id("local-patient-demo")
            if demo_patient and not any(p.id == demo_patient.id for p in patients):
                self.patient_repo.assign_caregiver(demo_patient.id, caregiver_id, can_edit=False)
                patients.append(demo_patient)
        return patients

    def get_patient_summary(self, patient_id: str) -> Dict[str, Any]:
        """Aggregated, non-clinical activity summary."""
        sessions = self.game_repo.list_by_patient(patient_id, limit=50)
        memories = self.memory_repo.list_by_patient(patient_id)
        reminders = self.reminder_repo.list_by_patient(patient_id)
        routines = self.routine_repo.list_by_patient(patient_id)

        total_sessions = len(sessions)
        avg_accuracy = (
            sum(s.accuracy for s in sessions) / total_sessions
            if total_sessions > 0
            else 0.0
        )

        return {
            "patient_id": patient_id,
            "total_sessions": total_sessions,
            "average_accuracy": round(avg_accuracy, 1),
            "memories_count": len(memories),
            "active_reminders_count": len([r for r in reminders if r.enabled]),
            "routines_count": len(routines),
            "recent_activity_status": "Active & Engaged" if total_sessions > 0 else "Awaiting Initial Activity",
        }

    def get_game_sessions(self, patient_id: str, limit: int = 20, offset: int = 0) -> List[GameSession]:
        return self.game_repo.list_by_patient(patient_id, limit=limit, offset=offset)

    def get_memories(self, patient_id: str, category: Optional[str] = None) -> List[Memory]:
        return self.memory_repo.list_by_patient(patient_id, category=category)

    def get_reminders(self, patient_id: str) -> List[Reminder]:
        return self.reminder_repo.list_by_patient(patient_id)

    def get_routines(self, patient_id: str) -> List[Routine]:
        return self.routine_repo.list_by_patient(patient_id)

    def link_patient(
        self,
        caregiver_id: str,
        patient_email: str,
        relationship_type: str = "Family Caregiver",
    ) -> Patient:
        """Link an authenticated caregiver to a patient by email with privacy preservation."""
        clean_email = patient_email.lower().strip()
        user = (
            self.db.query(User)
            .filter(User.email == clean_email, User.role == UserRole.PATIENT.value)
            .first()
        )
        patient = None
        if user:
            patient = self.patient_repo.get_by_user_id(user.id)
        elif settings.ENVIRONMENT == "development" and clean_email in ("local-patient-demo", "local-patient-demo@smriti.care", "demo@smriti.care"):
            patient = self.patient_repo.get_by_id("local-patient-demo")

        if not patient:
            # Generic error to avoid exposing account existence
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Unable to link patient with the provided information.",
            )

        # Check if already linked
        existing_link = (
            self.db.query(PatientCaregiver)
            .filter(
                PatientCaregiver.caregiver_id == caregiver_id,
                PatientCaregiver.patient_id == patient.id,
            )
            .first()
        )
        if not existing_link:
            new_link = PatientCaregiver(
                caregiver_id=caregiver_id,
                patient_id=patient.id,
                can_view=True,
                can_edit=False,
            )
            self.db.add(new_link)
            self.db.commit()

        return patient
