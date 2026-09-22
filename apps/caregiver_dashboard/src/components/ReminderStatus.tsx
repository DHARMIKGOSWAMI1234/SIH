import React from 'react';
import { CheckCircle2, Clock, CalendarCheck } from 'lucide-react';
import { ReminderAnalyticsResponse, ReminderItem } from '../api/client';

interface ReminderStatusProps {
  remindersData?: ReminderAnalyticsResponse | null;
  remindersList?: ReminderItem[];
  periodDays?: number;
}

export const ReminderStatus: React.FC<ReminderStatusProps> = ({
  remindersList = [],
}) => {
  return (
    <div className="card reminder-card">
      <div className="card-header-flex">
        <div style={{ display: 'flex', alignItems: 'center', gap: '10px' }}>
          <div className="stat-icon-wrapper amber" style={{ width: '36px', height: '36px' }}>
            <CalendarCheck size={20} />
          </div>
          <div>
            <h3 className="section-title">Today's Reminders</h3>
            <p className="section-subtitle">Active daily routine and habit schedule</p>
          </div>
        </div>
      </div>

      {/* Active Daily Schedule List */}
      <div className="reminders-list" style={{ marginTop: '16px' }}>
        {remindersList.length > 0 ? (
          remindersList.map((r) => (
            <div key={r.id || r.local_id} className="reminder-item-row">
              <div className="reminder-status-icon">
                {r.enabled ? (
                  <CheckCircle2 size={20} className="text-success" />
                ) : (
                  <Clock size={20} className="text-muted" />
                )}
              </div>
              <div className="reminder-meta">
                <span className={`reminder-title ${!r.enabled ? 'acknowledged' : ''}`}>
                  {r.title}
                </span>
                <div className="reminder-sub-row">
                  <span className="reminder-time">{r.scheduled_time}</span>
                  <span className="reminder-category-pill">{r.reminder_type}</span>
                </div>
              </div>
              <div className="reminder-action">
                <span className={`status-pill ${r.enabled ? 'success' : 'neutral'}`}>
                  {r.enabled ? 'Active Daily' : 'Disabled'}
                </span>
              </div>
            </div>
          ))
        ) : (
          <div style={{ padding: '24px 16px', textAlign: 'center', color: 'var(--text-muted)', fontSize: '14px' }}>
            No scheduled reminders configured for this patient.
          </div>
        )}
      </div>
    </div>
  );
};
