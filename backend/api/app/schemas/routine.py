"""Routine schemas."""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class RoutineBase(BaseModel):
    local_id: str
    title: str
    steps_json: str
    preferred_time: str
    enabled: bool = True

class RoutineCreate(RoutineBase):
    pass

class RoutineUpdate(BaseModel):
    title: Optional[str] = None
    steps_json: Optional[str] = None
    preferred_time: Optional[str] = None
    enabled: Optional[bool] = None

class RoutineResponse(RoutineBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    patient_id: str
    version: int
    created_at: datetime
    updated_at: datetime
