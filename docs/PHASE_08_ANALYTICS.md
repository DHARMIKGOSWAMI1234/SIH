# BANDHU Phase 08: Caregiver Intelligence, Analytics & Observed Trends

## 1. Executive Summary & Clinical Boundary

Phase 08 delivers **explainable, deterministic caregiver intelligence** from validated application activity data.

```
Patient Activity (Offline SQLite / Drift)
      ↓
Sync Engine (Idempotent Batch Sync)
      ↓
FastAPI Backend (PostgreSQL 18)
      ↓
Deterministic Analytics Service
      ↓
Caregiver Dashboard (React + Recharts)
```

### Strict Non-Clinical Boundary
BANDHU is a **non-diagnostic platform**. All observations describe recorded application activity, exercise participation, and routine completion.
- **PROHIBITED**:
  - Medical diagnoses
  - Dementia severity ratings / scores
  - Disease progression predictions
  - Clinical cognitive scores
  - Treatment recommendations
  - Medication recommendations
  - Medical predictions
  - Clinical interpretations derived from app activity
- **ALLOWED**:
  - Non-diagnostic disclaimers
  - References to consulting healthcare professionals for medical concerns
  - Caregiver review recommendations for routine adjustments
  - Observed participation consistency and game comfort metrics

---

## 2. Metric-Specific Data Sufficiency & Trend Semantics

Instead of applying a naive global rule, Phase 08 implements **metric-specific minimum data rules and directional semantics**:

| Metric | Minimum Data Rule | Trend Semantics | Direction Meaning |
| :--- | :--- | :--- | :--- |
| **Activity Participation** | $\ge 2$ completed activities in current and previous periods | `INCREASED` / `STABLE` / `DECREASED` | Higher $\rightarrow$ Increased, Lower $\rightarrow$ Decreased |
| **Game Accuracy** | $\ge 2$ completed sessions in current and previous periods | `IMPROVING` / `STABLE` / `DECLINING` | Higher $\rightarrow$ Improving, Lower $\rightarrow$ Declining |
| **Game Mistakes** | $\ge 2$ completed sessions in current and previous periods | `IMPROVING` / `STABLE` / `DECLINING` | **Lower $\rightarrow$ Improving, Higher $\rightarrow$ Declining** |
| **Response Time** | $\ge 2$ valid measurements ($>0\text{ ms}$) in each period | `IMPROVING` / `STABLE` / `DECLINING` | Faster ($<-200\text{ ms}$) $\rightarrow$ Improving, Slower $\rightarrow$ Declining |
| **Hint Usage** | Any valid measurements | **Descriptive Only** | Not classified as improving/declining; describes shift |
| **Reminder Adherence** | $\ge 1$ scheduled reminder in each comparison period | `IMPROVING` / `STABLE` / `DECLINING` | Completed / Scheduled; scheduled=0 $\rightarrow$ `INSUFFICIENT_DATA` |

### Key Rules
1. **Never Manufacture a Baseline**: If previous period has 0 records or data is insufficient, trend is strictly `INSUFFICIENT_DATA`.
2. **Future Reminders Excluded**: Scheduled reminders occurring later today (`slot_dt > now`) are never counted as missed or skipped.
3. **Zero-Division Protection**: If `scheduled == 0`, `adherence_rate = None` and `data_sufficient = False`.
4. **Session Deduplication**: Sessions and reminder events are deduplicated by `id` / `local_id` to prevent double-counting.

---

## 3. Backend REST API

All endpoints require JWT Bearer authentication and enforce server-side caregiver authorization via `verify_patient_access`.

### Endpoints
- `GET /api/v1/caregivers/patients/{patient_id}/analytics/overview?period_days={7|14|30}`
  - Returns overall participation, active days, sessions per day/week, longest streak, and daily series.
- `GET /api/v1/caregivers/patients/{patient_id}/analytics/activity?period_days={7|14|30}`
  - Returns detailed participation frequency and active day breakdown.
- `GET /api/v1/caregivers/patients/{patient_id}/analytics/games?period_days={7|14|30}&game_type={all|...}`
  - Returns cognitive game metrics, accuracy trend, mistakes trend, response time trend, and descriptive hint observations.
- `GET /api/v1/caregivers/patients/{patient_id}/analytics/reminders?period_days={7|14|30}`
  - Returns reminder adherence rate, completed vs scheduled counts, snoozed/missed counts, and adherence trend.
- `GET /api/v1/caregivers/patients/{patient_id}/analytics/trends?period_days={7|14|30}`
  - Returns deterministic observed trends, non-clinical review flags, and the mandatory clinical disclaimer.
- `GET /api/v1/caregivers/patients/{patient_id}/analytics/sync`
  - Returns caregiver-safe synchronization health status and pending count.

### Cross-Patient Isolation & Security
- Caregiver A $\rightarrow$ Patient A: **HTTP 200 OK**
- Caregiver A $\rightarrow$ Patient B: **HTTP 403 Forbidden**
- Zero leakage of Patient B data in error messages, aggregate queries, or trends.

---

## 4. Caregiver Dashboard Architecture

The dashboard (`apps/caregiver_dashboard`) is built with React, Vite, and Recharts without unnecessary `@types/recharts` packages.

### Component Structure
```
Dashboard
├── SummaryCards              (4 high-level KPI cards with real DB metrics)
├── ActivityOverview          (Participation metrics + Recharts daily timeline)
├── GamePerformance          (Cognitive game analytics, level 1 gentle, trend badges)
├── ReminderStatus            (Adherence rate, confirmed count, daily schedule)
├── ObservedTrendsCard        (Observed trends, non-clinical flags, non-diagnostic disclaimer)
├── RecentSessionsTable       (Synchronized session history log)
└── SyncHealth                (Encrypted SQLite-to-PostgreSQL sync status)
```

### Period Switcher
Caregivers can seamlessly toggle between **7 Days**, **14 Days**, and **30 Days** comparison windows. All dashboard components update reactively in parallel.
