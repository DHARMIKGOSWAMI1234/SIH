/**
 * Caregiver Dashboard API Client.
 * Connects to SMRITI FastAPI backend with error handling and empty-state fallbacks.
 */

export interface PatientProfile {
  id: string;
  user_id: string;
  anonymous_alias: string;
  preferred_language: string;
  font_scale_preference: number;
  contrast_preference: string;
  created_at: string;
  updated_at: string;
}

export interface PatientSummary {
  patient_id: string;
  total_sessions: number;
  average_accuracy: number;
  memories_count: number;
  active_reminders_count: number;
  routines_count: number;
  recent_activity_status: string;
}

export interface GameSessionRow {
  id: string;
  patient_id: string;
  local_id: string;
  game_type: string;
  score: number;
  accuracy: number;
  mistakes: number;
  response_time_ms: number;
  difficulty: number;
  hint_count: number;
  started_at: string;
  completed_at: string;
  created_at: string;
  updated_at: string;
}

export interface MemoryItem {
  id: string;
  patient_id: string;
  local_id: string;
  title: string;
  description: string;
  category: string;
  relationship?: string;
  person_name?: string;
  location?: string;
  event_date?: string;
  image_path?: string;
  audio_path?: string;
  media_uri?: string;
  language: string;
  region?: string;
  tags?: string;
  source: string;
  is_favorite: boolean;
  is_archived: boolean;
  version: number;
  created_at: string;
  updated_at: string;
}

export interface ReminderItem {
  id: string;
  patient_id: string;
  local_id: string;
  title: string;
  reminder_type: string;
  scheduled_time: string;
  enabled: boolean;
  version: number;
  created_at: string;
  updated_at: string;
}

export interface RoutineItem {
  id: string;
  patient_id: string;
  local_id: string;
  title: string;
  steps_json: string;
  preferred_time: string;
  enabled: boolean;
  version: number;
  created_at: string;
  updated_at: string;
}

export interface AuthUser {
  id: string;
  email: string;
  full_name: string;
  role: string;
  caregiver_id?: string;
}

export interface AuthResponse {
  access_token: string;
  token_type: string;
  user_id: string;
  role: string;
  caregiver_id?: string;
}

export interface DailyActivityDataPoint {
  date: string;
  game_sessions: number;
  reminders_completed: number;
  total: number;
}

export interface ActivityOverviewResponse {
  patient_id: string;
  period_days: number;
  total_completed_activities: number;
  active_days: number;
  sessions_per_day: number;
  sessions_per_week: number;
  most_recent_activity_at?: string | null;
  longest_streak_days: number;
  participation_trend: 'INCREASED' | 'STABLE' | 'DECREASED' | 'INSUFFICIENT_DATA';
  trend_observation: string;
  daily_series: DailyActivityDataPoint[];
  data_sufficient: boolean;
}

export interface GameMetricSummary {
  game_type: string;
  sessions_completed: number;
  average_score?: number | null;
  average_accuracy?: number | null;
  average_mistakes?: number | null;
  average_hints?: number | null;
  average_duration_seconds?: number | null;
  average_response_time_ms?: number | null;
  accuracy_trend: 'IMPROVING' | 'STABLE' | 'DECLINING' | 'INSUFFICIENT_DATA';
  mistakes_trend: 'IMPROVING' | 'STABLE' | 'DECLINING' | 'INSUFFICIENT_DATA';
  response_time_trend: 'IMPROVING' | 'STABLE' | 'DECLINING' | 'INSUFFICIENT_DATA';
  hint_usage_observation?: string | null;
  trend_observation: string;
  data_sufficient: boolean;
}

export interface GamesAnalyticsResponse {
  patient_id: string;
  period_days: number;
  selected_game_type: string;
  overall: GameMetricSummary;
  games: GameMetricSummary[];
}

export interface ReminderAnalyticsResponse {
  patient_id: string;
  period_days: number;
  scheduled_count: number;
  completed_count: number;
  snoozed_count: number;
  skipped_count: number;
  adherence_rate?: number | null;
  trend_direction: 'IMPROVING' | 'STABLE' | 'DECLINING' | 'INSUFFICIENT_DATA';
  trend_observation: string;
  data_sufficient: boolean;
}

export interface ObservedTrendItem {
  id: string;
  category: 'PARTICIPATION' | 'GAME_PERFORMANCE' | 'REMINDER_ADHERENCE' | 'SYNC_HEALTH';
  title: string;
  description: string;
  direction: string;
  period_days: number;
  status_type: 'INFO' | 'NEUTRAL' | 'ATTENTION_RECOMMENDED';
  data_basis: string;
}

export interface ReviewFlagItem {
  id: string;
  flag_type: string;
  title: string;
  message: string;
  status_type: 'INFO' | 'NEUTRAL' | 'ATTENTION_RECOMMENDED';
  suggested_action: string;
}

export interface TrendsAnalyticsResponse {
  patient_id: string;
  period_days: number;
  trends: ObservedTrendItem[];
  review_flags: ReviewFlagItem[];
  clinical_disclaimer: string;
}

export interface SyncHealthResponse {
  patient_id: string;
  sync_status: 'UP_TO_DATE' | 'PENDING' | 'SYNCING' | 'ATTENTION_NEEDED';
  status_label: string;
  pending_records_count: number;
  last_sync_at?: string | null;
  last_error_message?: string | null;
  is_offline_ready: boolean;
}

export class CaregiverApiClient {
  private baseUrl: string;
  private authToken: string | null = null;
  public onUnauthorized?: () => void;

  constructor(baseUrl: string = 'http://localhost:8000') {
    this.baseUrl = baseUrl;
    if (typeof window !== 'undefined' && window.localStorage) {
      this.authToken = localStorage.getItem('smriti_caregiver_token');
    }
  }

  setToken(token: string | null) {
    this.authToken = token;
  }

  private getHeaders(): HeadersInit {
    const headers: HeadersInit = {
      'Content-Type': 'application/json',
    };
    if (this.authToken) {
      headers['Authorization'] = `Bearer ${this.authToken}`;
    }
    return headers;
  }

  async login(email: string, password: string): Promise<AuthResponse> {
    const resp = await fetch(`${this.baseUrl}/api/v1/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: email.trim().toLowerCase(), password }),
    });
    if (!resp.ok) {
      const err = await resp.json().catch(() => ({ detail: 'Authentication failed' }));
      throw new Error(err.detail || 'Invalid credentials');
    }
    return await resp.json();
  }

  async register(data: {
    email: string;
    password: string;
    full_name: string;
    relationship_to_patient?: string;
    phone_number?: string;
  }): Promise<AuthResponse> {
    const resp = await fetch(`${this.baseUrl}/api/v1/auth/register`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        ...data,
        role: 'CAREGIVER',
      }),
    });
    if (!resp.ok) {
      const err = await resp.json().catch(() => ({ detail: 'Registration failed' }));
      throw new Error(err.detail || 'Unable to register account');
    }
    return await resp.json();
  }

  async getMe(): Promise<AuthUser | null> {
    try {
      const resp = await fetch(`${this.baseUrl}/api/v1/auth/me`, {
        headers: this.getHeaders(),
      });
      if (resp.status === 401) {
        this.onUnauthorized?.();
        return null;
      }
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async linkPatient(patientEmail: string, relationshipType?: string): Promise<PatientProfile> {
    const resp = await fetch(`${this.baseUrl}/api/v1/caregivers/link-patient`, {
      method: 'POST',
      headers: this.getHeaders(),
      body: JSON.stringify({
        patient_email: patientEmail.trim().toLowerCase(),
        relationship_type: relationshipType || 'Family Caregiver',
      }),
    });
    if (!resp.ok) {
      const err = await resp.json().catch(() => ({ detail: 'Unable to link patient with the provided information.' }));
      throw new Error(err.detail || 'Unable to link patient with the provided information.');
    }
    return await resp.json();
  }

  async getPatients(): Promise<PatientProfile[]> {
    try {
      const resp = await fetch(`${this.baseUrl}/api/v1/caregivers/patients`, {
        headers: this.getHeaders(),
      });
      if (resp.status === 401) {
        this.onUnauthorized?.();
        return [];
      }
      if (!resp.ok) return [];
      return await resp.json();
    } catch {
      return [];
    }
  }

  async getPatientSummary(patientId: string): Promise<PatientSummary | null> {
    try {
      const resp = await fetch(`${this.baseUrl}/api/v1/caregivers/patients/${patientId}/summary`, {
        headers: this.getHeaders(),
      });
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async getGameSessions(patientId: string, limit: number = 20): Promise<GameSessionRow[]> {
    try {
      const resp = await fetch(
        `${this.baseUrl}/api/v1/caregivers/patients/${patientId}/game-sessions?limit=${limit}`,
        { headers: this.getHeaders() }
      );
      if (!resp.ok) return [];
      return await resp.json();
    } catch {
      return [];
    }
  }

  async getMemories(patientId: string, category?: string): Promise<MemoryItem[]> {
    try {
      const query = category && category !== 'all' ? `?category=${category}` : '';
      const resp = await fetch(
        `${this.baseUrl}/api/v1/caregivers/patients/${patientId}/memories${query}`,
        { headers: this.getHeaders() }
      );
      if (!resp.ok) return [];
      return await resp.json();
    } catch {
      return [];
    }
  }

  async getReminders(patientId: string): Promise<ReminderItem[]> {
    try {
      const resp = await fetch(`${this.baseUrl}/api/v1/caregivers/patients/${patientId}/reminders`, {
        headers: this.getHeaders(),
      });
      if (!resp.ok) return [];
      return await resp.json();
    } catch {
      return [];
    }
  }

  async getRoutines(patientId: string): Promise<RoutineItem[]> {
    try {
      const resp = await fetch(`${this.baseUrl}/api/v1/caregivers/patients/${patientId}/routines`, {
        headers: this.getHeaders(),
      });
      if (!resp.ok) return [];
      return await resp.json();
    } catch {
      return [];
    }
  }

  async getActivityOverview(patientId: string, periodDays: number = 7): Promise<ActivityOverviewResponse | null> {
    try {
      const resp = await fetch(
        `${this.baseUrl}/api/v1/caregivers/patients/${patientId}/analytics/overview?period_days=${periodDays}`,
        { headers: this.getHeaders() }
      );
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async getGameAnalytics(patientId: string, periodDays: number = 7, gameType: string = 'all'): Promise<GamesAnalyticsResponse | null> {
    try {
      const resp = await fetch(
        `${this.baseUrl}/api/v1/caregivers/patients/${patientId}/analytics/games?period_days=${periodDays}&game_type=${encodeURIComponent(gameType)}`,
        { headers: this.getHeaders() }
      );
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async getReminderAnalytics(patientId: string, periodDays: number = 7): Promise<ReminderAnalyticsResponse | null> {
    try {
      const resp = await fetch(
        `${this.baseUrl}/api/v1/caregivers/patients/${patientId}/analytics/reminders?period_days=${periodDays}`,
        { headers: this.getHeaders() }
      );
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async getObservedTrends(patientId: string, periodDays: number = 7): Promise<TrendsAnalyticsResponse | null> {
    try {
      const resp = await fetch(
        `${this.baseUrl}/api/v1/caregivers/patients/${patientId}/analytics/trends?period_days=${periodDays}`,
        { headers: this.getHeaders() }
      );
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async getSyncHealth(patientId: string): Promise<SyncHealthResponse | null> {
    try {
      const resp = await fetch(
        `${this.baseUrl}/api/v1/caregivers/patients/${patientId}/analytics/sync`,
        { headers: this.getHeaders() }
      );
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async createPairingRequest(): Promise<PairingCreateResponse | null> {
    try {
      const resp = await fetch(`${this.baseUrl}/api/v1/caregivers/pairing/create`, {
        method: 'POST',
        headers: this.getHeaders(),
      });
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }

  async getPairingStatus(requestId: string): Promise<PairingStatusResponse | null> {
    try {
      const resp = await fetch(`${this.baseUrl}/api/v1/caregivers/pairing/${requestId}/status`, {
        headers: this.getHeaders(),
      });
      if (!resp.ok) return null;
      return await resp.json();
    } catch {
      return null;
    }
  }
}

export interface PairingCreateResponse {
  request_id: string;
  short_code: string;
  pairing_token: string;
  qr_payload: string;
  expires_at: string;
  expires_in_seconds: number;
  caregiver_name: string;
}

export interface PairingStatusResponse {
  request_id: string;
  status: 'PENDING' | 'USED' | 'EXPIRED' | 'CANCELLED';
  is_used: boolean;
  patient_id?: string | null;
  patient_name?: string | null;
}

export const caregiverApi = new CaregiverApiClient();
