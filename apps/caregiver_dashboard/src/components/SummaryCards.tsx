import React from 'react';
import { CheckCircle2, Clock, Flame, ShieldCheck } from 'lucide-react';
import {
  ActivityOverviewResponse,
  GamesAnalyticsResponse,
  GameSessionRow,
  ReminderAnalyticsResponse,
  SyncHealthResponse,
} from '../api/client';

interface SummaryCardsProps {
  activityData?: ActivityOverviewResponse | null;
  gamesData?: GamesAnalyticsResponse | null;
  remindersData?: ReminderAnalyticsResponse | null;
  syncData?: SyncHealthResponse | null;
  liveSessions?: GameSessionRow[];
  isLoading?: boolean;
}

export const SummaryCards: React.FC<SummaryCardsProps> = ({
  activityData,
  gamesData,
  syncData,
  liveSessions = [],
  isLoading = false,
}) => {
  // Activities completed: use API overview or derived from verified live sessions
  const completedActivities =
    activityData?.total_completed_activities !== undefined && activityData?.total_completed_activities !== null
      ? activityData.total_completed_activities
      : (liveSessions.length > 0 ? liveSessions.length : (isLoading ? '...' : 0));

  // Average Accuracy: API returns float 0.0-1.0 (e.g. 0.7 for 70%)
  const rawAccuracy =
    gamesData?.overall.average_accuracy !== null && gamesData?.overall.average_accuracy !== undefined
      ? gamesData.overall.average_accuracy
      : (liveSessions.length > 0
          ? liveSessions.reduce((sum, s) => sum + s.accuracy, 0) / liveSessions.length
          : null);

  const avgAccuracy =
    rawAccuracy !== null && rawAccuracy !== undefined
      ? `${Math.round(rawAccuracy <= 1.0 ? rawAccuracy * 100 : rawAccuracy)}%`
      : (isLoading ? '...' : 'N/A');

  const streakDays = activityData?.longest_streak_days ?? 0;

  const isSynced = !syncData || syncData.sync_status === 'UP_TO_DATE';
  const syncLabel = isSynced ? 'Synced' : 'Pending';

  return (
    <div className="stats-grid">
      <div className="card stat-card">
        <div className="stat-icon-wrapper sage">
          <CheckCircle2 size={22} />
        </div>
        <div className="stat-content">
          <div className="card-title">Activities Completed</div>
          <div className="card-value">{isLoading && completedActivities === 0 ? '...' : completedActivities}</div>
          <p className="card-subtext success">This week</p>
        </div>
      </div>

      <div className="card stat-card">
        <div className="stat-icon-wrapper blue">
          <Clock size={22} />
        </div>
        <div className="stat-content">
          <div className="card-title">Average Accuracy</div>
          <div className="card-value">{avgAccuracy}</div>
          <p className="card-subtext muted">Across recent activities</p>
        </div>
      </div>

      <div className="card stat-card">
        <div className="stat-icon-wrapper amber">
          <Flame size={22} />
        </div>
        <div className="stat-content">
          <div className="card-title">Current Streak</div>
          <div className="card-value">
            {isLoading && !activityData ? '...' : `${streakDays} ${streakDays === 1 ? 'day' : 'days'}`}
          </div>
          <p className="card-subtext success">Daily activity recorded</p>
        </div>
      </div>

      <div className="card stat-card">
        <div className="stat-icon-wrapper green">
          <ShieldCheck size={22} />
        </div>
        <div className="stat-content">
          <div className="card-title">Sync Status</div>
          <div className="card-value status-text-value">{syncLabel}</div>
          <p className="card-subtext muted">{isSynced ? 'Data is up to date' : 'Sync in progress'}</p>
        </div>
      </div>
    </div>
  );
};
