"""Reminder and ReminderEvent schemas."""
from typing import Optional
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class ReminderBase(BaseModel):
    local_id: str
    title: str
    reminder_type: str = "routine"
    scheduled_time: str
    enabled: bool = True

class ReminderCreate(ReminderBase):
    pass

class ReminderUpdate(BaseModel):
    title: Optional[str] = None
    reminder_type: Optional[str] = None
    scheduled_time: Optional[str] = None
    enabled: Optional[bool] = None

class ReminderResponse(ReminderBase):
    model_config = ConfigDict(from_attributes=True)

    id: str
    patient_id: str
    version: int
    created_at: datetime
    updated_at: datetime

class ReminderEventCreate(BaseModel):
    local_id: str
    reminder_id: str
    event_type: str  # acknowledged, snoozed, missed
    occurred_at: datetime

class ReminderEventResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    patient_id: str
    local_id: str
    reminder_id: str
    event_type: str
    occurred_at: datetime
    created_at: datetime
