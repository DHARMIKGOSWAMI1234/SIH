"""End-to-end system integration tests across AI, Backend, and Shared Schemas."""
import json
from pathlib import Path
import pytest
from httpx import AsyncClient, ASGITransport
from backend.api.app.main import app
from ai.models.session import GameSessionPerformance, DifficultyAction
from ai.adaptive_engine.engine import AdaptiveDifficultyEngine

@pytest.mark.asyncio
async def test_backend_health():
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        res = await client.get("/health")
    assert res.status_code == 200
    assert res.json() == {"status": "ok"}

def test_ai_engine_with_schema_fixture():
    root_dir = Path(__file__).parent.parent
    demo_file = root_dir / "data" / "demo" / "sample_patient_sessions.json"
    with open(demo_file, "r", encoding="utf-8") as f:
        demo_sessions = json.load(f)

    engine = AdaptiveDifficultyEngine()
    for s in demo_sessions:
        perf = GameSessionPerformance(
            game_type=s["gameType"],
            accuracy=s["accuracy"],
            response_time_ms=s["responseTimeMs"],
            mistakes=s["mistakes"],
            hints_used=s["hintCount"],
            current_difficulty=s["difficulty"],
        )
        adjustment = engine.evaluate(perf)
        assert adjustment.next_difficulty in range(1, 6)
        assert len(adjustment.caregiver_explanation) > 0

def test_language_constants_integrity():
    root_dir = Path(__file__).parent.parent
    lang_file = root_dir / "shared" / "constants" / "languages.json"
    with open(lang_file, "r", encoding="utf-8") as f:
        data = json.load(f)

    codes = [l["code"] for l in data["supported_languages"]]
    assert "en" in codes
    assert "hi" in codes
    assert "as" in codes
