import React from 'react';
import {
  LayoutDashboard,
  Activity,
  Brain,
  Clock,
  Settings,
  Shield,
  X,
  LucideIcon,
} from 'lucide-react';
import { useTranslation } from '../context/LocalizationContext';

export type NavTab =
  | 'overview'
  | 'patients'
  | 'activity'
  | 'memory'
  | 'reminders'
  | 'progress'
  | 'sync'
  | 'settings';

interface SidebarProps {
  activeTab: NavTab;
  onTabChange: (tab: NavTab) => void;
  isOpen: boolean;
  onClose: () => void;
}

// Primary demo navigation — only these appear in the sidebar
const mainNavItems: { id: NavTab; key: string; icon: LucideIcon }[] = [
  { id: 'overview', key: 'nav.overview', icon: LayoutDashboard },
  { id: 'activity', key: 'nav.activity', icon: Activity },
  { id: 'memory', key: 'nav.memory', icon: Brain },
  { id: 'reminders', key: 'nav.reminders', icon: Clock },
];

const accountNavItems: { id: NavTab; key: string; icon: LucideIcon }[] = [
  { id: 'settings', key: 'nav.settings', icon: Settings },
];

export const Sidebar: React.FC<SidebarProps> = ({
  activeTab,
  onTabChange,
  isOpen,
  onClose,
}) => {
  const { t } = useTranslation();

  return (
    <>
      {/* Mobile overlay */}
      {isOpen && <div className="sidebar-overlay" onClick={onClose} />}

      <aside className={`sidebar ${isOpen ? 'sidebar-open' : ''}`}>
        <div className="sidebar-header">
          <div className="brand-badge">
            <div className="brand-icon">
              <Shield size={18} />
            </div>
            <div>
              <div className="brand-title">BANDHU</div>
              <div className="brand-subtitle">Caregiver Portal</div>
            </div>
          </div>
          <button className="sidebar-close-btn" onClick={onClose} aria-label="Close menu">
            <X size={20} />
          </button>
        </div>

        <div className="sidebar-section-label">MAIN</div>

        <nav className="sidebar-nav">
          {mainNavItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                className={`sidebar-nav-item ${isActive ? 'active' : ''}`}
                onClick={() => {
                  onTabChange(item.id);
                  onClose();
                }}
              >
                <Icon size={18} className="nav-icon" />
                <span>{t(item.key)}</span>
              </button>
            );
          })}

          <div className="sidebar-section-label" style={{ padding: '16px 8px 8px' }}>ACCOUNT</div>

          {accountNavItems.map((item) => {
            const Icon = item.icon;
            const isActive = activeTab === item.id;
            return (
              <button
                key={item.id}
                className={`sidebar-nav-item ${isActive ? 'active' : ''}`}
                onClick={() => {
                  onTabChange(item.id);
                  onClose();
                }}
              >
                <Icon size={18} className="nav-icon" />
                <span>{t(item.key)}</span>
              </button>
            );
          })}
        </nav>

        <div className="sidebar-footer">
          <div className="system-status-indicator">
            <span className="status-dot online" />
            <span className="status-label">Synced</span>
          </div>
        </div>
      </aside>
    </>
  );
};
