import React from 'react';
import { Brain, Sparkles, ListChecks, TrendingUp, TrendingDown, Minus, LucideIcon } from 'lucide-react';
import { GamesAnalyticsResponse, GameMetricSummary } from '../api/client';

interface GamePerformanceProps {
  gamesData?: GamesAnalyticsResponse | null;
  selectedGameType: string;
  onSelectGameType: (gameType: string) => void;
}

function getIconForGame(gameType: string): LucideIcon {
  const clean = gameType.toLowerCase();
  if (clean.includes('match')) return Brain;
  if (clean.includes('pattern')) return Sparkles;
  return ListChecks;
}

export const GamePerformance: React.FC<GamePerformanceProps> = ({
  gamesData,
  selectedGameType,
  onSelectGameType,
}) => {
  const overall: GameMetricSummary | undefined = gamesData?.overall;
  const gamesList: GameMetricSummary[] = gamesData?.games || [];

  const renderTrendBadge = (trend: string, label: string) => {
    if (trend === 'IMPROVING') {
      return (
        <span className="status-pill success" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
          <TrendingUp size={14} />
          <span>{label}: Improving</span>
        </span>
      );
    }
    if (trend === 'DECLINING') {
      return (
        <span className="status-pill pending" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
          <TrendingDown size={14} />
          <span>{label}: Lower</span>
        </span>
      );
    }
    if (trend === 'STABLE') {
      return (
        <span className="status-pill neutral" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
          <Minus size={14} />
          <span>{label}: Steady</span>
        </span>
      );
    }
    return (
      <span className="status-pill neutral" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
        <span>{label}: Insufficient Data</span>
      </span>
    );
  };

  return (
    <div className="card game-performance-card" style={{ marginBottom: '24px' }}>
      <div className="card-header-flex">
        <div>
          <h3 className="section-title">Cognitive Game Performance</h3>
          <p className="section-subtitle">
            Gentle exercise metrics, accuracy trends, and response pacing observations
          </p>
        </div>
        <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
          <span className="badge-outline">All Level 1 (Gentle)</span>
        </div>
      </div>

      {/* Game Type Filter Tabs */}
      <div style={{ display: 'flex', gap: '8px', marginBottom: '20px', flexWrap: 'wrap' }}>
        {['all', 'Memory Match', 'Pattern Recognition', 'Daily Routine Recall'].map((gType) => (
          <button
            key={gType}
            type="button"
            className={`btn ${selectedGameType === gType ? 'btn-primary' : 'btn-secondary'}`}
            style={{ fontSize: '13px', padding: '6px 14px' }}
            onClick={() => onSelectGameType(gType)}
          >
            {gType === 'all' ? 'All Games' : gType}
          </button>
        ))}
      </div>

      {/* Overall Performance Metrics */}
      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(180px, 1fr))',
          gap: '12px',
          marginBottom: '20px',
          padding: '16px',
          background: 'var(--bg-app)',
          borderRadius: '10px',
          border: '1px solid var(--border-subtle)',
        }}
      >
        <div>
          <span className="detail-label">Completed Sessions</span>
          <div style={{ fontSize: '22px', fontWeight: 600, color: 'var(--text-main)', marginTop: '4px' }}>
            {overall ? overall.sessions_completed : 0}
          </div>
        </div>
        <div>
          <span className="detail-label">Average Accuracy</span>
          <div style={{ fontSize: '22px', fontWeight: 600, color: 'var(--color-sage-dark)', marginTop: '4px' }}>
            {overall?.average_accuracy !== null && overall?.average_accuracy !== undefined
              ? `${Math.round(overall.average_accuracy <= 1.0 ? overall.average_accuracy * 100 : overall.average_accuracy)}%`
              : 'N/A'}
          </div>
        </div>
        <div>
          <span className="detail-label">Average Mistakes</span>
          <div style={{ fontSize: '22px', fontWeight: 600, color: 'var(--text-main)', marginTop: '4px' }}>
            {overall?.average_mistakes !== null && overall?.average_mistakes !== undefined
              ? overall.average_mistakes
              : 'N/A'}
          </div>
        </div>
        <div>
          <span className="detail-label">Average Response Time</span>
          <div style={{ fontSize: '22px', fontWeight: 600, color: 'var(--text-main)', marginTop: '4px' }}>
            {overall?.average_response_time_ms
              ? `${(overall.average_response_time_ms / 1000).toFixed(1)}s`
              : 'N/A'}
          </div>
        </div>
      </div>

      {/* Trend Indicators & Observations */}
      <div style={{ marginBottom: '20px', display: 'flex', flexDirection: 'column', gap: '8px' }}>
        <div style={{ display: 'flex', gap: '8px', flexWrap: 'wrap' }}>
          {overall && renderTrendBadge(overall.accuracy_trend, 'Accuracy')}
          {overall && renderTrendBadge(overall.mistakes_trend, 'Mistakes')}
          {overall?.response_time_trend && overall.response_time_trend !== 'INSUFFICIENT_DATA' &&
            renderTrendBadge(overall.response_time_trend, 'Pacing')}
        </div>

        {overall?.trend_observation && (
          <p style={{ fontSize: '14px', color: 'var(--text-main)', margin: '4px 0' }}>
            {overall.trend_observation}
          </p>
        )}

        {overall?.hint_usage_observation && (
          <p style={{ fontSize: '13px', color: 'var(--text-muted)', margin: 0 }}>
            {overall.hint_usage_observation}
          </p>
        )}
      </div>

      {/* Per-Game Mini Cards */}
      <div className="activity-cards-grid">
        {gamesList.map((g) => {
          const Icon = getIconForGame(g.game_type);
          const rawAcc = g.average_accuracy ?? 0;
          const acc = Math.round(rawAcc <= 1.0 ? rawAcc * 100 : rawAcc);
          return (
            <div key={g.game_type} className="activity-mini-card">
              <div className="mini-card-top">
                <div className="mini-card-icon">
                  <Icon size={20} />
                </div>
                <div className="mini-card-meta">
                  <div className="mini-card-title">{g.game_type}</div>
                  <div className="mini-card-tag">Level 1 (Gentle)</div>
                </div>
              </div>

              <div className="mini-card-stats">
                <div className="metric-row">
                  <span className="metric-label">Completed</span>
                  <span className="metric-num">{g.sessions_completed} sessions</span>
                </div>
                <div className="metric-row">
                  <span className="metric-label">Avg. Accuracy</span>
                  <span className="metric-num font-semibold">
                    {g.average_accuracy !== null && g.average_accuracy !== undefined
                      ? `${Math.round(g.average_accuracy <= 1.0 ? g.average_accuracy * 100 : g.average_accuracy)}%`
                      : 'N/A'}
                  </span>
                </div>
                <div className="metric-row">
                  <span className="metric-label">Avg. Mistakes</span>
                  <span className="metric-num">
                    {g.average_mistakes !== null && g.average_mistakes !== undefined ? g.average_mistakes : 'N/A'}
                  </span>
                </div>
              </div>

              <div className="progress-bar-container">
                <div
                  className="progress-bar-fill"
                  style={{ width: `${acc}%` }}
                />
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
