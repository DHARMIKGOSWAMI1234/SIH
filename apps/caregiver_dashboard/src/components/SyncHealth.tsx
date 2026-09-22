import React from 'react';
import { ShieldCheck, RefreshCw, AlertTriangle, Clock } from 'lucide-react';
import { SyncHealthResponse } from '../api/client';

interface SyncHealthProps {
  syncData?: SyncHealthResponse | null;
  onRefresh?: () => void;
}

export const SyncHealth: React.FC<SyncHealthProps> = ({ syncData, onRefresh }) => {
  const status = syncData?.sync_status || 'UP_TO_DATE';
  const label = syncData?.status_label || 'Up to date';
  const pendingCount = syncData?.pending_records_count || 0;
  const lastSync = syncData?.last_sync_at
    ? new Date(syncData.last_sync_at).toLocaleString([], {
        month: 'short',
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit',
      })
    : 'Recently';

  const renderStatusBadge = () => {
    switch (status) {
      case 'UP_TO_DATE':
        return (
          <span className="status-pill success" style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
            <ShieldCheck size={14} />
            <span>Up to Date</span>
          </span>
        );
      case 'PENDING':
        return (
          <span className="status-pill pending" style={{ display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
            <Clock size={14} />
            <span>{pendingCount} Pending Sync</span>
          </span>
        );
      case 'ATTENTION_NEEDED':
        return (
          <span className="status-pill" style={{ display: 'inline-flex', alignItems: 'center', gap: '6px', background: '#fef2f2', color: '#991b1b', border: '1px solid #fecaca' }}>
            <AlertTriangle size={14} />
            <span>Sync Attention Recommended</span>
          </span>
        );
      default:
        return (
          <span className="status-pill neutral">
            <span>{label}</span>
          </span>
        );
    }
  };

  return (
    <div className="card sync-health-card" style={{ marginBottom: '24px' }}>
      <div className="card-header-flex">
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div className="stat-icon-wrapper green" style={{ width: '36px', height: '36px' }}>
            <ShieldCheck size={20} />
          </div>
          <div>
            <h3 className="section-title">Data Synchronization Health</h3>
            <p className="section-subtitle">
              Encrypted SQLite to PostgreSQL sync state and local cache integrity
            </p>
          </div>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          {renderStatusBadge()}
          {onRefresh && (
            <button
              type="button"
              className="btn btn-secondary"
              onClick={onRefresh}
              style={{ padding: '6px 10px', fontSize: '12px', display: 'flex', alignItems: 'center', gap: '4px' }}
              title="Refresh sync status"
            >
              <RefreshCw size={12} />
              <span>Refresh</span>
            </button>
          )}
        </div>
      </div>

      <div
        style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(auto-fit, minmax(200px, 1fr))',
          gap: '12px',
          marginTop: '16px',
          padding: '12px 16px',
          background: 'var(--bg-app)',
          borderRadius: '8px',
          border: '1px solid var(--border-subtle)',
        }}
      >
        <div>
          <span className="detail-label">Status Summary</span>
          <div style={{ fontSize: '15px', fontWeight: 600, color: 'var(--text-main)', marginTop: '2px' }}>
            {label}
          </div>
        </div>
        <div>
          <span className="detail-label">Last Synchronization</span>
          <div style={{ fontSize: '15px', fontWeight: 600, color: 'var(--text-main)', marginTop: '2px' }}>
            {lastSync}
          </div>
        </div>
        <div>
          <span className="detail-label">Offline-First Architecture</span>
          <div style={{ fontSize: '15px', fontWeight: 600, color: 'var(--color-sage-dark)', marginTop: '2px' }}>
            Active (Encrypted Local Cache)
          </div>
        </div>
      </div>

      {syncData?.last_error_message && (
        <div
          style={{
            marginTop: '12px',
            padding: '10px 14px',
            borderRadius: '6px',
            background: '#fef2f2',
            border: '1px solid #fecaca',
            color: '#991b1b',
            fontSize: '13px',
          }}
        >
          <strong>Sync Notice:</strong> {syncData.last_error_message}
        </div>
      )}
    </div>
  );
};
