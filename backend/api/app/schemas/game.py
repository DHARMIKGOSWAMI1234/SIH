"""GameSession schemas for cognitive activity tracking. Non-clinical."""
from datetime import datetime
from pydantic import BaseModel, ConfigDict

class GameSessionCreate(BaseModel):
    local_id: str
    game_type: str
    score: int
    accuracy: float
    mistakes: int = 0
    response_time_ms: float = 0.0
    difficulty: int = 1
    hint_count: int = 0
    started_at: datetime
    completed_at: datetime

class GameSessionResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: str
    patient_id: str
    local_id: str
    game_type: str
    score: int
    accuracy: float
    mistakes: int
    response_time_ms: float
    difficulty: int
    hint_count: int
    started_at: datetime
    completed_at: datetime
    created_at: datetime
    updated_at: datetime
