"""Patient-side Pairing & Caregiver Connection API Endpoints."""
from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from backend.api.app.db.session import get_db
from backend.api.app.schemas.pairing import (
    PairingValidateRequest,
    PairingValidateResponse,
    PairingConfirmRequest,
    PairingConfirmResponse,
    PatientCaregiverStatusResponse,
)
from backend.api.app.services.pairing_service import PairingService
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.auth.dependencies import get_current_user_optional, get_current_user

router = APIRouter(prefix="/patient", tags=["Patient Pairing"])

@router.post("/pairing/validate", response_model=PairingValidateResponse)
def validate_pairing_request(
    req: PairingValidateRequest,
    db: Session = Depends(get_db),
):
    """Validate a 4-digit code or QR token and return caregiver details for elderly confirmation."""
    if not req.short_code and not req.pairing_token and not req.qr_payload:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Please provide a 4-digit code or QR code token.",
        )

    service = PairingService(db)
    pairing_req, caregiver = service.validate_pairing(
        short_code=req.short_code,
        pairing_token=req.pairing_token,
        qr_payload=req.qr_payload,
    )

    return PairingValidateResponse(
        valid=True,
        request_id=pairing_req.id,
        pairing_token=pairing_req.pairing_token,
        caregiver_id=caregiver.id,
        caregiver_name=caregiver.full_name,
        relationship_type=caregiver.relationship_to_patient,
        expires_at=pairing_req.expires_at.isoformat(),
    )

@router.post("/pairing/confirm", response_model=PairingConfirmResponse)
def confirm_pairing_request(
    req: PairingConfirmRequest,
    current_user: Optional[User] = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    """Confirm caregiver connection upon patient acceptance."""
    service = PairingService(db)

    # Determine patient_id from current session or explicit payload
    patient_id = req.patient_id
    if current_user:
        patient = db.query(Patient).filter(Patient.user_id == current_user.id).first()
        if patient:
            patient_id = patient.id

    if not patient_id:
        # Fallback to local demo patient if running in development mode
        patient_id = "local-patient-demo"

    caregiver, patient = service.confirm_pairing(
        pairing_token=req.pairing_token,
        patient_id=patient_id,
    )

    return PairingConfirmResponse(
        success=True,
        caregiver_name=caregiver.full_name,
        patient_name=patient.anonymous_alias,
        connected_at=caregiver.updated_at.isoformat() if caregiver.updated_at else "",
    )

@router.get("/caregiver", response_model=PatientCaregiverStatusResponse)
def get_connected_caregiver(
    patient_id: Optional[str] = None,
    current_user: Optional[User] = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    """Retrieve currently linked caregiver for display in patient profile."""
    resolved_patient_id = patient_id
    if current_user:
        patient = db.query(Patient).filter(Patient.user_id == current_user.id).first()
        if patient:
            resolved_patient_id = patient.id

    if not resolved_patient_id:
        resolved_patient_id = "local-patient-demo"

    service = PairingService(db)
    info = service.get_patient_caregiver(resolved_patient_id)
    if not info:
        return PatientCaregiverStatusResponse(connected=False)

    return PatientCaregiverStatusResponse(
        connected=True,
        caregiver_id=info["caregiver_id"],
        caregiver_name=info["caregiver_name"],
        relationship=info["relationship"],
        linked_at=info["linked_at"],
    )

@router.post("/caregiver/disconnect", response_model=PatientCaregiverStatusResponse)
def disconnect_caregiver(
    patient_id: Optional[str] = None,
    current_user: Optional[User] = Depends(get_current_user_optional),
    db: Session = Depends(get_db),
):
    """Safely disconnect caregiver without removing patient local data."""
    resolved_patient_id = patient_id
    if current_user:
        patient = db.query(Patient).filter(Patient.user_id == current_user.id).first()
        if patient:
            resolved_patient_id = patient.id

    if not resolved_patient_id:
        resolved_patient_id = "local-patient-demo"

    links = db.query(PatientCaregiver).filter(PatientCaregiver.patient_id == resolved_patient_id).all()
    for link in links:
        db.delete(link)
    db.commit()

    return PatientCaregiverStatusResponse(connected=False)
