from typing import Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.api.app.db.session import get_db
from backend.api.app.schemas.sync import (
    SyncBatchRequest,
    SyncBatchResponse,
    SyncItemSchema,
    SyncOperationResult,
)
from backend.api.app.services.sync_service import SyncService
from backend.api.app.auth.dependencies import get_current_user, verify_patient_access
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient

router = APIRouter(prefix="/sync", tags=["Synchronization"])

@router.post("", response_model=SyncBatchResponse)
def sync_batch(
    req: SyncBatchRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Batch synchronization endpoint for offline queue processing with strict idempotency."""
    # Verify the user has access to synchronize for this patient
    verify_patient_access(req.patient_id, current_user, db, require_edit=True)

    service = SyncService(db)
    return service.process_batch(req.patient_id, req.items)

@router.post("/memories", response_model=SyncOperationResult)
def sync_single_memory(
    item: SyncItemSchema,
    patient_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Convenience endpoint for individual memory sync."""
    verify_patient_access(patient_id, current_user, db, require_edit=True)

    service = SyncService(db)
    batch_resp = service.process_batch(patient_id, [item])
    if batch_resp.results:
        return batch_resp.results[0]
    raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Sync failed")

@router.post("/game-sessions", response_model=SyncOperationResult)
def sync_single_game_session(
    item: SyncItemSchema,
    patient_id: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Dedicated endpoint for GameSession synchronization with validation and idempotency."""
    # Determine the target patient ID
    # Never trust client patient_id blindly: verify patient access or derive from current_user
    resolved_patient_id = patient_id
    if not resolved_patient_id:
        if current_user.role == "PATIENT":
            patient = db.query(Patient).filter(Patient.user_id == current_user.id).first()
            if not patient:
                raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Patient profile not found")
            resolved_patient_id = patient.id
        else:
            raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="patient_id is required")

    verify_patient_access(resolved_patient_id, current_user, db, require_edit=True)

    # Ensure entity_type is GameSessions
    if not item.entity_type or "game" not in item.entity_type.lower():
        item = item.model_copy(update={"entity_type": "GameSessions"})

    service = SyncService(db)
    batch_resp = service.process_batch(resolved_patient_id, [item])
    if batch_resp.results:
        res = batch_resp.results[0]
        if res.status == "rejected":
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail=res.message or "Game session payload validation rejected",
            )
        return res

    raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Game session sync failed")

