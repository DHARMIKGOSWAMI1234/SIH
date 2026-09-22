"""Memory schemas matching Flutter Personal Memory Bank and Phase 05."""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class MemoryBase(BaseModel):
    local_id: str
    title: str
    description: str
    category: str = "other"
    relationship: Optional[str] = None
    person_name: Optional[str] = None
    location: Optional[str] = None
    event_date: Optional[datetime] = None
    image_path: Optional[str] = None
    audio_path: Optional[str] = None
    media_uri: Optional[str] = None
    language: str = "en"
    region: Optional[str] = None
    tags: Optional[str] = None
    source: str = "personal"
    is_favorite: bool = False
    is_archived: bool = False

class MemoryCreate(MemoryBase):
    pass

class MemoryUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    relationship: Optional[str] = None
    person_name: Optional[str] = None
    location: Optional[str] = None
    event_date: Optional[datetime] = None
    image_path: Optional[str] = None
    audio_path: Optional[str] = None
    media_uri: Optional[str] = None
    language: Optional[str] = None
    region: Optional[str] = None
    tags: Optional[str] = None
    is_favorite: Optional[bool] = None
    is_archived: Optional[bool] = None

class MemoryResponse(MemoryBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    patient_id: str
    version: int
    created_at: datetime
    updated_at: datetime
