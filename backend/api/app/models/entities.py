"""Future PostgreSQL Entity Definitions for SMRITI Cloud/LAN Backend.

Phase 01 Architecture Specification:
These schemas define the database entity relationships planned for PostgreSQL in Phase 02.
Zero real patient data is stored; all structures are privacy-preserving by design.
"""
from datetime import datetime
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field

# 1. Consent Records
class ConsentRecord(BaseModel):
    id: str
    patient_id: str
    caregiver_id: str
    telemetry_sharing_enabled: bool = False
    voice_processing_consented: bool = False
    created_at: datetime
    updated_at: datetime

# 2. Patients & Caregivers
class PatientEntity(BaseModel):
    id: str
    anonymous_alias: str
    preferred_language: str = "en"
    font_scale_preference: float = 1.0
    contrast_preference: str = "standard"  # standard, high
    created_at: datetime

class CaregiverEntity(BaseModel):
    id: str
    full_name: str
    email: str
    relationship_to_patient: str
    created_at: datetime

# 3. Games & Game Sessions
class GameEntity(BaseModel):
    id: str
    game_code: str  # memory_match, pattern_recognition, routine_recall
    title: str
    description: str

class GameSessionEntity(BaseModel):
    id: str
    local_id: str
    patient_id: str
    game_type: str
    score: int
    accuracy: float
    mistakes: int
    response_time_ms: float
    difficulty: int
    hint_count: int
    started_at: datetime
    completed_at: datetime
    synced_at: datetime

# 4. Reminders & Events
class ReminderEntity(BaseModel):
    id: str
    local_id: str
    patient_id: str
    title: str
    reminder_type: str  # medication, hydration, routine
    scheduled_time: str
    enabled: bool

class ReminderEventEntity(BaseModel):
    id: str
    local_id: str
    reminder_id: str
    event_type: str  # acknowledged, snoozed, missed
    occurred_at: datetime

# 5. Routines & Memories
class RoutineEntity(BaseModel):
    id: str
    local_id: str
    patient_id: str
    title: str
    steps_json: str
    preferred_time: str
    enabled: bool

class MemoryEntity(BaseModel):
    id: str
    local_id: str
    patient_id: str
    title: str
    description: str
    media_uri: Optional[str] = None
    language: str = "en"

# 6. Recommendations & Alerts (Non-clinical)
class RecommendationEntity(BaseModel):
    id: str
    patient_id: str
    category: str
    suggested_difficulty: int
    caregiver_note: str
    created_at: datetime

class AlertEntity(BaseModel):
    id: str
    patient_id: str
    alert_type: str  # missed_reminder, inactivity_notice
    message: str
    is_dismissed: bool = False
    created_at: datetime

# 7. Sync Records & Audit Logs
class SyncRecordEntity(BaseModel):
    id: str
    patient_id: str
    entity_type: str
    local_id: str
    server_id: str
    operation: str  # INSERT, UPDATE, DELETE
    status: str
    synced_at: datetime

class AuditLogEntity(BaseModel):
    id: str
    actor_id: str
    actor_role: str  # patient, caregiver, system
    action: str
    resource_type: str
    ip_address_hash: str
    created_at: datetime
