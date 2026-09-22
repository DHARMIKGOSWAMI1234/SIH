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
        </main>
      </div>
    </div>
  );
};

