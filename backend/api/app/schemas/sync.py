"""Synchronization schemas with operation-level idempotency and conflict reporting."""
from typing import List, Optional, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field

class SyncItemSchema(BaseModel):
    operation_id: str = Field(..., description="Unique operation UUID serving as the idempotency key")
    entity_type: str = Field(..., description="Memories, GameSessions, Reminders, ReminderEvents, Routines")
    operation: str = Field(..., description="CREATE, UPDATE, DELETE")
    local_id: str = Field(..., description="The entity's client-side localId")
    server_id: Optional[str] = Field(None, description="The entity's serverId if previously synced")
    payload: Dict[str, Any] = Field(..., description="Entity data payload")
    client_updated_at: Optional[datetime] = Field(None, description="Timestamp of the mutation on the client")

class SyncOperationResult(BaseModel):
    operation_id: str
    status: str = Field(..., description="synced, already_processed, conflict, rejected")
    server_id: Optional[str] = None
    server_updated_at: Optional[datetime] = None
    message: Optional[str] = None
    conflict_data: Optional[Dict[str, Any]] = None

class SyncBatchRequest(BaseModel):
    patient_id: str
    items: List[SyncItemSchema]

class SyncBatchResponse(BaseModel):
    results: List[SyncOperationResult]
    processed_count: int
    server_time: datetime
