"""SMRITI Deterministic & Explainable Adaptive Difficulty Engine.

IMPORTANT CLINICAL BOUNDARY:
This module does NOT perform medical diagnosis, clinical classification, or dementia prediction.
All outputs reflect game exercise adjustment and engagement comfort only.
"""
from typing import Set
from ai.models.session import DifficultyAction, GameSessionPerformance, DifficultyAdjustment

# Prohibited clinical terms that must NEVER appear in caregiver explanations
PROHIBITED_CLINICAL_TERMS: Set[str] = {
    "dementia", "alzheimer", "cure", "diagnos", "severity",
    "decline", "patholog", "impairment", "prognosis", "deficit", "symptom"
}

class AdaptiveDifficultyEngine:
    """Deterministic, rule-based adaptive engine for cognitive exercises."""

    MIN_DIFFICULTY = 1
    MAX_DIFFICULTY = 5

    # Thresholds for decision-making
    HIGH_ACCURACY_THRESHOLD = 0.85
    LOW_ACCURACY_THRESHOLD = 0.60
    MAX_MISTAKES_FOR_PROMOTION = 1
    MISTAKES_TRIGGER_SUPPORT = 3
    REASONABLE_RESPONSE_TIME_MS = 6000.0  # 6 seconds per action target

    def evaluate(self, performance: GameSessionPerformance) -> DifficultyAdjustment:
        """Evaluates a completed game session and determines the next difficulty level."""
        current_diff = max(self.MIN_DIFFICULTY, min(self.MAX_DIFFICULTY, performance.current_difficulty))
        
        # Rule 1: High performance promotion
        if (
            performance.accuracy >= self.HIGH_ACCURACY_THRESHOLD
            and performance.mistakes <= self.MAX_MISTAKES_FOR_PROMOTION
            and performance.hints_used == 0
            and performance.response_time_ms <= self.REASONABLE_RESPONSE_TIME_MS
        ):
            if current_diff < self.MAX_DIFFICULTY:
                next_diff = current_diff + 1
                action = DifficultyAction.INCREASE
                explanation = (
                    "High exercise accuracy and smooth responses observed. "
                    "Increasing activity variety to keep sessions engaging."
                )
                support_triggers = {}
            else:
                next_diff = self.MAX_DIFFICULTY
                action = DifficultyAction.MAINTAIN
                explanation = (
                    "Excellent consistency at top activity level. "
                    "Maintaining current exercise settings for ongoing engagement."
                )
                support_triggers = {}

        # Rule 2: Support / Difficulty reduction trigger
        elif (
            performance.accuracy < self.LOW_ACCURACY_THRESHOLD
            or performance.mistakes >= self.MISTAKES_TRIGGER_SUPPORT
            or not performance.completed
        ):
            if current_diff > self.MIN_DIFFICULTY:
                next_diff = current_diff - 1
                action = DifficultyAction.DECREASE
                explanation = (
                    "Recent activity seemed challenging. "
                    "Adjusting to a gentler pace with fewer items to ensure a comfortable experience."
                )
                support_triggers = {
                    "extra_hints": True,
                    "display_time_multiplier": 1.25,
                    "reduced_item_count": True,
                }
            else:
                next_diff = self.MIN_DIFFICULTY
                action = DifficultyAction.MAINTAIN
                explanation = (
                    "Providing supportive prompts and extended viewing time "
                    "to assist with comfortable exercise completion."
                )
                support_triggers = {
                    "extra_hints": True,
                    "display_time_multiplier": 1.5,
                    "reduced_item_count": True,
                }

        # Rule 3: Balanced performance -> Maintain
        else:
            next_diff = current_diff
            action = DifficultyAction.MAINTAIN
            explanation = (
                "Steady participation and comfortable engagement. "
                "Maintaining current activity level."
            )
            support_triggers = {
                "extra_hints": performance.hints_used > 0,
                "display_time_multiplier": 1.0,
            }

        # Strict safety assertion: verify explanation never contains clinical terms
        self._validate_non_clinical(explanation)

        return DifficultyAdjustment(
            action=action,
            previous_difficulty=current_diff,
            next_difficulty=next_diff,
            support_triggers=support_triggers,
            caregiver_explanation=explanation,
        )

    def _validate_non_clinical(self, text: str) -> None:
        """Ensures generated explanations never use clinical or diagnostic language."""
        lower_text = text.lower()
        for term in PROHIBITED_CLINICAL_TERMS:
            if term in lower_text:
                raise ValueError(
                    f"Clinical boundary violation: Prohibited term '{term}' found in caregiver explanation: '{text}'"
                )
