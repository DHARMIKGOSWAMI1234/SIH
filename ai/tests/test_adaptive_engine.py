"""Unit tests for SMRITI Adaptive Difficulty Engine and Clinical Boundary Compliance."""
import pytest
from ai.models.session import GameSessionPerformance, DifficultyAction
from ai.adaptive_engine.engine import AdaptiveDifficultyEngine, PROHIBITED_CLINICAL_TERMS
from ai.analytics.engagement import summarize_engagement

@pytest.fixture
def engine():
    return AdaptiveDifficultyEngine()

def test_promotion_on_high_accuracy(engine):
    """High accuracy with zero hints and quick response should increase difficulty."""
    perf = GameSessionPerformance(
        game_type="memory_match",
        accuracy=0.92,
        response_time_ms=3200.0,
        mistakes=0,
        hints_used=0,
        current_difficulty=2,
    )
    result = engine.evaluate(perf)
    assert result.action == DifficultyAction.INCREASE
    assert result.previous_difficulty == 2
    assert result.next_difficulty == 3
    assert "increasing" in result.caregiver_explanation.lower()

def test_capped_at_max_difficulty(engine):
    """At maximum difficulty (5), high performance maintains level 5."""
    perf = GameSessionPerformance(
        game_type="memory_match",
        accuracy=0.95,
        response_time_ms=2800.0,
        mistakes=0,
        hints_used=0,
        current_difficulty=5,
    )
    result = engine.evaluate(perf)
    assert result.action == DifficultyAction.MAINTAIN
    assert result.next_difficulty == 5

def test_demotion_on_low_accuracy(engine):
    """Low accuracy below 60% should decrease difficulty and offer support."""
    perf = GameSessionPerformance(
        game_type="pattern_recognition",
        accuracy=0.45,
        response_time_ms=8500.0,
        mistakes=4,
        hints_used=2,
        current_difficulty=3,
    )
    result = engine.evaluate(perf)
    assert result.action == DifficultyAction.DECREASE
    assert result.previous_difficulty == 3
    assert result.next_difficulty == 2
    assert result.support_triggers.get("extra_hints") is True
    assert result.support_triggers.get("reduced_item_count") is True

def test_minimum_difficulty_floor(engine):
    """At minimum difficulty (1), low accuracy maintains level 1 but activates maximum support triggers."""
    perf = GameSessionPerformance(
        game_type="routine_recall",
        accuracy=0.30,
        response_time_ms=12000.0,
        mistakes=5,
        hints_used=3,
        current_difficulty=1,
    )
    result = engine.evaluate(perf)
    assert result.action == DifficultyAction.MAINTAIN
    assert result.next_difficulty == 1
    assert result.support_triggers.get("extra_hints") is True
    assert result.support_triggers.get("display_time_multiplier") == 1.5

def test_steady_performance_maintains_difficulty(engine):
    """Moderate accuracy maintains current difficulty."""
    perf = GameSessionPerformance(
        game_type="memory_match",
        accuracy=0.75,
        response_time_ms=4500.0,
        mistakes=2,
        hints_used=0,
        current_difficulty=2,
    )
    result = engine.evaluate(perf)
    assert result.action == DifficultyAction.MAINTAIN
    assert result.next_difficulty == 2

def test_strict_clinical_boundary_compliance(engine):
    """Every evaluation must strictly exclude clinical or diagnostic terminology."""
    for diff in range(1, 6):
        for acc in [0.2, 0.5, 0.75, 0.95]:
            perf = GameSessionPerformance(
                game_type="test_game",
                accuracy=acc,
                response_time_ms=4000.0,
                mistakes=1,
                hints_used=0,
                current_difficulty=diff,
            )
            result = engine.evaluate(perf)
            explanation_lower = result.caregiver_explanation.lower()
            for prohibited in PROHIBITED_CLINICAL_TERMS:
                assert prohibited not in explanation_lower, f"Prohibited word '{prohibited}' found in '{explanation_lower}'"

def test_clinical_boundary_validation_raises_on_violation(engine):
    """_validate_non_clinical must raise ValueError if clinical terms appear."""
    with pytest.raises(ValueError, match="Clinical boundary violation"):
        engine._validate_non_clinical("Patient dementia score indicates decline.")

def test_engagement_summary():
    """Non-clinical engagement summary calculations."""
    sessions = [
        {"accuracy": 0.8, "response_time_ms": 3000.0},
        {"accuracy": 0.9, "response_time_ms": 2500.0},
    ]
    summary = summarize_engagement(sessions)
    assert summary["total_activities_completed"] == 2
    assert summary["average_accuracy_pct"] == 85.0
    assert summary["average_response_time_ms"] == 2750.0
