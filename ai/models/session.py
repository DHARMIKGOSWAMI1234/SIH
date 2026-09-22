"""Data models for SMRITI AI and session analytics."""
from dataclasses import dataclass, field
from enum import Enum
from typing import Dict, Any, Optional

class DifficultyAction(str, Enum):
    INCREASE = "INCREASE"
    MAINTAIN = "MAINTAIN"
    DECREASE = "DECREASE"

@dataclass
class GameSessionPerformance:
    """Represents the performance recorded during a cognitive exercise."""
    game_type: str
    accuracy: float  # 0.0 to 1.0
    response_time_ms: float
    mistakes: int
    hints_used: int
    current_difficulty: int  # 1 (Beginner) to 5 (Advanced)
    recent_streak: int = 0
    completed: bool = True

@dataclass
class DifficultyAdjustment:
    """Result of adaptive engine evaluation."""
    action: DifficultyAction
    previous_difficulty: int
    next_difficulty: int
    support_triggers: Dict[str, Any] = field(default_factory=dict)
    caregiver_explanation: str = ""
