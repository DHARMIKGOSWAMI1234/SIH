"""Authentication service for registration, login, and token generation."""
from typing import Tuple, Optional
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
from backend.api.app.models.user import User, UserRole
from backend.api.app.models.patient import Patient
from backend.api.app.models.caregiver import Caregiver
from backend.api.app.schemas.auth import UserRegisterRequest, UserLoginRequest, TokenResponse, UserResponse
from backend.api.app.repositories.user_repository import UserRepository, PatientRepository
from backend.api.app.auth.security import get_password_hash, verify_password, create_access_token

class AuthService:
    def __init__(self, db: Session):
        self.db = db
        self.user_repo = UserRepository(db)
        self.patient_repo = PatientRepository(db)

    def register(self, req: UserRegisterRequest) -> Tuple[UserResponse, TokenResponse]:
        """Register a new user and associated Patient or Caregiver profile."""
        existing = self.user_repo.get_by_email(req.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A user with this email already exists",
            )

        role = req.role.upper()
        if role not in [r.value for r in UserRole]:
            role = UserRole.PATIENT.value

        user = User(
            email=req.email.lower().strip(),
            password_hash=get_password_hash(req.password),
            full_name=req.full_name.strip(),
            role=role,
        )
        self.user_repo.create(user)

        patient_id = None
        caregiver_id = None

        if role == UserRole.PATIENT.value:
            patient = Patient(
                user_id=user.id,
                anonymous_alias=req.anonymous_alias or req.full_name.strip(),
                preferred_language=req.preferred_language or "en",
            )
            self.patient_repo.create(patient)
            patient_id = patient.id
        elif role == UserRole.CAREGIVER.value:
            caregiver = Caregiver(
                user_id=user.id,
                full_name=req.full_name.strip(),
                phone_number=req.phone_number,
                relationship_to_patient=req.relationship_to_patient or "Family Caregiver",
            )
            self.db.add(caregiver)
            self.db.commit()
            self.db.refresh(caregiver)
            caregiver_id = caregiver.id

        token_data = {
            "sub": user.id,
            "email": user.email,
            "role": user.role,
            "patient_id": patient_id,
            "caregiver_id": caregiver_id,
        }
        access_token = create_access_token(token_data)

        user_resp = UserResponse(
            id=user.id,
            email=user.email,
            full_name=user.full_name,
            role=user.role,
            created_at=user.created_at,
            patient_id=patient_id,
            caregiver_id=caregiver_id,
        )
        token_resp = TokenResponse(
            access_token=access_token,
            user_id=user.id,
            role=user.role,
            patient_id=patient_id,
            caregiver_id=caregiver_id,
        )
        return user_resp, token_resp

    def login(self, req: UserLoginRequest) -> TokenResponse:
        """Authenticate user credentials and issue JWT access token."""
        user = self.user_repo.get_by_email(req.email)
        if not user or not verify_password(req.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid email or password",
                headers={"WWW-Authenticate": "Bearer"},
            )

        patient_id = None
        caregiver_id = None

        if user.role == UserRole.PATIENT.value:
            patient = self.patient_repo.get_by_user_id(user.id)
            if patient:
                patient_id = patient.id
        elif user.role == UserRole.CAREGIVER.value:
            caregiver = self.db.query(Caregiver).filter(Caregiver.user_id == user.id).first()
            if caregiver:
                caregiver_id = caregiver.id

        token_data = {
            "sub": user.id,
            "email": user.email,
            "role": user.role,
            "patient_id": patient_id,
            "caregiver_id": caregiver_id,
        }
        access_token = create_access_token(token_data)

        return TokenResponse(
            access_token=access_token,
            user_id=user.id,
            role=user.role,
            patient_id=patient_id,
            caregiver_id=caregiver_id,
        )
