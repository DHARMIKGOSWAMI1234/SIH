"""Health check endpoints."""
from fastapi import APIRouter
from typing import Dict

router = APIRouter()

@router.get("/health", response_model=Dict[str, str], tags=["System"])
async def get_health() -> Dict[str, str]:
    """Base system health check endpoint."""
    return {"status": "ok"}
