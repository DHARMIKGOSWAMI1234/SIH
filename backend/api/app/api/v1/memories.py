"""Memories REST API endpoints."""
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from backend.api.app.db.session import get_db
from backend.api.app.schemas.memory import MemoryResponse, MemoryUpdate
from backend.api.app.repositories.entity_repository import MemoryRepository
from backend.api.app.auth.dependencies import get_current_user, get_current_patient
from backend.api.app.models.user import User
from backend.api.app.models.patient import Patient
from backend.api.app.models.memory import Memory

router = APIRouter(prefix="/memories", tags=["Memories"])

@router.get("", response_model=List[MemoryResponse])
def list_memories(
    category: Optional[str] = None,
    is_favorite: Optional[bool] = None,
    include_archived: bool = False,
    current_patient: Patient = Depends(get_current_patient),
    db: Session = Depends(get_db),
):
    """Retrieve memories for the current authenticated patient."""
    repo = MemoryRepository(db)
    return repo.list_by_patient(
        current_patient.id,
        category=category,
        is_favorite=is_favorite,
        include_archived=include_archived,
    )

@router.get("/{id}", response_model=MemoryResponse)
def get_memory(
    id: str,
    current_patient: Patient = Depends(get_current_patient),
    db: Session = Depends(get_db),
):
    """Retrieve a single memory by ID."""
    repo = MemoryRepository(db)
    memory = repo.get_by_id(id)
    if not memory or memory.patient_id != current_patient.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found")
    return memory

@router.put("/{id}", response_model=MemoryResponse)
def update_memory(
    id: str,
    req: MemoryUpdate,
    current_patient: Patient = Depends(get_current_patient),
    db: Session = Depends(get_db),
):
    """Update an existing memory."""
    repo = MemoryRepository(db)
    memory = repo.get_by_id(id)
    if not memory or memory.patient_id != current_patient.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found")

    update_dict = req.model_dump(exclude_unset=True)
    for field, val in update_dict.items():
        setattr(memory, field, val)

    return repo.update(memory)

@router.delete("/{id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_memory(
    id: str,
    current_patient: Patient = Depends(get_current_patient),
    db: Session = Depends(get_db),
):
    """Delete a memory."""
    repo = MemoryRepository(db)
    memory = repo.get_by_id(id)
    if not memory or memory.patient_id != current_patient.id:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Memory not found")
    repo.delete(memory)
    return None
