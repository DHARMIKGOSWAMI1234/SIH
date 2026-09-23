"""Authentication and authorization dependencies for FastAPI."""
from typing import List, Optional
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from backend.api.app.db.session import get_db
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.models.patient_caregiver import PatientCaregiver
from backend.api.app.auth.security import decode_access_token
from backend.api.app.core.config import settings

security_scheme = HTTPBearer(auto_error=False)

KNOWN_OFFLINE_DEMO_PATIENTS = {"local-patient-demo", "local-patient-demo-2"}

async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: Session = Depends(get_db),
) -> Optional[User]:
    """Optionally verify JWT or offline token; returns None if not authenticated."""
    if not credentials:
        return None
    try:
        return await get_current_user(credentials, db)
    except HTTPException:
        return None

async def get_current_user(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_scheme),
    db: Session = Depends(get_db),
) -> User:
    """Verify JWT access token or known demo offline token and return the current User."""
    if not credentials:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )

    # Constraint 1: Offline tokens must only authenticate an existing known demo/local patient
    if credentials.credentials.startswith("offline-"):
        if settings.ENVIRONMENT == "development":
            offline_id = credentials.credentials[len("offline-"):]
            if offline_id in KNOWN_OFFLINE_DEMO_PATIENTS:
                user = db.query(User).filter(User.id == offline_id, User.role == UserRole.PATIENT.value).first()
                if user:
                    return user
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or unrecognized offline patient credential",
            headers={"WWW-Authenticate": "Bearer"},
        )

    payload = decode_access_token(credentials.credentials)
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user_id = payload.get("sub")
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Malformed authentication token",
            headers={"WWW-Authenticate": "Bearer"},
        )

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found",
            headers={"WWW-Authenticate": "Bearer"},
        )

    return user

def require_roles(allowed_roles: List[str]):
    """Role-aware authorization dependency factory."""
    async def role_checker(current_user: User = Depends(get_current_user)) -> User:
        if current_user.role not in allowed_roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Operation not permitted for role '{current_user.role}'. Required: {allowed_roles}",
            )
        return current_user
    return role_checker

async def get_current_patient(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Patient:
    """Retrieve the patient profile for the current authenticated user."""
    if current_user.role != UserRole.PATIENT.value and current_user.role != UserRole.ADMIN.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Operation requires PATIENT role, but user has '{current_user.role}'",
        )
    patient = db.query(Patient).filter(Patient.user_id == current_user.id).first()
    if not patient:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Patient profile not found for this user account",
        )
    return patient

async def get_current_caregiver(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
) -> Caregiver:
    """Retrieve the caregiver profile for the current authenticated user."""
    if current_user.role != UserRole.CAREGIVER.value and current_user.role != UserRole.ADMIN.value:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Operation requires CAREGIVER role, but user has '{current_user.role}'",
        )
    caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
    if not caregiver:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Caregiver profile not found for this user account",
        )
    return caregiver

def verify_patient_access(
    patient_id: str,
    current_user: User,
    db: Session,
    require_edit: bool = False,
) -> Patient:
    """Verify that current_user has authorized access to patient_id.
    
    Admins can access any patient.
    Patients can only access their own patient record.
    Caregivers can only access patients assigned to them via PatientCaregiver.
    """
    if current_user.role == UserRole.ADMIN.value:
        patient = db.query(Patient).filter(Patient.id == patient_id).first()
        if not patient:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")
        return patient

    if current_user.role == UserRole.PATIENT.value:
        patient = db.query(Patient).filter(Patient.id == patient_id, Patient.user_id == current_user.id).first()
        if not patient:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Unauthorized access to patient record")
        return patient

    if current_user.role == UserRole.CAREGIVER.value:
        caregiver = db.query(Caregiver).filter(Caregiver.user_id == current_user.id).first()
        if not caregiver:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Caregiver profile not configured")

        assignment = db.query(PatientCaregiver).filter(
            PatientCaregiver.patient_id == patient_id,
            PatientCaregiver.caregiver_id == caregiver.id,
        ).first()

        if not assignment or not assignment.can_view:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access to patient not authorized")

        if require_edit and not assignment.can_edit:
            raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Edit permission not granted for this patient")

        patient = db.query(Patient).filter(Patient.id == patient_id).first()
        if not patient:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient not found")
        return patient

    raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Unauthorized role")
