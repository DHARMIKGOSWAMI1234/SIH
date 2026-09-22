"""Caregiver schemas."""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class CaregiverBase(BaseModel):
    full_name: str
    phone_number: Optional[str] = None
    relationship_to_patient: str = "Family Caregiver"

class CaregiverCreate(CaregiverBase):
    user_id: str

class CaregiverResponse(CaregiverBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    created_at: datetime
    updated_at: datetime

class LinkPatientRequest(BaseModel):
    patient_email: str
    relationship_type: Optional[str] = "Family Caregiver"
