import React, { useState } from 'react';
import { Sidebar, NavTab } from './Sidebar';
import { TopBar } from './TopBar';
import { PatientProfile } from '../api/client';

interface AppLayoutProps {
  children: React.ReactNode;
  activeTab: NavTab;
  onTabChange: (tab: NavTab) => void;
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

export const AppLayout: React.FC<AppLayoutProps> = ({
  children,
  activeTab,
  onTabChange,
  isDark,
  onToggleTheme,
  searchTerm,
  onSearchChange,
  selectedPatient,
  onPatientChange,
  caregiverName,
  patients,
  onLinkPatientClick,
  onLogout,
}) => {
  const [sidebarOpen, setSidebarOpen] = useState(false);

  return (
    <div className={`app-container ${isDark ? 'theme-dark' : 'theme-light'}`}>
      <Sidebar
        activeTab={activeTab}
        onTabChange={onTabChange}
        isOpen={sidebarOpen}
        onClose={() => setSidebarOpen(false)}
      />

      <div className="content-wrapper">
        <TopBar
          onToggleSidebar={() => setSidebarOpen(!sidebarOpen)}
          isDark={isDark}
          onToggleTheme={onToggleTheme}
          searchTerm={searchTerm}
          onSearchChange={onSearchChange}
          selectedPatient={selectedPatient}
          onPatientChange={onPatientChange}
          caregiverName={caregiverName}
          patients={patients}
          onLinkPatientClick={onLinkPatientClick}
          onLogout={onLogout}
        />

        <main className="main-scroll-area">
          <div className="main-content-inner">{children}</div>
          <footer
            style={{
              padding: '20px 32px',
              borderTop: '1px solid var(--border-subtle)',
              display: 'flex',
              flexWrap: 'wrap',
              alignItems: 'center',
              justifyContent: 'space-between',
              gap: '12px',
              fontSize: '12.5px',
              color: 'var(--text-muted)',
              background: 'var(--bg-surface)',
              marginTop: '32px',
            }}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
              <img
                src="/assets/branding/bandhu_emblem.png"
                alt="BANDHU"
                style={{ width: '20px', height: '20px', borderRadius: '4px' }}
                onError={(e) => { (e.target as HTMLElement).style.display = 'none'; }}
              />
              <span style={{ fontWeight: 600, color: 'var(--text-main)' }}>
                BANDHU — AI Cognitive Care Companion
              </span>
            </div>
            <div>
              Caregiver Intelligence & Transparency Portal • Non-Diagnostic Cognitive Health Platform
            </div>
          </footer>
        </main>
      </div>
    </div>
  );
};

