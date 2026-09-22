import React from 'react';
import {
  Menu,
  Search,
  Sun,
  Moon,
  User,
  ChevronDown,
  LogOut,
  Globe,
} from 'lucide-react';
import { PatientProfile } from '../api/client';
import { useTranslation } from '../context/LocalizationContext';

interface TopBarProps {
  onToggleSidebar: () => void;
  isDark: boolean;
  onToggleTheme: () => void;
  searchTerm: string;
  onSearchChange: (val: string) => void;
  selectedPatient: string;
  onPatientChange: (val: string) => void;
  caregiverName?: string;
  patients?: PatientProfile[];
  onLinkPatientClick?: () => void;
  onLogout?: () => void;
}

// Show only the 3 reviewed demo languages
const DEMO_LANGUAGES = ['en', 'hi', 'as'];

export const TopBar: React.FC<TopBarProps> = ({
  onToggleSidebar,
  isDark,
  onToggleTheme,
  searchTerm,
  onSearchChange,
  selectedPatient,
  onPatientChange,
  caregiverName,
  patients = [],
  onLogout,
}) => {
  const { currentLanguage, setLanguage, languages, t } = useTranslation();
  const demoLanguages = languages.filter((l) => DEMO_LANGUAGES.includes(l.code));

  return (
    <header className="topbar">
      <div className="topbar-left">
        <button
          className="topbar-toggle-btn"
          onClick={onToggleSidebar}
          aria-label="Toggle navigation menu"
        >
          <Menu size={20} />
        </button>

        {/* Patient Selector */}
        <div className="patient-selector-container">
          <label htmlFor="patient-select" className="patient-selector-label">
            {t('header.patient')}:
          </label>
          <div className="select-wrapper">
            <select
              id="patient-select"
              className="patient-selector-select"
              value={selectedPatient}
              onChange={(e) => onPatientChange(e.target.value)}
            >
              {patients.length > 0 ? (
                patients.map((p) => (
                  <option key={p.id} value={p.id}>
                    {p.anonymous_alias || `Patient (${p.id.slice(0, 8)})`}
                  </option>
                ))
              ) : (
                <option value="">No patients linked</option>
              )}
            </select>
            <ChevronDown size={14} className="select-chevron" />
          </div>
        </div>

        {/* Search */}
        <div className="search-box">
          <Search size={15} className="search-icon" />
          <input
            type="text"
            placeholder={t('common.search')}
            value={searchTerm}
            onChange={(e) => onSearchChange(e.target.value)}
            className="search-input"
          />
        </div>
      </div>

      <div className="topbar-right">
        {/* Language Selector — 3 demo languages */}
        <div className="select-wrapper" style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
          <Globe size={15} style={{ color: 'var(--text-muted)' }} />
          <select
            aria-label="Language"
            value={currentLanguage}
            onChange={(e) => setLanguage(e.target.value)}
            className="patient-selector-select"
            style={{ fontSize: '12px', padding: '4px 22px 4px 6px' }}
          >
            {demoLanguages.map((lang) => (
              <option key={lang.code} value={lang.code}>
                {lang.nativeName}
              </option>
            ))}
          </select>
          <ChevronDown size={12} className="select-chevron" />
        </div>

        {/* Sync Status — Simple dot + text */}
        <div className="sync-badge">
          <span className="sync-dot" />
          <span>{t('header.syncActive')}</span>
        </div>

        {/* Theme Toggle */}
        <button
          className="theme-toggle-btn"
          onClick={onToggleTheme}
          title={isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
          aria-label="Toggle color theme"
        >
          {isDark ? <Sun size={16} /> : <Moon size={16} />}
        </button>

        {/* Caregiver Profile & Logout */}
        <div className="user-profile-badge" style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
          <div className="avatar-circle">
            <User size={16} />
          </div>
          <div className="user-info">
            <span className="user-name">{caregiverName || 'Caregiver'}</span>
            <span className="user-role">{t('header.role')}</span>
          </div>
          {onLogout && (
            <button
              type="button"
              onClick={onLogout}
              style={{
                marginLeft: '4px',
                padding: '5px 8px',
                border: '1px solid var(--border-subtle)',
                background: 'transparent',
                cursor: 'pointer',
                display: 'flex',
                alignItems: 'center',
                gap: '4px',
                color: 'var(--text-muted)',
                borderRadius: '6px',
                fontSize: '12px',
              }}
              title="Sign Out"
            >
              <LogOut size={13} />
              <span>{t('header.signOut')}</span>
            </button>
          )}
        </div>
      </div>
    </header>
  );
};
