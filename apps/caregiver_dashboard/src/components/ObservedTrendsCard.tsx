import React from 'react';
import { Info, Sparkles, AlertCircle, TrendingUp, TrendingDown, Minus } from 'lucide-react';
import { TrendsAnalyticsResponse, ObservedTrendItem, ReviewFlagItem } from '../api/client';

interface ObservedTrendsCardProps {
  trendsData?: TrendsAnalyticsResponse | null;
  periodDays: number;
}

export const ObservedTrendsCard: React.FC<ObservedTrendsCardProps> = ({
  trendsData,
  periodDays,
}) => {
  const trends: ObservedTrendItem[] = trendsData?.trends || [];
  const reviewFlags: ReviewFlagItem[] = trendsData?.review_flags || [];
  const disclaimer =
    trendsData?.clinical_disclaimer ||
    'SMRITI is a non-diagnostic platform. All observations describe recorded application activity and routine completion. SMRITI does not provide clinical diagnoses, dementia severity ratings, disease progression predictions, or medication recommendations.';

  const renderTrendDirectionBadge = (dir: string) => {
    if (dir === 'INCREASED' || dir === 'IMPROVING') {
      return (
        <span className="status-pill success" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
          <TrendingUp size={13} />
          <span>{dir}</span>
        </span>
      );
    }
    if (dir === 'DECREASED' || dir === 'DECLINING') {
      return (
        <span className="status-pill pending" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
          <TrendingDown size={13} />
          <span>{dir}</span>
        </span>
      );
    }
    if (dir === 'STABLE') {
      return (
        <span className="status-pill neutral" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
          <Minus size={13} />
          <span>{dir}</span>
        </span>
      );
    }
    return (
      <span className="status-pill neutral" style={{ display: 'inline-flex', alignItems: 'center', gap: '4px' }}>
        <span>INSUFFICIENT_DATA</span>
      </span>
    );
  };

  return (
    <div className="card trends-card" style={{ marginBottom: '24px' }}>
      <div className="card-header-flex">
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <Sparkles size={20} className="text-sage" />
          <h3 className="section-title">Observed Activity Trends ({periodDays}-Day Window)</h3>
        </div>
        <span className="badge-outline">Deterministic Engine</span>
      </div>

      <div className="trends-body">
        {/* Observed Trends List */}
        <div style={{ display: 'flex', flexDirection: 'column', gap: '12px', marginBottom: '20px' }}>
          {trends.length > 0 ? (
            trends.map((t) => (
              <div
                key={t.id}
                style={{
                  padding: '14px 16px',
                  borderRadius: '8px',
                  background: 'var(--bg-app)',
                  border: '1px solid var(--border-subtle)',
                }}
              >
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '6px' }}>
                  <span style={{ fontWeight: 600, fontSize: '14.5px', color: 'var(--text-main)' }}>
                    {t.title}
                  </span>
                  {renderTrendDirectionBadge(t.direction)}
                </div>
                <p style={{ margin: '0 0 6px 0', fontSize: '13.5px', color: 'var(--text-main)', lineHeight: 1.5 }}>
                  {t.description}
                </p>
                <span style={{ fontSize: '12px', color: 'var(--text-muted)' }}>
                  Data basis: {t.data_basis}
                </span>
              </div>
            ))
          ) : (
            <div style={{ padding: '16px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '14px' }}>
              Not enough activity data to show a reliable trend.
            </div>
          )}
        </div>

        {/* Non-Clinical Review Flags */}
        {reviewFlags.length > 0 && (
          <div style={{ marginBottom: '20px' }}>
            <h4 style={{ fontSize: '14px', fontWeight: 600, color: 'var(--text-main)', marginBottom: '10px' }}>
              Caregiver Review Flags (Non-Clinical)
            </h4>
            <div style={{ display: 'flex', flexDirection: 'column', gap: '10px' }}>
              {reviewFlags.map((flag) => (
                <div
                  key={flag.id}
                  style={{
                    display: 'flex',
                    gap: '12px',
                    padding: '12px 14px',
                    borderRadius: '8px',
                    background: '#fffbeb',
                    border: '1px solid #fef3c7',
                    color: '#92400e',
                  }}
                >
                  <AlertCircle size={18} style={{ flexShrink: 0, marginTop: '2px', color: '#b45309' }} />
                  <div>
                    <div style={{ fontWeight: 600, fontSize: '13.5px' }}>{flag.title}</div>
                    <div style={{ fontSize: '13px', marginTop: '2px' }}>{flag.message}</div>
                    <div style={{ fontSize: '12px', marginTop: '4px', fontStyle: 'italic', color: '#78350f' }}>
                      Suggested: {flag.suggested_action}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}

        {/* Clinical Transparency Notice */}
        <div className="transparency-notice-box">
          <Info size={18} className="notice-icon" />
          <div className="notice-text">
            <strong>Non-Diagnostic Disclaimer:</strong> {disclaimer} If you have medical concerns, please consult a qualified healthcare professional.
          </div>
        </div>
      </div>
    </div>
  );
};
