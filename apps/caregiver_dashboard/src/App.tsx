import React, { useState, useEffect, useCallback } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { LocalizationProvider, useTranslation } from './context/LocalizationContext';
import { LoginScreen } from './components/LoginScreen';
import { AppLayout } from './layout/AppLayout';
import { NavTab } from './layout/Sidebar';
import { SummaryCards } from './components/SummaryCards';
import { ActivityOverview } from './components/ActivityOverview';
import { GamePerformance } from './components/GamePerformance';
import { ReminderStatus } from './components/ReminderStatus';
import { ObservedTrendsCard } from './components/ObservedTrendsCard';
import { RecentSessionsTable } from './components/RecentSessionsTable';
import { MemoryManager } from './components/MemoryManager';
import { ConnectPatientModal } from './components/ConnectPatientModal';
import { PatientCards } from './components/PatientCards';
import {
  caregiverApi,
  PatientProfile,
  GameSessionRow,
  ReminderItem,
  ActivityOverviewResponse,
  GamesAnalyticsResponse,
  ReminderAnalyticsResponse,
  TrendsAnalyticsResponse,
  SyncHealthResponse,
} from './api/client';
import {
  Users,
  ShieldCheck,
  UserPlus,
  X,
  AlertCircle,
  CheckCircle,
  HeartHandshake,
} from 'lucide-react';

const DashboardContent: React.FC = () => {
  const { user, isAuthenticated, isLoading, logout } = useAuth();
  const { t, currentLanguage, setLanguage, languages } = useTranslation();
  const [activeTab, setActiveTab] = useState<NavTab>('overview');
  const [isDark, setIsDark] = useState<boolean>(false);
  const [searchTerm, setSearchTerm] = useState<string>('');
  const [patients, setPatients] = useState<PatientProfile[]>([]);
  const [selectedPatient, setSelectedPatient] = useState<string>('');

  // Period: 7 days default
  const [periodDays] = useState<7 | 14 | 30>(7);
  const [selectedGameType, setSelectedGameType] = useState<string>('all');

  // Analytics State
  const [isLoadingData, setIsLoadingData] = useState<boolean>(true);
  const [activityData, setActivityData] = useState<ActivityOverviewResponse | null>(null);
  const [gamesData, setGamesData] = useState<GamesAnalyticsResponse | null>(null);
  const [remindersData, setRemindersData] = useState<ReminderAnalyticsResponse | null>(null);
  const [trendsData, setTrendsData] = useState<TrendsAnalyticsResponse | null>(null);
  const [syncData, setSyncData] = useState<SyncHealthResponse | null>(null);
  const [sessions, setSessions] = useState<GameSessionRow[]>([]);
  const [remindersList, setRemindersList] = useState<ReminderItem[]>([]);

  // Link / Pairing Patient Modal State
  const [isConnectModalOpen, setIsConnectModalOpen] = useState<boolean>(false);
  const [isLinkModalOpen, setIsLinkModalOpen] = useState<boolean>(false);
  const [linkEmail, setLinkEmail] = useState<string>('');
  const [linkRelationship, setLinkRelationship] = useState<string>('Family Caregiver');
  const [isLinking, setIsLinking] = useState<boolean>(false);
  const [linkError, setLinkError] = useState<string>('');
  const [linkSuccess, setLinkSuccess] = useState<string>('');

  const loadAnalyticsData = useCallback(async (targetPatientId?: string) => {
    const patientId = targetPatientId || selectedPatient;
    if (!isAuthenticated || !patientId) {
      setActivityData(null);
      setGamesData(null);
      setRemindersData(null);
      setTrendsData(null);
      setSyncData(null);
      setSessions([]);
      setRemindersList([]);
      setIsLoadingData(false);
      return;
    }
    setIsLoadingData(true);
    try {
      const [act, gms, rem, trn, snc, sess, remList] = await Promise.all([
        caregiverApi.getActivityOverview(patientId, periodDays),
        caregiverApi.getGameAnalytics(patientId, periodDays, selectedGameType),
        caregiverApi.getReminderAnalytics(patientId, periodDays),
        caregiverApi.getObservedTrends(patientId, periodDays),
        caregiverApi.getSyncHealth(patientId),
        caregiverApi.getGameSessions(patientId),
        caregiverApi.getReminders(patientId),
      ]);

      setActivityData(act);
      setGamesData(gms);
      setRemindersData(rem);
      setTrendsData(trn);
      setSyncData(snc);
      setSessions(Array.isArray(sess) ? sess : []);
      setRemindersList(Array.isArray(remList) ? remList : []);
    } catch (err) {
      console.error('Failed to load caregiver data:', err);
    } finally {
      setIsLoadingData(false);
    }
  }, [selectedPatient, periodDays, selectedGameType, isAuthenticated]);

  const loadPatients = useCallback(async () => {
    try {
      const list = await caregiverApi.getPatients();
      setPatients(list);
      if (list.length > 0) {
        const defaultId = list.some((p) => p.id === 'local-patient-demo')
          ? 'local-patient-demo'
          : list[0].id;
        setSelectedPatient((prev) => {
          const nextId = (!prev || !list.some((p) => p.id === prev)) ? defaultId : prev;
          loadAnalyticsData(nextId);
          return nextId;
        });
      } else {
        setSelectedPatient('');
        setIsLoadingData(false);
      }
    } catch {
      setIsLoadingData(false);
    }
  }, [loadAnalyticsData]);

  useEffect(() => {
    if (isAuthenticated) {
      loadPatients();
    }
  }, [isAuthenticated, loadPatients]);

  useEffect(() => {
    if (selectedPatient) {
      loadAnalyticsData();
    }
  }, [selectedPatient, periodDays, selectedGameType]);

  const handlePatientChange = (patientId: string) => {
    setSelectedPatient(patientId);
    loadAnalyticsData(patientId);
  };

  const handleLinkPatient = async (e: React.FormEvent) => {
    e.preventDefault();
    setLinkError('');
    setLinkSuccess('');
    setIsLinking(true);

    try {
      const linked = await caregiverApi.linkPatient(linkEmail, linkRelationship);
      setLinkSuccess(`Successfully linked patient (${linked.anonymous_alias || linked.id})!`);
      setLinkEmail('');
      await loadPatients();
      setSelectedPatient(linked.id);
      setTimeout(() => {
        setIsLinkModalOpen(false);
        setLinkSuccess('');
      }, 1500);
    } catch (err: unknown) {
      const msg = err instanceof Error ? err.message : 'Unable to link patient with the provided information.';
      setLinkError(msg);
    } finally {
      setIsLinking(false);
    }
  };

  if (isLoading) {
    return (
      <div style={{ minHeight: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center', background: 'var(--bg-app)' }}>
        <div style={{ textAlign: 'center' }}>
          <HeartHandshake size={48} style={{ color: 'var(--color-sage)', animation: 'pulse 1.5s infinite', margin: '0 auto 16px' }} />
          <p style={{ color: 'var(--text-muted)', fontSize: '16px' }}>Loading BANDHU Caregiver Portal...</p>
        </div>
      </div>
    );
  }

  if (!isAuthenticated || !user) {
    return <LoginScreen />;
  }

  const renderContent = () => {
    switch (activeTab) {
      case 'overview':
        return (
          <>
            {/* Header */}
            <div className="page-header-flex" style={{ marginBottom: '20px' }}>
              <div>
                <h1 className="page-title">{t('header.title')}</h1>
                <p className="page-subtitle">
                  {t('header.subtitle')}
                </p>
              </div>
            </div>

            {patients.length === 0 ? (
              <div className="card" style={{ marginBottom: '24px', border: '1px dashed var(--color-sage)', background: 'var(--color-sage-light)' }}>
                <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', flexWrap: 'wrap', gap: '16px' }}>
                  <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                    <HeartHandshake size={28} style={{ color: 'var(--color-sage-dark)' }} />
                    <div>
                      <h4 style={{ fontWeight: 600, color: 'var(--color-sage-dark)' }}>{t('empty.noPatients')}</h4>
                      <p style={{ fontSize: '13px', color: 'var(--text-main)', marginTop: '2px' }}>
                        {t('empty.noPatientsDesc')}
                      </p>
                    </div>
                  </div>
                  <button
                    type="button"
                    className="btn btn-primary"
                    onClick={() => setIsConnectModalOpen(true)}
                    style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
                  >
                    <UserPlus size={16} />
                    <span>+ Connect Patient</span>
                  </button>
                </div>
              </div>
            ) : (
              <PatientCards
                patients={patients}
                selectedPatientId={selectedPatient}
                onSelectPatient={handlePatientChange}
                onConnectClick={() => setIsConnectModalOpen(true)}
              />
            )}

            {/* Overview Page: 4 Metric Cards, Recent Cognitive Activity, Activity This Week */}
            <SummaryCards
              activityData={activityData}
              gamesData={gamesData}
              remindersData={remindersData}
              syncData={syncData}
              liveSessions={sessions}
              isLoading={isLoadingData}
            />

            <RecentSessionsTable
              filterQuery={searchTerm}
              liveSessions={sessions}
              isLoading={isLoadingData}
            />

            <ActivityOverview
              activityData={activityData}
              liveSessions={sessions}
              periodDays={periodDays}
              isLoading={isLoadingData}
            />
          </>
        );

      case 'patients':
        return (
          <div className="tab-pane">
            <div className="page-header-flex">
              <div>
                <h1 className="page-title">Patient Profile Overview</h1>
                <p className="page-subtitle">
                  Authorized patient records and active caregiver relationship details
                </p>
              </div>
              <button
                type="button"
                className="btn btn-primary"
                onClick={() => setIsConnectModalOpen(true)}
                style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
              >
                <UserPlus size={16} />
                <span>+ Connect Patient</span>
              </button>
            </div>

            {patients.length > 0 && (
              <PatientCards
                patients={patients}
                selectedPatientId={selectedPatient}
                onSelectPatient={handlePatientChange}
                onConnectClick={() => setIsConnectModalOpen(true)}
              />
            )}

            <div className="card">
              <div className="flex items-center gap-3 mb-4">
                <div className="stat-icon-wrapper sage">
                  <Users size={22} />
                </div>
                <div>
                  <h3 className="section-title">Active Profile ({selectedPatient})</h3>
                  <p className="section-subtitle">
                    {patients.find((p) => p.id === selectedPatient)?.anonymous_alias || 'Authorized patient record'}
                  </p>
                </div>
              </div>
              <div className="details-grid">
                <div className="detail-item">
                  <span className="detail-label">Status</span>
                  <span className="detail-val text-success font-semibold">Active & Engaged</span>
                </div>
                <div className="detail-item">
                  <span className="detail-label">Care Tier</span>
                  <span className="detail-val">Cognitive Support (Gentle)</span>
                </div>
                <div className="detail-item">
                  <span className="detail-label">Region</span>
                  <span className="detail-val">North Eastern Region (NER)</span>
                </div>
                <div className="detail-item">
                  <span className="detail-label">Caregiver</span>
                  <span className="detail-val">{user.full_name}</span>
                </div>
              </div>
            </div>
          </div>
        );

      case 'activity':
        return (
          <div className="tab-pane">
            <div className="page-header-flex">
              <div>
                <h1 className="page-title">Activity</h1>
                <p className="page-subtitle">
                  Session breakdown across cognitive exercises
                </p>
              </div>
            </div>
            <ActivityOverview
              activityData={activityData}
              liveSessions={sessions}
              periodDays={periodDays}
              isLoading={isLoadingData}
            />
            <GamePerformance
              gamesData={gamesData}
              selectedGameType={selectedGameType}
              onSelectGameType={setSelectedGameType}
            />
            <div className="mt-6">
              <RecentSessionsTable
                filterQuery={searchTerm}
                liveSessions={sessions}
                isLoading={isLoadingData}
              />
            </div>
          </div>
        );

      case 'memory':
        return <MemoryManager patientId={selectedPatient} apiClient={caregiverApi} />;

      case 'reminders':
        return (
          <div className="tab-pane">
            <div className="page-header-flex">
              <div>
                <h1 className="page-title">Reminders</h1>
                <p className="page-subtitle">
                  Today's schedule and routine tracking
                </p>
              </div>
            </div>
            <ReminderStatus
              remindersData={remindersData}
              remindersList={remindersList}
              periodDays={periodDays}
            />
          </div>
        );

      case 'progress':
        return (
          <div className="tab-pane">
            <div className="page-header-flex">
              <div>
                <h1 className="page-title">Longitudinal Engagement Trends</h1>
                <p className="page-subtitle">
                  Comfort-based participation trends and consistency tracking
                </p>
              </div>
            </div>
            <ObservedTrendsCard trendsData={trendsData} periodDays={periodDays} />
          </div>
        );

      case 'settings':
        return (
          <div className="tab-pane">
            <div className="page-header-flex">
              <div>
                <h1 className="page-title">Settings</h1>
                <p className="page-subtitle">
                  Display preferences, language, and platform information
                </p>
              </div>
            </div>

            {/* Appearance */}
            <div className="card">
              <h3 className="section-title mb-2">Appearance</h3>
              <p className="section-subtitle mb-4">
                Customize theme display for comfortable viewing
              </p>
              <div className="settings-row">
                <div>
                  <div className="settings-label">Dark Mode Theme</div>
                  <div className="settings-desc">Switch between warm light cream and dark contrast</div>
                </div>
                <button
                  type="button"
                  className="btn btn-secondary"
                  onClick={() => setIsDark(!isDark)}
                >
                  {isDark ? 'Switch to Light' : 'Switch to Dark'}
                </button>
              </div>
            </div>

            {/* Language */}
            <div className="card mt-4">
              <h3 className="section-title mb-2">Language</h3>
              <p className="section-subtitle mb-4">Choose dashboard display language</p>
              <div className="settings-row">
                <div>
                  <div className="settings-label">Active Language</div>
                  <div className="settings-desc">Select from reviewed languages</div>
                </div>
                <select
                  value={currentLanguage}
                  onChange={(e) => setLanguage(e.target.value)}
                  className="input-field"
                  style={{ minWidth: '160px' }}
                >
                  {languages.filter((l) => l.reviewed).map((lang) => (
                    <option key={lang.code} value={lang.code}>
                      {lang.nativeName} ({lang.englishName})
                    </option>
                  ))}
                </select>
              </div>
            </div>

            {/* About BANDHU */}
            <div className="card mt-4">
              <h3 className="section-title mb-2">About BANDHU</h3>
              <p className="section-subtitle mb-2">Assistive Cognitive Health Companion</p>
              <p style={{ fontSize: '13.5px', color: 'var(--text-main)', lineHeight: 1.6, margin: 0 }}>
                BANDHU empowers caregivers with non-intrusive transparency into cognitive exercises, routines, and reminiscence activities.
              </p>
            </div>

            {/* Clinical Boundary Notice */}
            <div className="card mt-4">
              <h3 className="section-title mb-2">Clinical Boundary Notice</h3>
              <p className="section-subtitle mb-4">
                Strict adherence to non-diagnostic, supportive monitoring standards
              </p>
              <div className="banner info">
                <ShieldCheck size={20} className="banner-icon" />
                <div>
                  <div className="banner-title">Non-Diagnostic Platform Policy</div>
                  <div className="banner-desc">
                    BANDHU does not provide medical diagnoses, risk scores, or clinical severity assessments.
                    All recorded metrics reflect observed gameplay comfort, engagement consistency, and routine completion.
                  </div>
                </div>
              </div>
            </div>
          </div>
        );

      default:
        return null;
    }
  };

  return (
    <>
      <AppLayout
        activeTab={activeTab}
        onTabChange={setActiveTab}
        isDark={isDark}
        onToggleTheme={() => setIsDark(!isDark)}
        searchTerm={searchTerm}
        onSearchChange={setSearchTerm}
        selectedPatient={selectedPatient}
        onPatientChange={handlePatientChange}
        caregiverName={user.full_name}
        patients={patients}
        onLinkPatientClick={() => setIsConnectModalOpen(true)}
        onLogout={logout}
      >
        {renderContent()}
      </AppLayout>

      {/* Modern QR / 4-Digit Code Pairing Modal */}
      <ConnectPatientModal
        isOpen={isConnectModalOpen}
        onClose={() => setIsConnectModalOpen(false)}
        onPatientConnected={async (newPatientId, _patientName) => {
          await loadPatients();
          if (newPatientId) {
            setSelectedPatient(newPatientId);
            loadAnalyticsData(newPatientId);
          }
        }}
      />

      {/* Link Patient Modal */}
      {isLinkModalOpen && (
        <div
          style={{
            position: 'fixed',
            inset: 0,
            backgroundColor: 'rgba(0, 0, 0, 0.5)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 100,
            padding: '16px',
          }}
        >
          <div
            className="card"
            style={{
              maxWidth: '480px',
              width: '100%',
              boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.2)',
              position: 'relative',
            }}
          >
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
              <div style={{ display: 'flex', alignItems: 'center', gap: '8px' }}>
                <UserPlus size={20} style={{ color: 'var(--color-sage)' }} />
                <h3 className="section-title" style={{ margin: 0 }}>{t('linkModal.title')}</h3>
              </div>
              <button
                type="button"
                onClick={() => {
                  setIsLinkModalOpen(false);
                  setLinkError('');
                  setLinkSuccess('');
                }}
                style={{ background: 'transparent', border: 'none', cursor: 'pointer', color: 'var(--text-muted)' }}
                aria-label="Close"
              >
                <X size={20} />
              </button>
            </div>

            <p className="section-subtitle" style={{ marginBottom: '20px' }}>
              {t('linkModal.subtitle')}
            </p>

            {linkError && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  padding: '12px',
                  borderRadius: '8px',
                  backgroundColor: '#fef2f2',
                  border: '1px solid #fecaca',
                  color: '#991b1b',
                  fontSize: '14px',
                  marginBottom: '16px',
                }}
              >
                <AlertCircle size={16} />
                <span>{linkError}</span>
              </div>
            )}

            {linkSuccess && (
              <div
                style={{
                  display: 'flex',
                  alignItems: 'center',
                  gap: '8px',
                  padding: '12px',
                  borderRadius: '8px',
                  backgroundColor: '#f0fdf4',
                  border: '1px solid #bbf7d0',
                  color: '#166534',
                  fontSize: '14px',
                  marginBottom: '16px',
                }}
              >
                <CheckCircle size={16} />
                <span>{linkSuccess}</span>
              </div>
            )}

            <form onSubmit={handleLinkPatient}>
              <div style={{ marginBottom: '16px' }}>
                <label className="settings-label" style={{ display: 'block', marginBottom: '6px' }}>
                  {t('linkModal.emailLabel')}
                </label>
                <input
                  type="email"
                  required
                  placeholder="patient@example.com"
                  value={linkEmail}
                  onChange={(e) => setLinkEmail(e.target.value)}
                  className="search-input"
                  style={{ width: '100%', padding: '10px 12px', border: '1px solid var(--border-strong)', borderRadius: '8px' }}
                />
              </div>

              <div style={{ marginBottom: '20px' }}>
                <label className="settings-label" style={{ display: 'block', marginBottom: '6px' }}>
                  {t('linkModal.relationshipLabel')}
                </label>
                <input
                  type="text"
                  placeholder="e.g. Daughter, Spouse, Professional Caregiver"
                  value={linkRelationship}
                  onChange={(e) => setLinkRelationship(e.target.value)}
                  className="search-input"
                  style={{ width: '100%', padding: '10px 12px', border: '1px solid var(--border-strong)', borderRadius: '8px' }}
                />
              </div>

              <div
                style={{
                  padding: '10px 12px',
                  borderRadius: '8px',
                  background: 'var(--bg-app)',
                  border: '1px solid var(--border-subtle)',
                  fontSize: '12px',
                  color: 'var(--text-muted)',
                  marginBottom: '20px',
                }}
              >
                <strong>Notice:</strong> {t('linkModal.notice')}
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px' }}>
                <button
                  type="button"
                  className="btn btn-secondary"
                  onClick={() => {
                    setIsLinkModalOpen(false);
                    setLinkError('');
                    setLinkSuccess('');
                  }}
                  disabled={isLinking}
                >
                  {t('linkModal.cancel')}
                </button>
                <button
                  type="submit"
                  className="btn btn-primary"
                  disabled={isLinking || !linkEmail.trim()}
                  style={{ display: 'flex', alignItems: 'center', gap: '6px' }}
                >
                  {isLinking ? t('linkModal.submitting') : t('linkModal.submit')}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}
    </>
  );
};

export const App: React.FC = () => {
  return (
    <LocalizationProvider>
      <AuthProvider>
        <DashboardContent />
      </AuthProvider>
    </LocalizationProvider>
  );
};
