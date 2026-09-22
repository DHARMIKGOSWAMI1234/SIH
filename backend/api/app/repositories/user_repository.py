"""Repositories for User, Patient, Caregiver, and SyncOperation entities."""
from typing import Optional, List
from sqlalchemy.orm import Session
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.models.sync_operation import SyncOperation

class UserRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, user_id: str) -> Optional[User]:
        return self.db.query(User).filter(User.id == user_id).first()

    def get_by_email(self, email: str) -> Optional[User]:
        return self.db.query(User).filter(User.email == email.lower().strip()).first()

    def create(self, user: User) -> User:
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

class PatientRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_id(self, patient_id: str) -> Optional[Patient]:
        return self.db.query(Patient).filter(Patient.id == patient_id).first()

    def get_by_user_id(self, user_id: str) -> Optional[Patient]:
        return self.db.query(Patient).filter(Patient.user_id == user_id).first()

    def create(self, patient: Patient) -> Patient:
        self.db.add(patient)
        self.db.commit()
        self.db.refresh(patient)
        return patient

    def get_patients_for_caregiver(self, caregiver_id: str) -> List[Patient]:
        return (
            self.db.query(Patient)
            .join(PatientCaregiver, PatientCaregiver.patient_id == Patient.id)
            .filter(PatientCaregiver.caregiver_id == caregiver_id, PatientCaregiver.can_view == True)
            .all()
        )

    def assign_caregiver(self, patient_id: str, caregiver_id: str, can_edit: bool = False) -> PatientCaregiver:
        existing = (
            self.db.query(PatientCaregiver)
            .filter(
                PatientCaregiver.patient_id == patient_id,
                PatientCaregiver.caregiver_id == caregiver_id,
            )
            .first()
        )
        if existing:
            existing.can_edit = can_edit
            self.db.commit()
            return existing

        assignment = PatientCaregiver(
            patient_id=patient_id,
            caregiver_id=caregiver_id,
            can_view=True,
            can_edit=can_edit,
        )
        self.db.add(assignment)
        self.db.commit()
        self.db.refresh(assignment)
        return assignment

class SyncRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_by_operation_id(self, operation_id: str) -> Optional[SyncOperation]:
        return self.db.query(SyncOperation).filter(SyncOperation.operation_id == operation_id).first()

    def record_operation(
        self,
        operation_id: str,
        patient_id: str,
        entity_type: str,
        operation: str,
        local_id: str,
        server_id: Optional[str] = None,
        status: str = "synced",
        client_updated_at = None,
    ) -> SyncOperation:
        record = SyncOperation(
            operation_id=operation_id,
            patient_id=patient_id,
            entity_type=entity_type,
            operation=operation,
            local_id=local_id,
            server_id=server_id,
            status=status,
            client_updated_at=client_updated_at,
        )
        self.db.add(record)
        self.db.commit()
        self.db.refresh(record)
        return record
