"""Caregiver API endpoints for authorized patient monitoring."""
from typing import List, Dict, Any, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from backend.api.app.db.session import get_db
from backend.api.app.schemas.patient import PatientResponse
from backend.api.app.schemas.caregiver import LinkPatientRequest
from backend.api.app.schemas.game import GameSessionResponse
from backend.api.app.schemas.memory import MemoryResponse
from backend.api.app.schemas.reminder import ReminderResponse
from backend.api.app.schemas.routine import RoutineResponse
from backend.api.app.schemas.pairing import PairingCreateResponse, PairingStatusResponse
from backend.api.app.services.caregiver_service import CaregiverService
from backend.api.app.services.pairing_service import PairingService
from backend.api.app.auth.dependencies import (
    get_current_user,
    get_current_caregiver,
    verify_patient_access,
    require_roles,
)
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.caregiver import Caregiver

router = APIRouter(prefix="/caregivers", tags=["Caregiver Dashboard"])

@router.post("/pairing/create", response_model=PairingCreateResponse, status_code=status.HTTP_201_CREATED)
def create_pairing_request(
    current_caregiver: Caregiver = Depends(get_current_caregiver),
    db: Session = Depends(get_db),
):
    """Generate a 4-digit code and secure QR pairing request valid for 10 minutes."""
    service = PairingService(db)
    req, caregiver = service.create_pairing_request(current_caregiver.id)
    return PairingCreateResponse(
        request_id=req.id,
        short_code=req.short_code,
        pairing_token=req.pairing_token,
        expires_at=req.expires_at.isoformat(),
        expires_in_seconds=600,
        qr_payload=req.qr_payload,
        caregiver_name=caregiver.full_name,
    )

@router.get("/pairing/{request_id}/status", response_model=PairingStatusResponse)
def get_pairing_status(
    request_id: str,
    current_caregiver: Caregiver = Depends(get_current_caregiver),
    db: Session = Depends(get_db),
):
    """Check pairing completion status for live dashboard updating."""
    service = PairingService(db)
    return service.get_pairing_status(request_id, current_caregiver.id)

@router.post("/link-patient", response_model=PatientResponse, status_code=status.HTTP_200_OK)
def link_patient(
    req: LinkPatientRequest,
    current_caregiver: Caregiver = Depends(get_current_caregiver),
    db: Session = Depends(get_db),
):
    """Link authenticated caregiver to a patient.
    
    Note: In production deployments, this should be governed by an explicit patient
    invitation/consent handshake rather than direct email lookup.
    """
    service = CaregiverService(db)
    return service.link_patient(
        caregiver_id=current_caregiver.id,
        patient_email=req.patient_email,
        relationship_type=req.relationship_type or "Family Caregiver",
    )


@router.get("/patients", response_model=List[PatientResponse])
def get_authorized_patients(
    current_caregiver: Caregiver = Depends(get_current_caregiver),
    db: Session = Depends(get_db),
):
    """Retrieve list of all patients assigned to this caregiver."""
    service = CaregiverService(db)
    return service.get_authorized_patients(current_caregiver.id)

@router.get("/patients/{patient_id}/summary", response_model=Dict[str, Any])
def get_patient_summary(
    patient_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve aggregated engagement metrics for an authorized patient."""
    verify_patient_access(patient_id, current_user, db)
    service = CaregiverService(db)
    return service.get_patient_summary(patient_id)

@router.get("/patients/{patient_id}/game-sessions", response_model=List[GameSessionResponse])
def get_game_sessions(
    patient_id: str,
    limit: int = Query(20, ge=1, le=100),
    offset: int = Query(0, ge=0),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve paginated activity session history for an authorized patient."""
    verify_patient_access(patient_id, current_user, db)
    service = CaregiverService(db)
    return service.get_game_sessions(patient_id, limit=limit, offset=offset)

@router.get("/patients/{patient_id}/memories", response_model=List[MemoryResponse])
def get_patient_memories(
    patient_id: str,
    category: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve personal memories for an authorized patient."""
    verify_patient_access(patient_id, current_user, db)
    service = CaregiverService(db)
    return service.get_memories(patient_id, category=category)

@router.get("/patients/{patient_id}/reminders", response_model=List[ReminderResponse])
def get_patient_reminders(
    patient_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve scheduled reminders for an authorized patient."""
    verify_patient_access(patient_id, current_user, db)
    service = CaregiverService(db)
    return service.get_reminders(patient_id)

@router.get("/patients/{patient_id}/routines", response_model=List[RoutineResponse])
def get_patient_routines(
    patient_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve daily routines for an authorized patient."""
    verify_patient_access(patient_id, current_user, db)
    service = CaregiverService(db)
    return service.get_routines(patient_id)
