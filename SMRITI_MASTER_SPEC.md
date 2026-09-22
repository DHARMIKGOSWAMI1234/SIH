# SMRITI — MASTER ENGINEERING SPECIFICATION (v1.0.0)
## SIH26003: AI-Based Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in North Eastern Region (NER)
### Organization: Ministry of Development of North Eastern Region (MDoNER)

---

## 1. Executive Summary & Clinical Boundaries

### 1.1 Project Purpose
SMRITI is an offline-first, culturally familiar cognitive activity, routine tracking, and memory assistance application engineered specifically for the elderly population in India's North Eastern Region (NER). It pairs a highly accessible, calm patient mobile application with an explainable adaptive difficulty engine, local SQLite persistence, and a caregiver transparency dashboard.

### 1.2 Strict Clinical Boundary Notice
> [!IMPORTANT]
> **SMRITI IS NOT A DIAGNOSTIC TOOL, CLINICAL PREDICTOR, OR MEDICAL DEVICE.**
>
> - **SMRITI IS NOT:**
>   - A dementia diagnostic system
>   - A dementia risk/severity predictor
>   - A medical diagnosis or neurologist replacement
>   - A medical advice chatbot
>   - A treatment, cure, or clinical decision support system
>
> - **SMRITI IS:**
>   - A cognitive activity and engagement platform
>   - A memory assistance and daily routine tool
>   - An accessible reminder system
>   - A caregiver transparency and engagement monitoring tool
>   - An elderly-first accessibility interface
>
> - **Mandatory Terminology:**
>   - Allowed: *activity performance*, *exercise score*, *recent engagement*, *observed trend*, *caregiver review recommended*, *routine completed*.
>   - Prohibited: *"dementia detected"*, *"dementia probability"*, *"cured"*, *"cognitive decline diagnosed"*, *"stage 2 dementia"*.

---

## 2. System Architecture & Component Responsibilities

### 2.1 Monorepo Layout
```
SMRITI-SIH26003/
├── apps/
│   ├── patient_app/             # Flutter (Dart) elderly-first mobile & web client
│   └── caregiver_dashboard/     # React (TypeScript) dashboard foundation
├── backend/
│   └── api/                     # Python FastAPI server
├── ai/
│   ├── adaptive_engine/         # Deterministic rule-based difficulty adjustment
│   ├── analytics/               # Non-clinical aggregation & trends
│   ├── models/                  # Shared data structures
│   └── tests/                   # Pytest test suite
├── data/
│   ├── raw/
│   ├── processed/
│   ├── demo/
│   └── DATASET_MANIFEST.md      # Ethical data governance & NER cultural schema
├── shared/
│   ├── schemas/                 # Cross-boundary JSON schemas
│   └── constants/               # System & localization constants
├── docs/
│   ├── architecture/            # Architecture diagrams & sync specifications
│   ├── decisions/               # Architecture Decision Records (ADRs)
│   └── demo/                    # Phone demo and connectivity guides
├── scripts/
│   ├── setup/                   # Setup scripts
│   ├── development/             # Development runners
│   └── demo/                    # Dynamic LAN IP detection and QR generation
├── tests/                       # Cross-component integration tests
├── .gitignore
├── .env.example
├── README.md
└── SMRITI_MASTER_SPEC.md
```

### 2.2 Core Tech Stack
| Component | Technology | Rationale |
| :--- | :--- | :--- |
| **Patient Application** | Flutter (Dart 3) | Cross-platform (Android, Web), smooth 60fps rendering, rich accessibility controls. |
| **Local Persistence** | SQLite via Drift | Type-safe, reactive, offline-first local SQL storage with web Wasm/fallback support. |
| **Backend API** | FastAPI (Python 3.13) | Asynchronous, lightweight, OpenAPI documentation, high performance. |
| **Adaptive Engine** | Python / Dart | 100% deterministic, explainable, rule-based; zero opaque "black-box" decisions. |
| **Caregiver Dashboard** | React + TypeScript | Clean, extensible web foundation for caregiver insights and activity logging. |

---

## 3. Detailed Component Specifications

### 3.1 Patient Application (`apps/patient_app`)
1. **Elderly-First Design System:**
   - **Typography:** Minimum body text 18sp; large, high-contrast headings (24sp–32sp).
   - **Touch Targets:** Minimum 56x56dp (recommended 64x64dp) with generous spacing to avoid accidental taps.
   - **Color Palette:** Deep slate/navy (`#1E293B`), warm cream background (`#FDFBF7`), restorative sage green (`#3B7A57`), high-contrast dark charcoal text (`#0F172A`).
   - **Navigation:** Single-level, predictable navigation without multi-finger gestures, pinch-to-zoom, or hidden dropdowns.
2. **Local Persistence Tables (Drift):**
   - `GameSessions`: `localId`, `serverId`, `gameType`, `score`, `accuracy`, `mistakes`, `responseTimeMs`, `difficulty`, `hintCount`, `startedAt`, `completedAt`, `syncStatus`.
   - `Reminders`: `localId`, `serverId`, `title`, `type`, `scheduledTime`, `enabled`, `syncStatus`.
   - `ReminderEvents`: `localId`, `reminderId`, `eventType`, `occurredAt`, `syncStatus`.
   - `Routines`: `localId`, `serverId`, `title`, `stepsJson`, `preferredTime`, `enabled`, `syncStatus`.
   - `Memories`: `localId`, `serverId`, `title`, `description`, `mediaUri`, `language`, `syncStatus`.
   - `SyncQueue`: `localId`, `entityType`, `entityId`, `operation`, `status`, `retryCount`, `lastAttemptAt`.
3. **Core Cognitive Exercises (Implementation & Architecture):**
   - *Memory Match (Phase 02 Implemented):*
     - **Difficulty Tiers:**
       - Easy: 3 pairs (6 cards, 3x2 grid), initial preview time 1.5s.
       - Medium: 4 pairs (8 cards, 4x2 grid), initial preview time 1.0s.
       - Hard: 6 pairs (12 cards, 4x3 grid), initial preview time 0.5s.
     - **NER Cultural & Familiar Asset Set:** High-contrast, culturally resonant icons:
       - Assam/NER Tea Cup (`local_cafe`), Garden Orchids (`local_florist`), Traditional Home (`home`), Warm Morning Sun (`wb_sunny`), Local Harvest Fruit (`apple`), Festival Dhol/Drum (`music_note`), Sacred Bamboo Grove (`eco`), Brahmaputra River Boat (`sailing`).
     - **Accessibility & Sensory Design:** Minimum 64dp touch targets, high contrast border ratios (> 4.5:1), smooth 3D matrix card flip transitions (400ms), visual & haptic calm cues, non-punitive gentle hint mechanism.
     - **Deterministic Transparent Scoring:**
       - $\text{accuracy} = \text{matchedPairs} / \max(1, \text{totalAttempts})$
       - $\text{score} = \max(0, (\text{matchedPairs} \times 100) - (\text{mistakes} \times 15) - (\text{hintsUsed} \times 20))$
       - Complete metrics: completion duration, average response time per turn, hint tally, mistakes tally.
   - *Pattern Recognition (Phase 03 Implemented):*
     - **Difficulty Tiers:**
       - Easy: 4 sequence questions, 3–4 items in visual sequence, 2 answer choices (1 distractor).
       - Medium: 5 sequence questions, 4–5 items in visual sequence, 3 answer choices (2 distractors).
       - Hard: 6 sequence questions, 5–7 items in visual sequence, 4 answer choices (3 distractors).
     - **Visual Rhythms & Familiar Catalog:** High-contrast alternating, triplet cycle, and repetition patterns featuring Red Apple, Garden Orchid/Flower, Warm Assam Tea, Morning Sun, Bamboo Leaf, Family Home, Festival Drum, and River Boat.
     - **Accessibility & Sensory Features:** Sequence display with explicit arrows and distinct `Next ?` card slot, $\ge 64\text{dp}$ touch target answer buttons, turn locking preventing rapid double taps, gentle distractor-elimination hints, and calm feedback ("Well done!", "Let's look closely at the pattern again.").
     - **Deterministic Scoring & Metrics:**
       - $\text{accuracy} = \text{correctAnswers} / \max(1, \text{totalAttempts})$
       - $\text{score} = \max(0, (\text{correctAnswers} \times 100) - (\text{mistakes} \times 20) - (\text{hintCount} \times 10))$
       - Evaluated with `ClientAdaptiveEngine` and persisted to SQLite with `gameType: 'pattern_recognition'`.
   - *Daily Routine Recall (Phase 04 Implemented):*
     - **Difficulty Tiers:**
       - Easy: 3 questions, 3 routine steps per question, 3–4 available choices (0–1 distractor).
       - Medium: 4 questions, 4 routine steps per question, 5 available choices (1 distractor).
       - Hard: 5 questions, 5 routine steps per question, 7 available choices (2 distractors).
     - **NER Cultural & Everyday Catalog:** High-contrast everyday routine cards with semantic visual identifiers:
       - Wake Up, Wash & Freshen Up, Morning Assam Tea, Breakfast, Morning Walk, Scheduled Medicine (generic caregiver routine item only, strictly non-clinical), Afternoon Lunch, Afternoon Rest, Evening Tea & Chat, Dinner, Night Sleep.
     - **Accessibility & Interaction:** Minimum 64dp touch targets, accessible sequence step slots with tap-to-add and tap-to-remove interactions, clear sequence reset, gentle distractor elimination & next-item highlighting hints, and calm feedback without countdown timer pressure.
     - **Deterministic Scoring & Metrics:**
       - $\text{accuracy} = \text{correctRounds} / \max(1, \text{correctRounds} + \text{mistakes})$
       - $\text{score} = \max(0, (\text{correctRounds} \times 100) - (\text{mistakes} \times 20) - (\text{hintCount} \times 10))$
       - Evaluated with `ClientAdaptiveEngine` and persisted to SQLite with `gameType: 'routine_recall'`.
   - *Personal Memory Bank & NER Cultural Memory (Phase 05 Implemented):*
     - **Controlled Semantic Categories:** Family, Friends, Places, Childhood, Food & Drinks, Festivals, Traditions, Milestones, Daily Life, Objects, Music & Songs, Other Memories.
     - **Data Model & Drift Schema v2:** `Memories` table expanded with `category`, `relationship`, `personName`, `location`, `eventDate`, `imagePath`, `audioPath`, `region`, `tags`, `source`, `isFavorite`, `isArchived`, `syncStatus`, `retryCount`, `lastSyncAttempt`. Preserves existing v1 records with safe migration.
     - **Media Privacy & Local Storage:** Photos and voice notes stored strictly in local application documents storage (`smriti_memories_media/`). Zero cloud uploads or third-party AI exposure.
     - **My Life Story Timeline:** Chronological personal milestones timeline with zero synthetic personal data; empty state gracefully encourages adding real family memories.
     - **Verified NER Cultural Starter Pack:** 14 open-license cultural items across 8 North Eastern states (Assam, Meghalaya, Manipur, Nagaland, Sikkim, Arunachal Pradesh, Mizoram, Tripura) with full provenance in `DATASET_MANIFEST.md`.
     - **Memory-Based Activities:** Data-driven personalized cognitive activities ("Who is this?", "What is this place?", "Do you recognize this?", gentle hints, and calm reminiscence discussion).
     - **Deterministic Memory Rescue:** Local structured retrieval from Memories + Reminders + Routines without generative LLMs or hallucination. Fallback: *"I don't have that information yet."*
     - **Caregiver Memory Management:** Full React dashboard integration with Memory Library, Add Memory form, Category breakdowns, Favorites filtering, and Cultural Content viewer.
4. **Offline-First Synchronization & Local Persistence:**
   - Local operations persist immediately to Drift SQLite (`GameSessions`, `Memories`, `Reminders`, `Routines` tables).
   - Records initialized with UUID `localId`, `syncStatus = 'pending'`, and enqueued to `SyncQueue`.
   - Dynamic `ProgressScreen` queries reactive local SQLite history via `SmritiRepository.getRecentSessions()`.
   - Zero cloud or network requirement for gameplay, metrics computation, or session logging.

### 3.2 Adaptive Difficulty Engine (`apps/patient_app/.../adaptive` & `ai/adaptive_engine`)
- **Dual-Layer Architecture:**
  - Client-side Dart engine (`ClientAdaptiveEngine`) for real-time offline recommendations immediately following exercise completion.
  - Backend Python engine (`ai/adaptive_engine`) for batch multi-day trend analysis and caregiver telemetry synthesis.
- **Deterministic Evaluation Rules:**
  - Evaluates: `accuracy` (0.0–1.0), `mistakes`, `responseTimeMs`, `hintsUsed`, `currentDifficulty` (1–3), `recentStreak`.
  - Level Up (`targetDifficulty = current + 1`): Accuracy $\ge 85\%$, mistakes $\le 1$, and hints $\le 1$.
  - Support Trigger / Level Down (`targetDifficulty = current - 1`): Accuracy $< 60\%$ or mistakes $\ge 3$.
  - Maintain (`targetDifficulty = current`): Stable performance ($60\% \le \text{accuracy} < 85\%$).
- **Strict Non-Clinical Explainability & Safety:**
  - Banned terms verified by safety filters: *"dementia"*, *"decline"*, *"diagnosis"*, *"impairment"*, *"disease"*, *"deficit"*, *"stage"*, *"score dropped"*.
  - Generates transparent, encouraging caregiver summaries explaining exactly *why* an adjustment was recommended (e.g., *"Comfortable rhythm observed with 100% accuracy. Gently increasing card pairs to keep exercise engaging."*).

### 3.3 Backend API & Database Synchronization (`backend/api`)
- **FastAPI REST Service:**
  - Base health check: `GET /health` returning `{"status": "ok"}`.
  - JWT Authentication: `POST /api/v1/auth/register`, `POST /api/v1/auth/login`, `GET /api/v1/auth/me`.
  - Batch Synchronization: `POST /api/v1/sync` accepting queued operations with operation-level idempotency.
  - Memory Management: `GET /api/v1/memories`, `GET /api/v1/memories/{id}`, `PUT /api/v1/memories/{id}`, `DELETE /api/v1/memories/{id}`.
  - Caregiver Dashboard Endpoints: `/api/v1/caregivers/patients`, `/api/v1/caregivers/patients/{id}/summary`, `/game-sessions`, `/memories`, `/reminders`, `/routines`.
- **Operation-Level Idempotency (`operation_id != entity.localId`):**
  - Every sync operation carries a unique `operation_id` (UUID).
  - Retries retain the same `operation_id`.
  - Processed operations are tracked in the `sync_operations` table, preventing duplicate database records.
- **PostgreSQL Persistence & Alembic:**
  - Full PostgreSQL schema: `users`, `patients`, `caregivers`, `patient_caregivers`, `memories`, `game_sessions`, `reminders`, `reminder_events`, `routines`, `sync_operations`.
  - Managed via SQLAlchemy 2.0 and Alembic migrations (`initial_schema`).
  - Automatic fallback to SQLite (`sqlite:///./smriti.db`) for development and automated testing when PostgreSQL is not running locally.

### 3.4 Phone Demo & QR Tooling (`scripts/demo`)
- Dynamic LAN IPv4 resolution (avoiding `127.0.0.1` and hard-coded values).
- High-contrast QR code image generation (`smriti_phone_demo_qr.png`).
- PowerShell launcher (`start_phone_demo.ps1`) binding Flutter Web to `0.0.0.0` with automatic port selection.

### 3.5 Phase 06B Authentication & Multi-Patient Data Isolation
- **Role Enforcement:** Strict server-side role validation on all endpoints; cross-role or cross-patient access returns `HTTP 403 Forbidden`.
- **Caregiver-Patient Linking Flow:** `POST /api/v1/caregivers/link-patient` links patient to authenticated caregiver by email; generic error messages mask patient existence.
- **Local Account Data Isolation:** Drift SQLite local records are tagged with `owner:$activePatientId`. Patient queries filter by the active authenticated patient. Logging out preserves local records and `SyncQueue` without data deletion. Logging in as another patient hides previous records; logging back in restores full visibility.
- **Auth & Sync Safety:** HTTP 401 / token expiration never deletes local data or pending `SyncQueue` items. Operations are safely retained and resume upon re-authentication.

---

## 4. Multilingual & Cultural Representation (NER) — Phase 07 Implemented
- **9 Supported Regional Languages:**
  1. English (`en`) — Fully Translation-Verified.
  2. Hindi (`hi`) — Fully Translation-Verified.
  3. Assamese (`as`) — Fully Translation-Verified.
  4. Bengali (`bn`) — Architecturally Supported / Translation Review Required.
  5. Meitei/Manipuri (`mni`) — Architecturally Supported / Translation Review Required.
  6. Bodo (`brx`) — Architecturally Supported / Translation Review Required.
  7. Mizo (`lus`) — Architecturally Supported / Translation Review Required.
  8. Khasi (`kha`) — Architecturally Supported / Translation Review Required.
  9. Garo (`grt`) — Architecturally Supported / Translation Review Required.
- **Repository-Wide String Audit:** Universal localization of buttons, headings, navigation, game instructions, hints, results, dialogs, validation errors, empty states, loading states, offline messages, and settings.
- **Fallback Safety:** Missing or unreviewed keys deterministically fall back to English (`en`). Never emits null, blank strings, raw keys, or broken placeholders.
- **Personal Content Preservation:** User-created memories, names, family descriptions, voice transcripts, and caregiver notes are preserved verbatim and **never automatically translated**.
- **Voice Interaction Pipeline ("Talk to Me"):**
  - Hands-free voice assistance with elderly-first pacing and full touch fallback.
  - Strict medical boundary: clinical queries trigger compassion guardrails; zero diagnostic, staging, or treatment claims.
  - Deterministic retrieval via `MemoryRescueService` and SQLite persistence.
  - Zero RenderFlex overflow tested across 320dp, 360dp, 390dp, 412dp, and 430dp viewports.
- **Cultural Packs:** Culturally resonant starter pack items across all 8 NER states with documented provenance in `DATASET_MANIFEST.md`.

---

## 5. Caregiver Intelligence & Deterministic Analytics — Phase 08 Implemented
- **Deterministic Analytics Engine:** Pure, explainable mathematical aggregation over validated PostgreSQL activity records (`GameSession`, `Reminder`, `ReminderEvent`, `SyncOperation`).
- **Strict Non-Clinical Boundary:** SMRITI is a non-diagnostic platform. All observations describe recorded application activity, exercise participation, and routine completion. SMRITI does not provide clinical diagnoses, dementia severity scores, disease progression predictions, clinical cognitive scores, or medication/treatment recommendations.
- **Metric-Specific Minimum Data Rules:**
  - Activity Participation: $\ge 2$ completed activities in current and previous periods for comparative trend (`INCREASED`, `STABLE`, `DECREASED`); otherwise `INSUFFICIENT_DATA`.
  - Game Performance: $\ge 2$ completed sessions per comparison period for trend (`IMPROVING`, `STABLE`, `DECLINING`); $\ge 1$ for current averages.
  - Reminder Adherence: $\ge 1$ scheduled reminder in each comparison period; `scheduled = 0` handled safely as `INSUFFICIENT_DATA` with `adherence_rate = None`.
  - Response Time: $\ge 2$ valid measurements in each comparison period; faster ($<-200\text{ms}$) $\rightarrow$ `IMPROVING`, slower $\rightarrow$ `DECLINING`.
  - Hint Usage: Descriptive-only observation (not classified as improving/declining).
- **Caregiver Authorization & Cross-Patient Isolation:** Server-side RBAC enforcement via `verify_patient_access`. Caregiver A $\rightarrow$ Patient A allowed; Caregiver A $\rightarrow$ Patient B returns HTTP 403 Forbidden. Zero leakage of Patient B data in error messages, aggregate queries, or trends.
- **Caregiver Dashboard Component Architecture:**
  - `SummaryCards`: 4 high-level KPI cards with real DB metrics.
  - `ActivityOverview`: Participation metrics + Recharts daily timeline.
  - `GamePerformance`: Cognitive exercise metrics, pacing, and hint observations.
  - `ReminderStatus`: Adherence rate and scheduled daily routines.
  - `ObservedTrendsCard`: Deterministic observations, review flags, and non-diagnostic disclaimer.
  - `RecentSessionsTable`: Synchronized session log.
  - `SyncHealth`: Caregiver-safe synchronization health status.
- **Period Switcher:** 7-day, 14-day, and 30-day analytics windows with reactive UI updates.

