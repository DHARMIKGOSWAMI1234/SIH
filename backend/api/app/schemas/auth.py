"""Authentication and user profile schemas."""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field, ConfigDict

class UserRegisterRequest(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=6)
    full_name: str
    role: str = Field(default="PATIENT", description="PATIENT, CAREGIVER, or ADMIN")
    
    # Optional patient profile fields
    anonymous_alias: Optional[str] = "Patient"
    preferred_language: Optional[str] = "en"
    
    # Optional caregiver profile fields
    relationship_to_patient: Optional[str] = "Family Caregiver"
    phone_number: Optional[str] = None

class UserLoginRequest(BaseModel):
    email: EmailStr
    password: str

class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user_id: str
    role: str
    patient_id: Optional[str] = None
    caregiver_id: Optional[str] = None

class UserResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    email: str
    full_name: str
    role: str
    created_at: datetime
    patient_id: Optional[str] = None
    caregiver_id: Optional[str] = None
    anonymous_alias: Optional[str] = None
    preferred_language: Optional[str] = None
    font_scale_preference: Optional[float] = None
    contrast_preference: Optional[str] = None

class PatientProfileUpdateRequest(BaseModel):
    anonymous_alias: Optional[str] = None
    preferred_language: Optional[str] = None
    font_scale_preference: Optional[float] = None
    contrast_preference: Optional[str] = None
