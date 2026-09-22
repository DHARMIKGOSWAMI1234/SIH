"""Patient schemas."""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class PatientBase(BaseModel):
    anonymous_alias: str = "Patient"
    preferred_language: str = "en"
    font_scale_preference: float = 1.0
    contrast_preference: str = "standard"

class PatientCreate(PatientBase):
    user_id: str

class PatientUpdate(BaseModel):
    anonymous_alias: Optional[str] = None
    preferred_language: Optional[str] = None
    font_scale_preference: Optional[float] = None
    contrast_preference: Optional[str] = None

class PatientResponse(PatientBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    user_id: str
    created_at: datetime
    updated_at: datetime
