import React from 'react';
import { Brain, Sparkles, ListChecks, LucideIcon, Loader2 } from 'lucide-react';
import { GameSessionRow } from '../api/client';

interface SessionRow {
  id: string;
  gameType: string;
  gameIcon: LucideIcon;
  score: number;
  accuracy: number;
  dateTime: string;
}

function getIconForGame(gameType: string): LucideIcon {
  const clean = gameType.toLowerCase();
  if (clean.includes('match')) return Brain;
  if (clean.includes('pattern')) return Sparkles;
  return ListChecks;
}

function formatGameName(gameType: string): string {
  if (gameType === 'memory_match' || gameType.toLowerCase() === 'memory match') return 'Memory Match';
  if (gameType === 'pattern_recognition' || gameType.toLowerCase() === 'pattern recognition') return 'Pattern Recognition';
  return gameType.replace(/_/g, ' ').replace(/\b\w/g, (c) => c.toUpperCase());
}

export const RecentSessionsTable: React.FC<{
  filterQuery?: string;
  liveSessions?: GameSessionRow[];
  isLoading?: boolean;
}> = ({ filterQuery = '', liveSessions = [], isLoading = false }) => {
  const displaySessions: SessionRow[] = (liveSessions || []).map((s) => ({
    id: s.id || s.local_id,
    gameType: formatGameName(s.game_type),
    gameIcon: getIconForGame(s.game_type),
    score: s.score ?? 0,
    accuracy: Math.round(s.accuracy <= 1.0 ? s.accuracy * 100 : s.accuracy),
    dateTime: new Date(s.completed_at).toLocaleDateString(undefined, {
      month: 'short',
      day: 'numeric',
      hour: '2-digit',
      minute: '2-digit',
    }),
  }));

  const filtered = displaySessions.filter(
    (s) => s.gameType.toLowerCase().includes(filterQuery.toLowerCase())
  );

  return (
    <div className="card table-card">
      <div className="card-header-flex">
        <div>
          <h3 className="section-title">Recent Cognitive Activity</h3>
        </div>
        {!isLoading && filtered.length > 0 && (
          <span className="badge-tag">{filtered.length} {filtered.length === 1 ? 'activity' : 'activities'}</span>
        )}
      </div>

      {isLoading ? (
        <div
          style={{
            padding: '40px 16px',
            textAlign: 'center',
            color: 'var(--text-muted)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
          }}
        >
          <Loader2 size={24} className="animate-spin text-sage" style={{ animation: 'spin 1s linear infinite' }} />
          <p style={{ margin: 0, fontSize: '14px', color: 'var(--text-muted)' }}>
            Loading cognitive activity records...
          </p>
        </div>
      ) : filtered.length === 0 ? (
        <div
          style={{
            padding: '36px 16px',
            textAlign: 'center',
            color: 'var(--text-muted)',
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            justifyContent: 'center',
            gap: '8px',
          }}
        >
          <div className="stat-icon-wrapper sage" style={{ width: '44px', height: '44px', marginBottom: '4px' }}>
            <ListChecks size={24} />
          </div>
          <p style={{ margin: 0, fontSize: '15px', fontWeight: 600, color: 'var(--text-main)' }}>
            No recent activity recorded yet.
          </p>
          <p style={{ margin: 0, fontSize: '13px', color: 'var(--text-muted)' }}>
            Patient exercise sessions will appear here automatically.
          </p>
        </div>
      ) : (
        <div className="table-responsive">
          <table className="sessions-table">
            <thead>
              <tr>
                <th>Exercise</th>
                <th>Score</th>
                <th>Accuracy</th>
                <th>Date & Time</th>
              </tr>
            </thead>
            <tbody>
              {filtered.map((row) => {
                const Icon = row.gameIcon;
                return (
                  <tr key={row.id}>
                    <td>
                      <div className="table-exercise-cell">
                        <div className="cell-icon">
                          <Icon size={16} />
                        </div>
                        <span className="font-semibold">{row.gameType}</span>
                      </div>
                    </td>
                    <td>
                      <span className="font-semibold" style={{ color: 'var(--color-primary-dark, var(--text-main))' }}>
                        {row.score}
                      </span>
                    </td>
                    <td>
                      <span className="accuracy-badge success">{row.accuracy}%</span>
                    </td>
                    <td className="text-muted">{row.dateTime}</td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
};
