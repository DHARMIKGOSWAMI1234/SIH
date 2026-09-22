"""Deterministic, explainable analytics service for SMRITI Caregiver Intelligence.

Strictly non-clinical, non-diagnostic, and non-prescriptive.
Calculates activity participation, game performance, reminder adherence, and observed trends
from validated PostgreSQL records (GameSession, Reminder, ReminderEvent, SyncOperation).
"""
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta, timezone
from sqlalchemy.orm import Session
from sqlalchemy import func, and_, desc

from backend.api.app.models.game_session import GameSession
from backend.api.app.models.reminder import Reminder, ReminderEvent
from backend.api.app.models.sync_operation import SyncOperation
from backend.api.app.schemas.analytics import (
    ActivityOverviewResponse,
    DailyActivityDataPoint,
    GamesAnalyticsResponse,
    GameMetricSummary,
    ReminderAnalyticsResponse,
    TrendsAnalyticsResponse,
    ObservedTrendItem,
    ReviewFlagItem,
    SyncHealthResponse,
    TrendDirection,
    ParticipationDirection,
)

class AnalyticsService:
    def __init__(self, db: Session):
        self.db = db

    def _get_time_windows(self, period_days: int) -> Tuple[datetime, datetime, datetime]:
        """Returns (now, current_start, prev_start) in UTC timezone."""
        now = datetime.now(timezone.utc)
        current_start = now - timedelta(days=period_days)
        prev_start = current_start - timedelta(days=period_days)
        return now, current_start, prev_start

    # =========================================================================
    # 1. ACTIVITY PARTICIPATION ANALYTICS
    # =========================================================================

    def get_activity_overview(self, patient_id: str, period_days: int) -> ActivityOverviewResponse:
        now, current_start, prev_start = self._get_time_windows(period_days)

        # Current period game sessions (deduplicated)
        current_sessions_raw = (
            self.db.query(GameSession)
            .filter(
                GameSession.patient_id == patient_id,
                GameSession.completed_at >= current_start,
                GameSession.completed_at <= now,
            )
            .all()
        )
        seen_curr_s = set()
        current_sessions = []
        for s in current_sessions_raw:
            if s.id not in seen_curr_s:
                seen_curr_s.add(s.id)
                current_sessions.append(s)

        # Previous period game sessions (deduplicated)
        prev_sessions_raw = (
            self.db.query(GameSession)
            .filter(
                GameSession.patient_id == patient_id,
                GameSession.completed_at >= prev_start,
                GameSession.completed_at < current_start,
            )
            .all()
        )
        seen_prev_s = set()
        prev_sessions = []
        for s in prev_sessions_raw:
            if s.id not in seen_prev_s:
                seen_prev_s.add(s.id)
                prev_sessions.append(s)

        # Current period reminder events (completed/acknowledged, deduplicated)
        current_reminder_events_raw = (
            self.db.query(ReminderEvent)
            .filter(
                ReminderEvent.patient_id == patient_id,
                ReminderEvent.event_type == "acknowledged",
                ReminderEvent.occurred_at >= current_start,
                ReminderEvent.occurred_at <= now,
            )
            .all()
        )
        seen_curr_r = set()
        current_reminder_events = []
        for r in current_reminder_events_raw:
            if r.id not in seen_curr_r:
                seen_curr_r.add(r.id)
                current_reminder_events.append(r)

        # Previous period reminder events (deduplicated)
        prev_reminder_events_raw = (
            self.db.query(ReminderEvent)
            .filter(
                ReminderEvent.patient_id == patient_id,
                ReminderEvent.event_type == "acknowledged",
                ReminderEvent.occurred_at >= prev_start,
                ReminderEvent.occurred_at < current_start,
            )
            .all()
        )
        seen_prev_r = set()
        prev_reminder_events = []
        for r in prev_reminder_events_raw:
            if r.id not in seen_prev_r:
                seen_prev_r.add(r.id)
                prev_reminder_events.append(r)

        # Total completed activities = game sessions + acknowledged reminders
        current_total = len(current_sessions) + len(current_reminder_events)
        prev_total = len(prev_sessions) + len(prev_reminder_events)

        # Daily series aggregation
        daily_dict: Dict[str, Dict[str, int]] = {}
        for day_offset in range(period_days):
            day_dt = (current_start + timedelta(days=day_offset)).strftime("%Y-%m-%d")
            daily_dict[day_dt] = {"game_sessions": 0, "reminders_completed": 0, "total": 0}

        for s in current_sessions:
            d_str = s.completed_at.strftime("%Y-%m-%d")
            if d_str in daily_dict:
                daily_dict[d_str]["game_sessions"] += 1
                daily_dict[d_str]["total"] += 1

        for r in current_reminder_events:
            d_str = r.occurred_at.strftime("%Y-%m-%d")
            if d_str in daily_dict:
                daily_dict[d_str]["reminders_completed"] += 1
                daily_dict[d_str]["total"] += 1

        daily_series = [
            DailyActivityDataPoint(
                date=k,
                game_sessions=v["game_sessions"],
                reminders_completed=v["reminders_completed"],
                total=v["total"],
            )
            for k, v in sorted(daily_dict.items())
        ]

        # Active days: days with at least 1 completed activity
        active_days = sum(1 for dp in daily_series if dp.total > 0)

        # Longest participation streak
        longest_streak = 0
        current_streak = 0
        for dp in daily_series:
            if dp.total > 0:
                current_streak += 1
                if current_streak > longest_streak:
                    longest_streak = current_streak
            else:
                current_streak = 0

        # Most recent activity timestamp
        most_recent = None
        all_timestamps = [s.completed_at for s in current_sessions] + [r.occurred_at for r in current_reminder_events]
        if all_timestamps:
            most_recent = max(all_timestamps)

        # Metric-specific data sufficiency for participation:
        # At least 2 comparable observations (current >= 2 and prev >= 2)
        data_sufficient = (current_total >= 2) and (prev_total >= 2)
        participation_trend: ParticipationDirection = "INSUFFICIENT_DATA"
        trend_obs = "Not enough activity data to show a reliable trend."

        if current_total == 0 and prev_total == 0:
            trend_obs = "No activity records found in the selected period."
        elif not data_sufficient:
            if prev_total == 0 and current_total >= 2:
                trend_obs = f"{current_total} activities completed in this period. Insufficient previous-period data for comparison."
            elif current_total == 1:
                trend_obs = "1 activity recorded. More activity is needed before a participation trend can be shown."
            else:
                trend_obs = "Not enough activity data to show a reliable trend."
        else:
            diff = current_total - prev_total
            pct_change = (diff / prev_total) * 100.0 if prev_total > 0 else 0.0

            if pct_change > 5.0:
                participation_trend = "INCREASED"
                trend_obs = f"Activity participation was higher ({current_total} vs {prev_total}) than the previous period."
            elif pct_change < -5.0:
                participation_trend = "DECREASED"
                trend_obs = f"Activity participation was lower ({current_total} vs {prev_total}) than the previous period."
            else:
                participation_trend = "STABLE"
                trend_obs = f"Activity participation remained steady ({current_total} sessions) compared with the previous period."

        sessions_per_day = round(current_total / float(period_days), 2)
        sessions_per_week = round(sessions_per_day * 7.0, 1)

        return ActivityOverviewResponse(
            patient_id=patient_id,
            period_days=period_days,
            total_completed_activities=current_total,
            active_days=active_days,
            sessions_per_day=sessions_per_day,
            sessions_per_week=sessions_per_week,
            most_recent_activity_at=most_recent,
            longest_streak_days=longest_streak,
            participation_trend=participation_trend,
            trend_observation=trend_obs,
            daily_series=daily_series,
            data_sufficient=data_sufficient,
        )

    # =========================================================================
    # 2. GAME PERFORMANCE ANALYTICS
    # =========================================================================

    def get_game_analytics(
        self,
        patient_id: str,
        period_days: int,
        selected_game_type: str = "all",
    ) -> GamesAnalyticsResponse:
        now, current_start, prev_start = self._get_time_windows(period_days)

        supported_games = [
            "Memory Match",
            "Pattern Recognition",
            "Daily Routine Recall",
        ]

        # Query all game sessions for current and previous periods
        current_raw = self.db.query(GameSession).filter(
            GameSession.patient_id == patient_id,
            GameSession.completed_at >= current_start,
            GameSession.completed_at <= now,
        ).all()
        prev_raw = self.db.query(GameSession).filter(
            GameSession.patient_id == patient_id,
            GameSession.completed_at >= prev_start,
            GameSession.completed_at < current_start,
        ).all()

        # Deduplicate to prevent accidental double-counting
        seen_curr = set()
        all_current = []
        for s in current_raw:
            if s.id not in seen_curr:
                seen_curr.add(s.id)
                all_current.append(s)

        seen_prev = set()
        all_prev = []
        for s in prev_raw:
            if s.id not in seen_prev:
                seen_prev.add(s.id)
                all_prev.append(s)

        def compute_summary(game_label: str, curr_list: List[GameSession], prev_list: List[GameSession]) -> GameMetricSummary:
            n_curr = len(curr_list)
            n_prev = len(prev_list)

            # Metric-specific minimum data rule: at least 2 completed sessions in each period
            sufficient = (n_curr >= 2) and (n_prev >= 2)

            if n_curr == 0:
                return GameMetricSummary(
                    game_type=game_label,
                    sessions_completed=0,
                    average_score=None,
                    average_accuracy=None,
                    average_mistakes=None,
                    average_hints=None,
                    average_duration_seconds=None,
                    average_response_time_ms=None,
                    accuracy_trend="INSUFFICIENT_DATA",
                    mistakes_trend="INSUFFICIENT_DATA",
                    response_time_trend="INSUFFICIENT_DATA",
                    hint_usage_observation=None,
                    trend_observation="Not enough activity data to show a reliable trend.",
                    data_sufficient=False,
                )

            # Average score / accuracy: require sufficient valid game sessions (n_curr >= 1)
            avg_score = round(sum(s.score for s in curr_list) / float(n_curr), 1)
            avg_acc = round(sum(s.accuracy for s in curr_list) / float(n_curr), 1)
            avg_mistakes = round(sum(s.mistakes for s in curr_list) / float(n_curr), 1)
            avg_hints = round(sum(s.hint_count for s in curr_list) / float(n_curr), 1)
            durations = [(s.completed_at - s.started_at).total_seconds() for s in curr_list if s.completed_at >= s.started_at]
            avg_dur = round(sum(durations) / float(len(durations)), 1) if durations else None

            # Response time: require sufficient valid measurements
            valid_curr_resp = [s.response_time_ms for s in curr_list if s.response_time_ms and s.response_time_ms > 0]
            avg_resp = round(sum(valid_curr_resp) / float(len(valid_curr_resp)), 1) if valid_curr_resp else None

            if not sufficient:
                obs = (
                    f"{n_curr} session recorded. More sessions needed for comparative trend."
                    if n_curr == 1
                    else "Not enough activity data to show a reliable trend."
                )
                return GameMetricSummary(
                    game_type=game_label,
                    sessions_completed=n_curr,
                    average_score=avg_score,
                    average_accuracy=avg_acc,
                    average_mistakes=avg_mistakes,
                    average_hints=avg_hints,
                    average_duration_seconds=avg_dur,
                    average_response_time_ms=avg_resp,
                    accuracy_trend="INSUFFICIENT_DATA",
                    mistakes_trend="INSUFFICIENT_DATA",
                    response_time_trend="INSUFFICIENT_DATA",
                    hint_usage_observation="Consistent hint usage observed." if avg_hints is not None else None,
                    trend_observation=obs,
                    data_sufficient=False,
                )

            # Sufficient data: calculate comparative metrics
            prev_acc = sum(s.accuracy for s in prev_list) / float(n_prev)
            prev_mistakes = sum(s.mistakes for s in prev_list) / float(n_prev)
            prev_hints = sum(s.hint_count for s in prev_list) / float(n_prev)

            # Accuracy trend (higher = improving, lower = declining)
            acc_diff = avg_acc - prev_acc
            if acc_diff > 3.0:
                acc_trend: TrendDirection = "IMPROVING"
                acc_obs = f"Accuracy increased compared with the previous period ({avg_acc:.1f}% vs {prev_acc:.1f}%)."
            elif acc_diff < -3.0:
                acc_trend = "DECLINING"
                acc_obs = f"Accuracy was lower compared with the previous period ({avg_acc:.1f}% vs {prev_acc:.1f}%)."
            else:
                acc_trend = "STABLE"
                acc_obs = f"Accuracy remained steady ({avg_acc:.1f}%) across recorded sessions."

            # Mistakes trend (INVERTED: lower mistakes = improving, higher mistakes = declining)
            mistakes_diff = avg_mistakes - prev_mistakes
            if mistakes_diff < -0.5:
                mistakes_trend: TrendDirection = "IMPROVING"
            elif mistakes_diff > 0.5:
                mistakes_trend = "DECLINING"
            else:
                mistakes_trend = "STABLE"

            # Response time trend (lower ms = faster/improving, higher ms = slower/declining)
            valid_prev_resp = [s.response_time_ms for s in prev_list if s.response_time_ms and s.response_time_ms > 0]
            if len(valid_curr_resp) >= 2 and len(valid_prev_resp) >= 2 and avg_resp is not None:
                prev_avg_resp = sum(valid_prev_resp) / float(len(valid_prev_resp))
                resp_diff = avg_resp - prev_avg_resp
                if resp_diff < -200.0:
                    resp_trend: TrendDirection = "IMPROVING"
                elif resp_diff > 200.0:
                    resp_trend = "DECLINING"
                else:
                    resp_trend = "STABLE"
            else:
                resp_trend = "INSUFFICIENT_DATA"

            # Hints: descriptive-only metric (not classified as improving/declining)
            hints_diff = avg_hints - prev_hints
            if hints_diff > 0.5:
                hint_obs = "Recent sessions included more hints than earlier sessions."
            elif hints_diff < -0.5:
                hint_obs = "Recent sessions included fewer hints than earlier sessions."
            else:
                hint_obs = "Hint usage remained consistent across sessions."

            return GameMetricSummary(
                game_type=game_label,
                sessions_completed=n_curr,
                average_score=avg_score,
                average_accuracy=avg_acc,
                average_mistakes=avg_mistakes,
                average_hints=avg_hints,
                average_duration_seconds=avg_dur,
                average_response_time_ms=avg_resp,
                accuracy_trend=acc_trend,
                mistakes_trend=mistakes_trend,
                response_time_trend=resp_trend,
                hint_usage_observation=hint_obs,
                trend_observation=acc_obs,
                data_sufficient=True,
            )

        overall_summary = compute_summary("All Games", all_current, all_prev)

        game_summaries: List[GameMetricSummary] = []
        for g_name in supported_games:
            curr_g = [s for s in all_current if s.game_type == g_name]
            prev_g = [s for s in all_prev if s.game_type == g_name]
            game_summaries.append(compute_summary(g_name, curr_g, prev_g))

        return GamesAnalyticsResponse(
            patient_id=patient_id,
            period_days=period_days,
            selected_game_type=selected_game_type,
            overall=overall_summary,
            games=game_summaries,
        )

    # =========================================================================
    # 3. REMINDER ADHERENCE ANALYTICS
    # =========================================================================

    def get_reminder_analytics(self, patient_id: str, period_days: int) -> ReminderAnalyticsResponse:
        now, current_start, prev_start = self._get_time_windows(period_days)

        # Active scheduled reminders configured for this patient
        scheduled_reminders = (
            self.db.query(Reminder)
            .filter(
                Reminder.patient_id == patient_id,
                Reminder.enabled == True,
            )
            .all()
        )

        def parse_scheduled_time(time_str: str) -> Tuple[int, int]:
            try:
                parts = time_str.strip().split(":")
                return int(parts[0]), int(parts[1])
            except Exception:
                return 9, 0

        # Calculate scheduled reminder occurrences strictly up to 'now'
        # Scheduled reminders that have not yet occurred must NOT count as missed/skipped
        scheduled_count_curr = 0
        scheduled_count_prev = 0

        for r in scheduled_reminders:
            r_hour, r_min = parse_scheduled_time(r.scheduled_time)
            r_created = r.created_at if r.created_at.tzinfo else r.created_at.replace(tzinfo=timezone.utc)

            # Current period slots
            curr_start_date = current_start.date()
            now_date = now.date()
            days_span_curr = (now_date - curr_start_date).days + 1
            for day_offset in range(days_span_curr):
                slot_date = curr_start_date + timedelta(days=day_offset)
                slot_dt = datetime(slot_date.year, slot_date.month, slot_date.day, r_hour, r_min, tzinfo=timezone.utc)
                if slot_dt >= current_start and slot_dt <= now:
                    if slot_dt >= r_created - timedelta(minutes=5):
                        scheduled_count_curr += 1

            # Previous period slots
            prev_start_date = prev_start.date()
            days_span_prev = (curr_start_date - prev_start_date).days + 1
            for day_offset in range(days_span_prev):
                slot_date = prev_start_date + timedelta(days=day_offset)
                slot_dt = datetime(slot_date.year, slot_date.month, slot_date.day, r_hour, r_min, tzinfo=timezone.utc)
                if slot_dt >= prev_start and slot_dt < current_start:
                    if slot_dt >= r_created - timedelta(minutes=5):
                        scheduled_count_prev += 1

        # Events in current period (deduplicated)
        curr_events_raw = (
            self.db.query(ReminderEvent)
            .filter(
                ReminderEvent.patient_id == patient_id,
                ReminderEvent.occurred_at >= current_start,
                ReminderEvent.occurred_at <= now,
            )
            .all()
        )
        seen_curr_events = set()
        curr_events = []
        for e in curr_events_raw:
            if e.id not in seen_curr_events:
                seen_curr_events.add(e.id)
                curr_events.append(e)

        # Events in previous period (deduplicated)
        prev_events_raw = (
            self.db.query(ReminderEvent)
            .filter(
                ReminderEvent.patient_id == patient_id,
                ReminderEvent.occurred_at >= prev_start,
                ReminderEvent.occurred_at < current_start,
            )
            .all()
        )
        seen_prev_events = set()
        prev_events = []
        for e in prev_events_raw:
            if e.id not in seen_prev_events:
                seen_prev_events.add(e.id)
                prev_events.append(e)

        completed_curr = sum(1 for e in curr_events if e.event_type == "acknowledged")
        snoozed_curr = sum(1 for e in curr_events if e.event_type == "snoozed")
        skipped_curr = sum(1 for e in curr_events if e.event_type == "missed")

        completed_prev = sum(1 for e in prev_events if e.event_type == "acknowledged")

        # Metric-specific minimum data rule: at least 1 scheduled reminder in each comparison period
        # Never divide by zero: scheduled = 0 -> INSUFFICIENT_DATA
        if scheduled_count_curr == 0:
            return ReminderAnalyticsResponse(
                patient_id=patient_id,
                period_days=period_days,
                scheduled_count=0,
                completed_count=completed_curr,
                snoozed_count=snoozed_curr,
                skipped_count=skipped_curr,
                adherence_rate=None,
                trend_direction="INSUFFICIENT_DATA",
                trend_observation="No scheduled reminders have occurred yet during this period.",
                data_sufficient=False,
            )

        adherence_rate_curr = min(100.0, round((completed_curr / float(scheduled_count_curr)) * 100.0, 1))

        # Adherence trend: requires at least 1 scheduled reminder in each comparison period
        trend_direction: TrendDirection = "INSUFFICIENT_DATA"
        sufficient = (scheduled_count_curr >= 1) and (scheduled_count_prev >= 1)

        if not sufficient:
            trend_obs = (
                f"{completed_curr} of {scheduled_count_curr} scheduled reminders completed. "
                "Insufficient previous reminder data for comparison."
            )
        else:
            adherence_rate_prev = min(100.0, round((completed_prev / float(scheduled_count_prev)) * 100.0, 1))
            diff = adherence_rate_curr - adherence_rate_prev

            if diff > 5.0:
                trend_direction = "IMPROVING"
                trend_obs = f"Reminder completion was higher ({adherence_rate_curr}% vs {adherence_rate_prev}%) than the previous period."
            elif diff < -5.0:
                trend_direction = "DECLINING"
                trend_obs = f"Reminder completion was lower ({adherence_rate_curr}% vs {adherence_rate_prev}%) than the previous period."
            else:
                trend_direction = "STABLE"
                trend_obs = f"Reminder completion remained steady ({adherence_rate_curr}%) during the selected period."

        return ReminderAnalyticsResponse(
            patient_id=patient_id,
            period_days=period_days,
            scheduled_count=scheduled_count_curr,
            completed_count=completed_curr,
            snoozed_count=snoozed_curr,
            skipped_count=skipped_curr,
            adherence_rate=adherence_rate_curr,
            trend_direction=trend_direction,
            trend_observation=trend_obs,
            data_sufficient=sufficient,
        )

    # =========================================================================
    # 4. OBSERVED TRENDS & REVIEW FLAGS
    # =========================================================================

    def get_observed_trends(self, patient_id: str, period_days: int) -> TrendsAnalyticsResponse:
        activity = self.get_activity_overview(patient_id, period_days)
        games = self.get_game_analytics(patient_id, period_days)
        reminders = self.get_reminder_analytics(patient_id, period_days)

        trends: List[ObservedTrendItem] = []
        review_flags: List[ReviewFlagItem] = []

        # Trend 1: Activity Participation
        trends.append(
            ObservedTrendItem(
                id="trend-participation",
                category="PARTICIPATION",
                title="Activity Participation",
                description=activity.trend_observation,
                direction=activity.participation_trend,
                period_days=period_days,
                status_type="NEUTRAL" if activity.participation_trend in ["INCREASED", "STABLE"] else "ATTENTION_RECOMMENDED" if activity.participation_trend == "DECREASED" else "INFO",
                data_basis=f"{activity.total_completed_activities} activities across {activity.active_days} active days",
            )
        )

        # Trend 2: Overall Game Performance
        trends.append(
            ObservedTrendItem(
                id="trend-games-overall",
                category="GAME_PERFORMANCE",
                title="Cognitive Game Performance",
                description=games.overall.trend_observation,
                direction=games.overall.accuracy_trend,
                period_days=period_days,
                status_type="NEUTRAL" if games.overall.accuracy_trend in ["IMPROVING", "STABLE"] else "ATTENTION_RECOMMENDED" if games.overall.accuracy_trend == "DECLINING" else "INFO",
                data_basis=f"{games.overall.sessions_completed} sessions recorded",
            )
        )

        # Trend 3: Reminder Adherence
        trends.append(
            ObservedTrendItem(
                id="trend-reminders",
                category="REMINDER_ADHERENCE",
                title="Routine Reminder Adherence",
                description=reminders.trend_observation,
                direction=reminders.trend_direction,
                period_days=period_days,
                status_type="NEUTRAL" if reminders.trend_direction in ["IMPROVING", "STABLE"] else "ATTENTION_RECOMMENDED" if reminders.trend_direction == "DECLINING" else "INFO",
                data_basis=(
                    f"{reminders.completed_count} of {reminders.scheduled_count} scheduled reminders confirmed"
                    if reminders.scheduled_count > 0
                    else "0 scheduled reminders"
                ),
            )
        )

        # Non-clinical Review Flags:
        # Flag 1: Low recent activity (if total < 2 in a 7+ day window)
        if activity.total_completed_activities < 2:
            review_flags.append(
                ReviewFlagItem(
                    id="flag-low-activity",
                    flag_type="ACTIVITY_ENGAGEMENT",
                    title="Low Recent Activity",
                    message="Activity has been lower than usual during the selected period. Caregiver review may be useful.",
                    status_type="ATTENTION_RECOMMENDED",
                    suggested_action="Consider introducing a gentle routine recall exercise at a comfortable pace.",
                )
            )

        # Flag 2: Game struggle observation (if accuracy < 60% or mistakes > 4)
        if games.overall.data_sufficient and games.overall.average_accuracy and games.overall.average_accuracy < 65.0:
            review_flags.append(
                ReviewFlagItem(
                    id="flag-game-comfort",
                    flag_type="GAME_COMFORT",
                    title="Game Exercise Comfort Observation",
                    message="Recent sessions showed lower accuracy. Maintaining gentle level 1 difficulty is recommended.",
                    status_type="ATTENTION_RECOMMENDED",
                    suggested_action="Ensure exercises are conducted in a quiet, relaxed setting with audio guidance.",
                )
            )

        # Flag 3: Reminder adherence review (if adherence rate < 70%)
        if reminders.data_sufficient and reminders.adherence_rate is not None and reminders.adherence_rate < 70.0:
            review_flags.append(
                ReviewFlagItem(
                    id="flag-reminder-adherence",
                    flag_type="REMINDER_SCHEDULE",
                    title="Reminder Adherence Observation",
                    message="Reminder completion was below 70% during the selected period.",
                    status_type="ATTENTION_RECOMMENDED",
                    suggested_action="Review routine timing with the patient to align with natural daily habits.",
                )
            )

        return TrendsAnalyticsResponse(
            patient_id=patient_id,
            period_days=period_days,
            trends=trends,
            review_flags=review_flags,
        )

    # =========================================================================
    # 5. SYNC HEALTH
    # =========================================================================

    def get_sync_health(self, patient_id: str) -> SyncHealthResponse:
        # Check SyncOperation records
        pending_ops = (
            self.db.query(SyncOperation)
            .filter(
                SyncOperation.patient_id == patient_id,
                SyncOperation.status == "pending",
            )
            .count()
        )

        last_op = (
            self.db.query(SyncOperation)
            .filter(SyncOperation.patient_id == patient_id)
            .order_by(desc(SyncOperation.processed_at))
            .first()
        )

        last_sync = last_op.processed_at if last_op else None

        if pending_ops > 0:
            status = "PENDING"
            label = f"{pending_ops} activities waiting to sync"
            err_msg = "Some recent activity has not synchronized yet."
        else:
            status = "UP_TO_DATE"
            label = "Up to date"
            err_msg = None

        return SyncHealthResponse(
            patient_id=patient_id,
            sync_status=status,
            status_label=label,
            pending_records_count=pending_ops,
            last_sync_at=last_sync,
            last_error_message=err_msg,
            is_offline_ready=True,
        )
