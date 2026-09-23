"""Pydantic schemas for Caregiver ↔ Patient Pairing."""
from typing import Optional
from pydantic import BaseModel, Field

class PairingCreateResponse(BaseModel):
    request_id: str
    short_code: str
    pairing_token: str
    expires_at: str
    expires_in_seconds: int = 600
    qr_payload: str
    caregiver_name: str

class PairingStatusResponse(BaseModel):
    request_id: str
    status: str
    is_used: bool
    patient_id: Optional[str] = None
    patient_name: Optional[str] = None

class PairingValidateRequest(BaseModel):
    short_code: Optional[str] = Field(None, max_length=10)
    pairing_token: Optional[str] = None
    qr_payload: Optional[str] = None

class PairingValidateResponse(BaseModel):
    valid: bool
    request_id: str
    pairing_token: str
    caregiver_id: str
    caregiver_name: str
    relationship_type: str
    expires_at: str

class PairingConfirmRequest(BaseModel):
    pairing_token: str
    patient_id: Optional[str] = None

class PairingConfirmResponse(BaseModel):
    success: bool
    caregiver_name: str
    patient_name: str
    connected_at: str

class PatientCaregiverStatusResponse(BaseModel):
    connected: bool
    caregiver_id: Optional[str] = None
    caregiver_name: Optional[str] = None
    relationship: Optional[str] = None
    linked_at: Optional[str] = None
