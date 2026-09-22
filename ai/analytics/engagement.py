"""Non-clinical engagement analytics for SMRITI."""
from typing import List, Dict, Any

def summarize_engagement(sessions: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Computes transparent, non-clinical activity engagement summaries.
    
    NEVER classifies dementia severity or diagnoses patients.
    """
    if not sessions:
        return {
            "total_activities_completed": 0,
            "average_accuracy_pct": 0.0,
            "average_response_time_ms": 0.0,
            "activity_streak_days": 0,
            "caregiver_note": "No activities recorded recently. Encouraging a light session today."
        }

    total_count = len(sessions)
    total_acc = sum(s.get("accuracy", 0.0) for s in sessions)
    total_rt = sum(s.get("response_time_ms", 0.0) for s in sessions)
    
    avg_acc = (total_acc / total_count) * 100
    avg_rt = total_rt / total_count

    return {
        "total_activities_completed": total_count,
        "average_accuracy_pct": round(avg_acc, 1),
        "average_response_time_ms": round(avg_rt, 0),
        "caregiver_note": f"Completed {total_count} activities with steady participation."
    }
