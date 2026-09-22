import React from 'react';
import { Activity, Loader2 } from 'lucide-react';
import {
  ResponsiveContainer,
  BarChart,
  Bar,
  XAxis,
  YAxis,
  Tooltip,
  CartesianGrid,
  Legend,
} from 'recharts';
import { ActivityOverviewResponse, GameSessionRow } from '../api/client';

interface ActivityOverviewProps {
  activityData?: ActivityOverviewResponse | null;
  liveSessions?: GameSessionRow[];
  periodDays?: number;
  isLoading?: boolean;
}

export const ActivityOverview: React.FC<ActivityOverviewProps> = ({
  activityData,
  liveSessions = [],
  isLoading = false,
}) => {
  // Combine dailySeries with liveSessions so real completed activities are shown on the chart
  const seriesMap: Record<string, { dateKey: string; date: string; Games: number; Reminders: number; Total: number }> = {};

  (activityData?.daily_series ?? []).forEach((dp) => {
    const parts = dp.date.split('-');
    const label = parts.length === 3 ? `${parts[1]}/${parts[2]}` : dp.date;
    seriesMap[dp.date] = {
      dateKey: dp.date,
      date: label,
      Games: dp.game_sessions,
      Reminders: dp.reminders_completed,
      Total: dp.total,
    };
  });

  // Ensure sessions in liveSessions appear on their completion date
  liveSessions.forEach((s) => {
    if (!s.completed_at) return;
    const sDate = s.completed_at.slice(0, 10);
    if (!seriesMap[sDate]) {
      const parts = sDate.split('-');
      const label = parts.length === 3 ? `${parts[1]}/${parts[2]}` : sDate;
      seriesMap[sDate] = {
        dateKey: sDate,
        date: label,
        Games: 0,
        Reminders: 0,
        Total: 0,
      };
    }
    seriesMap[sDate].Games = Math.max(seriesMap[sDate].Games, 1);
    seriesMap[sDate].Total = seriesMap[sDate].Games + seriesMap[sDate].Reminders;
  });

  // Sort by dateKey ascending
  const chartData = Object.values(seriesMap).sort((a, b) => a.dateKey.localeCompare(b.dateKey));
  const hasData = chartData.some((dp) => dp.Total > 0);

  return (
    <div className="card activity-overview-card">
      <div className="card-header-flex">
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div className="stat-icon-wrapper sage" style={{ width: '36px', height: '36px' }}>
            <Activity size={20} />
          </div>
          <div>
            <h3 className="section-title">Activity This Week</h3>
            <p className="section-subtitle">Daily cognitive exercises and routine reminders</p>
          </div>
        </div>
      </div>

      {/* Participation Timeline Chart (Recharts) */}
      <div style={{ height: '240px', width: '100%', marginTop: '16px' }}>
        {isLoading ? (
          <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', height: '100%', color: 'var(--text-muted)', gap: '8px' }}>
            <Loader2 size={24} style={{ animation: 'spin 1s linear infinite' }} />
            <span style={{ fontSize: '13px' }}>Loading activity chart...</span>
          </div>
        ) : chartData.length > 0 && hasData ? (
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={chartData} margin={{ top: 10, right: 10, left: -20, bottom: 0 }}>
              <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="var(--border-subtle)" />
              <XAxis dataKey="date" tick={{ fontSize: 12, fill: 'var(--text-muted)' }} axisLine={false} tickLine={false} />
              <YAxis allowDecimals={false} tick={{ fontSize: 12, fill: 'var(--text-muted)' }} axisLine={false} tickLine={false} />
              <Tooltip
                contentStyle={{
                  backgroundColor: 'var(--bg-surface)',
                  borderColor: 'var(--border-subtle)',
                  borderRadius: '8px',
                  fontSize: '12px',
                  color: 'var(--text-main)',
                  boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)',
                }}
              />
              <Legend wrapperStyle={{ fontSize: '12px', paddingTop: '8px' }} />
              <Bar dataKey="Games" name="Games" fill="var(--color-sage, #3b7a57)" radius={[4, 4, 0, 0]} stackId="a" />
              <Bar dataKey="Reminders" name="Reminders" fill="#60a5fa" radius={[4, 4, 0, 0]} stackId="a" />
            </BarChart>
          </ResponsiveContainer>
        ) : (
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'center', height: '100%', color: 'var(--text-muted)', fontSize: '14px' }}>
            Not enough activity data for a reliable trend.
          </div>
        )}
      </div>
    </div>
  );
};
