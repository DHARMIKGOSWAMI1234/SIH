"""Pydantic response models for SMRITI Caregiver Intelligence & Deterministic Analytics.

Strictly non-clinical, non-diagnostic, and non-prescriptive.
All metrics describe recorded application activity and exercise participation.
"""
from typing import List, Optional, Literal, Dict, Any
from datetime import datetime
from pydantic import BaseModel, Field

PeriodDays = Literal[7, 14, 30]
TrendDirection = Literal["IMPROVING", "STABLE", "DECLINING", "INSUFFICIENT_DATA"]
ParticipationDirection = Literal["INCREASED", "STABLE", "DECREASED", "INSUFFICIENT_DATA"]
ReviewFlagStatus = Literal["INFO", "NEUTRAL", "ATTENTION_RECOMMENDED"]

class DailyActivityDataPoint(BaseModel):
    """Daily activity count for participation charts."""
    date: str = Field(..., description="Date string in YYYY-MM-DD format")
    game_sessions: int = Field(0, description="Completed cognitive game sessions on this date")
    reminders_completed: int = Field(0, description="Acknowledged routine reminders on this date")
    total: int = Field(0, description="Total completed activities on this date")

class ActivityOverviewResponse(BaseModel):
    """Aggregated participation metrics over the selected period."""
    patient_id: str
    period_days: int
    total_completed_activities: int
    active_days: int
    sessions_per_day: float
    sessions_per_week: float
    most_recent_activity_at: Optional[datetime] = None
    longest_streak_days: int
    participation_trend: ParticipationDirection
    trend_observation: str
    daily_series: List[DailyActivityDataPoint]
    data_sufficient: bool

class GameMetricSummary(BaseModel):
    """Performance metrics for a specific game type or aggregated across all games."""
    game_type: str
    sessions_completed: int
    average_score: Optional[float] = None
    average_accuracy: Optional[float] = None
    average_mistakes: Optional[float] = None
    average_hints: Optional[float] = None
    average_duration_seconds: Optional[float] = None
    average_response_time_ms: Optional[float] = None
    accuracy_trend: TrendDirection
    mistakes_trend: TrendDirection
    response_time_trend: TrendDirection = "INSUFFICIENT_DATA"
    hint_usage_observation: Optional[str] = None
    trend_observation: str
    data_sufficient: bool

class GamesAnalyticsResponse(BaseModel):
    """Game performance analytics across all games or filtered by game type."""
    patient_id: str
    period_days: int
    selected_game_type: str
    overall: GameMetricSummary
    games: List[GameMetricSummary]

class ReminderAnalyticsResponse(BaseModel):
    """Reminder adherence metrics based on scheduled vs completed routine reminders."""
    patient_id: str
    period_days: int
    scheduled_count: int
    completed_count: int
    snoozed_count: int
    skipped_count: int
    adherence_rate: Optional[float] = None
    trend_direction: TrendDirection
    trend_observation: str
    data_sufficient: bool

class ObservedTrendItem(BaseModel):
    """Deterministic, explainable observation based on recorded activity."""
    id: str
    category: Literal["PARTICIPATION", "GAME_PERFORMANCE", "REMINDER_ADHERENCE", "SYNC_HEALTH"]
    title: str
    description: str
    direction: str
    period_days: int
    status_type: ReviewFlagStatus
    data_basis: str

class ReviewFlagItem(BaseModel):
    """Non-clinical review flag indicating notable changes or attention points."""
    id: str
    flag_type: str
    title: str
    message: str
    status_type: ReviewFlagStatus
    suggested_action: str

class TrendsAnalyticsResponse(BaseModel):
    """Collection of observed trends and non-clinical review flags for caregiver review."""
    patient_id: str
    period_days: int
    trends: List[ObservedTrendItem]
    review_flags: List[ReviewFlagItem]
    clinical_disclaimer: str = (
        "SMRITI is a non-diagnostic platform. All observations describe recorded application "
        "activity and routine completion. SMRITI does not provide clinical diagnoses, dementia "
        "severity ratings, disease progression predictions, or medication recommendations."
    )

class SyncHealthResponse(BaseModel):
    """Caregiver-safe synchronization health status."""
    patient_id: str
    sync_status: Literal["UP_TO_DATE", "PENDING", "SYNCING", "ATTENTION_NEEDED"]
    status_label: str
    pending_records_count: int
    last_sync_at: Optional[datetime] = None
    last_error_message: Optional[str] = None
    is_offline_ready: bool = True
