"""Authentication API routes."""
from fastapi import APIRouter, Depends, status
from sqlalchemy.orm import Session
from backend.api.app.db.session import get_db
from backend.api.app.schemas.auth import (
    UserRegisterRequest,
    UserLoginRequest,
    TokenResponse,
    UserResponse,
    PatientProfileUpdateRequest,
)
from fastapi import HTTPException
from backend.api.app.models.user import UserRole
from backend.api.app.services.auth_service import AuthService
from backend.api.app.auth.dependencies import get_current_user
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
def register(req: UserRegisterRequest, db: Session = Depends(get_db)):
    """Register a new user account with role-based profile creation."""
    service = AuthService(db)
    _, token_resp = service.register(req)
    return token_resp

@router.post("/login", response_model=TokenResponse)
def login(req: UserLoginRequest, db: Session = Depends(get_db)):
    """Authenticate credentials and return JWT access token."""
    service = AuthService(db)
    return service.login(req)

@router.get("/me", response_model=UserResponse)
def get_me(current_user: User = Depends(get_current_user), db: Session = Depends(get_db)):
    """Get current authenticated user identity and associated profile IDs."""
    patient_id = None
    caregiver_id = None
    alias = None
    pref_lang = None
    font_scale = None
    contrast = None

    patient = db.query(Patient).filter(Patient.user_id == current_user.id).first()
    if patient:
        patient_id = patient.id
        alias = patient.anonymous_alias
        pref_lang = patient.preferred_language
        font_scale = patient.font_scale_preference
        contrast = patient.contrast_preference

    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if caregiver:
        caregiver_id = caregiver.id

    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role,
        created_at=current_user.created_at,
        patient_id=patient_id,
        caregiver_id=caregiver_id,
        anonymous_alias=alias,
        preferred_language=pref_lang,
        font_scale_preference=font_scale,
        contrast_preference=contrast,
    )

@router.put("/patient-profile", response_model=UserResponse)
def update_patient_profile(
    req: PatientProfileUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Update patient preferences for the authenticated patient account."""
    if current_user.role != UserRole.PATIENT.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only patient accounts can update patient profile preferences.",
        )

    patient = db.query(Patient).filter(Patient.user_id == current_user.id).first()
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found.",
        )

    if req.anonymous_alias is not None:
        patient.anonymous_alias = req.anonymous_alias
    if req.preferred_language is not None:
        patient.preferred_language = req.preferred_language
    if req.font_scale_preference is not None:
        patient.font_scale_preference = req.font_scale_preference
    if req.contrast_preference is not None:
        patient.contrast_preference = req.contrast_preference

    db.commit()
    db.refresh(patient)

    return UserResponse(
        id=current_user.id,
        email=current_user.email,
        full_name=current_user.full_name,
        role=current_user.role,
        created_at=current_user.created_at,
        patient_id=patient.id,
        caregiver_id=None,
        anonymous_alias=patient.anonymous_alias,
        preferred_language=patient.preferred_language,
        font_scale_preference=patient.font_scale_preference,
        contrast_preference=patient.contrast_preference,
    )
