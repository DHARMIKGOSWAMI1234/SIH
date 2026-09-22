"""FastAPI endpoints for Caregiver Intelligence & Deterministic Analytics.

All routes enforce server-side caregiver authorization via verify_patient_access.
All responses are strictly non-clinical, non-diagnostic, and non-prescriptive.
"""
from typing import Optional, Literal
from fastapi import APIRouter, Depends, Query, Path, HTTPException, status
from sqlalchemy.orm import Session

from backend.api.app.db.session import get_db
from backend.api.app.models.user import User
from backend.api.app.auth.dependencies import get_current_user, verify_patient_access
from backend.api.app.services.analytics_service import AnalyticsService
from backend.api.app.schemas.analytics import (
    ActivityOverviewResponse,
    GamesAnalyticsResponse,
    ReminderAnalyticsResponse,
    TrendsAnalyticsResponse,
    SyncHealthResponse,
)

router = APIRouter(
    prefix="/caregivers/patients/{patient_id}/analytics",
    tags=["Caregiver Analytics"],
)

@router.get("/overview", response_model=ActivityOverviewResponse)
def get_analytics_overview(
    patient_id: str = Path(..., description="Target patient ID"),
    period_days: int = Query(7, description="Analytics comparison window in days"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve overall activity participation and daily timeline series."""
    verify_patient_access(patient_id, current_user, db)
    service = AnalyticsService(db)
    return service.get_activity_overview(patient_id, period_days)

@router.get("/activity", response_model=ActivityOverviewResponse)
def get_activity_analytics(
    patient_id: str = Path(..., description="Target patient ID"),
    period_days: int = Query(7, description="Analytics comparison window in days"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve detailed participation frequency and active days breakdown."""
    verify_patient_access(patient_id, current_user, db)
    service = AnalyticsService(db)
    return service.get_activity_overview(patient_id, period_days)

@router.get("/games", response_model=GamesAnalyticsResponse)
def get_game_analytics(
    patient_id: str = Path(..., description="Target patient ID"),
    period_days: int = Query(7, description="Analytics comparison window in days"),
    game_type: str = Query("all", description="Filter by game family: all, Memory Match, Pattern Recognition, Daily Routine Recall"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve cognitive exercise performance metrics and trends."""
    verify_patient_access(patient_id, current_user, db)
    service = AnalyticsService(db)
    return service.get_game_analytics(patient_id, period_days, selected_game_type=game_type)

@router.get("/reminders", response_model=ReminderAnalyticsResponse)
def get_reminder_analytics(
    patient_id: str = Path(..., description="Target patient ID"),
    period_days: int = Query(7, description="Analytics comparison window in days"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve routine reminder adherence rates and observed completion trends."""
    verify_patient_access(patient_id, current_user, db)
    service = AnalyticsService(db)
    return service.get_reminder_analytics(patient_id, period_days)

@router.get("/trends", response_model=TrendsAnalyticsResponse)
def get_observed_trends(
    patient_id: str = Path(..., description="Target patient ID"),
    period_days: int = Query(7, description="Analytics comparison window in days"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve deterministic observed trends and non-clinical review flags."""
    verify_patient_access(patient_id, current_user, db)
    service = AnalyticsService(db)
    return service.get_observed_trends(patient_id, period_days)

@router.get("/sync", response_model=SyncHealthResponse)
def get_sync_health(
    patient_id: str = Path(..., description="Target patient ID"),
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db),
):
    """Retrieve caregiver-safe synchronization health status."""
    verify_patient_access(patient_id, current_user, db)
    service = AnalyticsService(db)
    return service.get_sync_health(patient_id)
