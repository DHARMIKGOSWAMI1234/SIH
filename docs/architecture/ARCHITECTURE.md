# SMRITI System Architecture Specification

## 1. Overview & Diagram

```
+-------------------------------------------------------------+
|                 SMRITI PATIENT MOBILE APP                   |
|                      (Flutter / Dart)                       |
|                                                             |
|  +------------------+  +-----------------+  +------------+  |
|  | Cognitive Games  |  | Reminders &     |  | Memories & |  |
|  | - Memory Match   |  | Daily Routines  |  | Cult. Pack |  |
|  | - Pattern Recog. |  |                 |  |            |  |
|  | - Routine Recall |  |                 |  |            |  |
|  +--------+---------+  +--------+--------+  +-----+------+  |
|           |                     |                 |         |
|           +---------------------+-----------------+         |
|                                 |                           |
|                                 v                           |
|                   +---------------------------+             |
|                   | Local Drift/SQLite Layer  |             |
|                   +-------------+-------------+             |
|                                 |                           |
|        +------------------------+-------------------+       |
|        |                                            |       |
|        v                                            v       |
|  +--------------------+                   +-----------------+
|  | Deterministic      |                   | Sync Queue      |
|  | Adaptive Engine    |                   | Service         |
|  +--------------------+                   +--------+--------+
+----------------------------------------------------|--------+
                                                     |
                                            Internet Available
                                                     |
                                                     v
                                      +-------------------------------+
                                      |      FastAPI Backend API      |
                                      |          (Python)             |
                                      +--------------+----------------+
                                                     |
                                                     v
                                      +-------------------------------+
                                      |      PostgreSQL Database      |
                                      |      (Future Cloud / LAN)     |
                                      +--------------+----------------+
                                                     |
                                 +-------------------+-------------------+
                                 |                                       |
                                 v                                       v
                     +-----------------------+               +-----------------------+
                     | Caregiver Dashboard   |               | Aggregated Analytics  |
                     | (React / TypeScript)  |               | (Non-clinical trends) |
                     +-----------------------+               +-----------------------+
```

## 2. Offline-First & Synchronization Strategy

### 2.1 Local-First Operations
- Every action initiated by the patient (completing a game, checking off a reminder, viewing a memory) is committed synchronously to the local SQLite database.
- A local record is assigned a UUID `localId` immediately.
- The `serverId` column remains `null` until successfully synchronized with the backend.

### 2.2 Sync Queue & State Transitions
Every modifiable entity writes a corresponding entry into the `SyncQueue` table:
- **`pending`**: Newly created or modified locally, waiting for network connectivity.
- **`syncing`**: In-flight payload sent to the backend endpoint.
- **`synced`**: Server acknowledged receipt; server timestamp and server ID recorded.
- **`failed`**: Network error or temporary server 5xx; increments `retryCount` with exponential backoff.
- **`conflict`**: Server rejected change; resolved via local-wins for patient input and server-wins for caregiver schedule updates.

### 2.3 Privacy & Data Governance Boundaries
- No personal identifiable information (PII) is transmitted without explicit caregiver consent.
- Telemetry captures non-clinical performance indicators only: reaction times, hints requested, cards matched, and routine completion timestamps.
- Zero raw audio or camera recordings are uploaded to the cloud without explicit opt-in.

---

## 3. Cognitive Game Architecture: Memory Match

### 3.1 State Machine Lifecycle
```
[Intro Screen] 
      │ Select Difficulty (Easy: 3 pairs, Med: 4 pairs, Hard: 6 pairs)
      ▼
[Game Screen Initialized]
      │ State: previewing (0.5s - 1.5s reveal of all cards)
      ▼
[Gameplay Active] ◄────────────────────────────────────────┐
      │ Card 1 Tap -> State: checking (turnLock = true)     │
      │ Card 2 Tap -> Validate Pair                         │
      ├── Match: mark cards 'isMatched', update accuracy    │ (Pairs remaining)
      └── Mismatch: delay 1000ms, flip cards back down      │
      │                                                     │
      └─────────────────────────────────────────────────────┘
      │ (All pairs matched)
      ▼
[Completion & Evaluation]
      │ Calculate accuracy, response times, score
      │ Pass metrics to ClientAdaptiveEngine (offline)
      ▼
[Local Persistence & Results]
      │ Insert into Drift SQLite GameSessions (status: pending)
      │ Enqueue to SyncQueue
      │ Display ResultsScreen with caregiver explainability note
      ▼
[Progress Screen Updated]
      │ Real-time local SQLite query reflects new session
```

### 3.2 Metrics & Deterministic Scoring Formulas
- **Accuracy:**
  $$\text{accuracy} = \frac{\text{matchedPairs}}{\max(1, \text{totalAttempts})}$$
- **Score:**
  $$\text{score} = \max(0, (\text{matchedPairs} \times 100) - (\text{mistakes} \times 15) - (\text{hintsUsed} \times 20))$$
- **Adaptive Adjustment Rules:**
  - `INCREASE` (Target = Current + 1): Accuracy $\ge 0.85 \land \text{mistakes} \le 1 \land \text{hintsUsed} \le 1$
  - `SUPPORT_REQUIRED` (Target = Current - 1): Accuracy $< 0.60 \lor \text{mistakes} \ge 3$
  - `MAINTAIN` (Target = Current): Otherwise.

### 3.3 Cognitive Game Architecture: Pattern Recognition
```
[Intro Screen]
      │ Select Difficulty (Easy: 4 questions/2 choices, Med: 5 questions/3 choices, Hard: 6 questions/4 choices)
      ▼
[Question Loop Active] ◄─────────────────────────────────────┐
      │ Render Sequence with target slot: [A] -> [B] -> [?]   │
      │ User Taps Option (turnLock = false)                  │
      ├── Correct Match:                                      │
      │     - Reveal answer in target slot                    │ (Questions remaining)
      │     - Banner: "Well done! That fits the pattern."     │
      │     - Delay 1400ms -> next question                   │
      └── Mistake:                                            │
            - Banner: "Let's look closely at pattern again."  │
            - Option dimmed to prevent confusion              │
      │                                                       │
      └───────────────────────────────────────────────────────┘
      │ (All questions completed)
      ▼
[Evaluation & SQLite Persistence]
      │ Accuracy = correctAnswers / max(1, totalAttempts)
      │ Score = max(0, (correctAnswers * 100) - (mistakes * 20) - (hintCount * 10))
      │ ClientAdaptiveEngine.evaluate(...)
      │ Insert into Drift SQLite GameSessions (gameType: 'pattern_recognition', status: 'pending')
      ▼
[Results Screen & Dynamic Progress History]
      │ Displays metrics, adaptive suggestion, and records to local activity feed
```

### 3.4 Cognitive Game Architecture: Daily Routine Recall
```
[Intro Screen]
      │ Select Difficulty (Easy: 3 steps/3-4 options, Med: 4 steps/5 options, Hard: 5 steps/7 options)
      ▼
[Question Loop Active] ◄────────────────────────────────────────┐
      │ Display Step Slots [1] [2] [3]... + Available Pool      │
      │ User Taps Available Activity -> Adds to Next Slot       │
      │ User Taps Slotted Item -> Removes Item Back to Pool     │
      │ Hint Requested -> Eliminates Distractor OR Highlights   │
      │ User Taps "Check Sequence" (all slots populated)        │
      ├── Correct Chronological Order:                          │
      │     - Slots turn calm sage green                        │ (Questions remaining)
      │     - Banner: "Wonderful! That is the right sequence."   │
      │     - Delay 1500ms -> advance to next round             │
      └── Mismatch / Incorrect Order:                           │
            - Slots highlight warm amber                        │
            - Banner: "Take your time. Let's review the order." │
            - User edits selections and checks again            │
      │                                                         │
      └─────────────────────────────────────────────────────────┘
      │ (All routine rounds completed)
      ▼
[Evaluation & SQLite Persistence]
      │ Accuracy = correctRounds / max(1, correctRounds + mistakes)
      │ Score = max(0, (correctRounds * 100) - (mistakes * 20) - (hintCount * 10))
      │ ClientAdaptiveEngine.evaluate(...) [non-clinical deterministic evaluation]
      │ Insert into Drift SQLite GameSessions (gameType: 'routine_recall', status: 'pending')
      │ Enqueue to SyncQueue (entityType: 'GameSessions', operation: 'INSERT')
      ▼
[Results Screen & Dynamic Activity History]
      │ Displays accuracy, score, time taken, hint count, and adaptive recommendations
      │ ProgressScreen dynamically displays "Daily Routine Steps" with checklist badge
```

---

## 4. Caregiver Transparency & Safety Filter
All adaptive summaries pass through strict lexical enforcement before display or persistence:
- **Banned Lexicon:** `["dementia", "decline", "diagnosis", "impairment", "disease", "deficit", "stage", "score dropped"]`
- **Output Contract:** Explanations focus solely on pace, comfort, and engagement to preserve dignity and prevent clinical misunderstanding.

---

## 5. Phase 06A Synchronization & PostgreSQL Architecture

### 5.1 End-to-End Synchronization Flow
```
Flutter Patient App (Local Drift SQLite)
  └── Writes locally first (zero network dependency)
  └── Enqueues SyncQueue item (unique operation_id UUID)
        │
        ▼
SyncManager (Background Client)
  └── Assembles batch payload
  └── HTTP POST /api/v1/sync (Bearer JWT)
        │
        ▼
FastAPI Backend
  ├── Idempotency Check: lookup operation_id in sync_operations table
  │     ├── Found: return "already_processed" with existing server_id
  │     └── New: process mutation in transaction & record operation_id
  ├── Conflict Check: timestamp/version aware (reject stale updates)
  └── PostgreSQL Persistence: 1:1 mapped records
        │
        ▼
Caregiver Dashboard (React / TypeScript)
  └── Fetches authorized patient records via /api/v1/caregivers/...
  └── Displays live session history, memories, routines, and reminders
```

### 5.2 Idempotency Key Specification
- Every `SyncQueue` item generates a distinct `operation_id` (UUID).
- The entity's `localId` remains the entity identifier.
- Retries of the same `SyncQueue` item preserve the original `operation_id`.
- The backend stores every processed `operation_id` in the `sync_operations` table.
- A duplicate or replayed sync request is recognized immediately without creating duplicate rows.

### 5.3 Deterministic Conflict Strategy
- **Append-Only** (`GameSessions`, `ReminderEvents`): Both records are preserved; never overwritten.
- **Mutable** (`Memories`, `Reminders`, `Routines`): Timestamp/version-aware. Stale client updates (`client_updated_at < server.updated_at`) receive `status: "conflict"` and conflict payload. Patient local data is never deleted or corrupted.

---

## 6. Phase 06B Authentication & Multi-Patient Isolation Architecture

### 6.1 Role-Based Access Control
- **`PATIENT`**: Authorized for self patient profile, personal memories, cognitive game sessions, reminders, routines, and sync mutations. Denied access to caregiver portal endpoints (HTTP 403).
- **`CAREGIVER`**: Authorized for caregiver profile, linking patients by email, and accessing linked patient summaries, game sessions, memories, routines, and reminders. Cross-patient access without explicit link is forbidden (HTTP 403).
- **`ADMIN`**: System-level administrative supervision.

### 6.2 Multi-Patient Local Account Isolation (Drift SQLite)
```
[Patient A Logs In]
  ├── Active Patient ID: 'patient-A-uuid'
  ├── Insert Memory: Tagged with 'owner:patient-A-uuid'
  └── Query Memories: WHERE tags LIKE '%owner:patient-A-uuid%' -> Returns Patient A memories

[Patient A Logs Out]
  ├── Session cleared from SecureAuthStorage
  ├── Local SQLite records PRESERVED (Zero data deletion)
  └── SyncQueue records PRESERVED

[Patient B Logs In]
  ├── Active Patient ID: 'patient-B-uuid'
  └── Query Memories: WHERE tags LIKE '%owner:patient-B-uuid%' -> Patient A memories are INVISIBLE

[Patient B Logs Out & Patient A Logs In Again]
  ├── Active Patient ID: 'patient-A-uuid'
  └── Query Memories: Returns Patient A memories intact
```

### 6.3 Caregiver Linking Privacy
- Caregiver must already be authenticated with valid JWT.
- Endpoint `POST /api/v1/caregivers/link-patient` accepts `patient_email` and optional `relationship_type`.
- If the patient does not exist or is not a registered `PATIENT`, a generic 404 message (`"Unable to link patient with the provided information."`) is returned to avoid email enumeration.
- When linked, a `patient_caregivers` authorization row is created with `can_view=True`.

### 6.4 Auth & Sync Safety (401 Handling)
- When the JWT token expires or the server returns `HTTP 401`:
  - Local Drift SQLite data is **never** deleted.
  - `SyncQueue` pending operations are preserved intact without penalty.
  - Operations are not marked as permanently failed.
  - Client state transitions safely to `unauthenticated`.
  - Upon re-authentication, `SyncManager` immediately resumes queue processing.

---

## 7. Phase 07 Multilingual Localization & Voice Interaction Architecture

### 7.1 9 Supported Languages & Verification Framework
SMRITI supports exactly **9 regional languages of India and the North Eastern Region**:
1. **English (`en`)**: Fully Translation-Verified.
2. **Hindi (`hi`)**: Fully Translation-Verified.
3. **Assamese (`as`)**: Fully Translation-Verified.
4. **Bengali (`bn`)**: Architecturally Supported / Translation Review Required.
5. **Meitei/Manipuri (`mni`)**: Architecturally Supported / Translation Review Required.
6. **Bodo (`brx`)**: Architecturally Supported / Translation Review Required.
7. **Mizo (`lus`)**: Architecturally Supported / Translation Review Required.
8. **Khasi (`kha`)**: Architecturally Supported / Translation Review Required.
9. **Garo (`grt`)**: Architecturally Supported / Translation Review Required.

### 7.2 Full-App Localization & Deterministic Fallback
- **Universal Localization**: Every user-facing UI element (headings, buttons, dialogs, game cards, navigation, reminders, error states, accessibility labels) uses `AppStrings.get(...)`.
- **Fallback Safety**: Unreviewed or missing keys deterministically fall back to English (`en`). The system never emits null, blank strings, raw keys, or broken placeholders.
- **Personal Content Preservation**: User-created memories, names, family descriptions, voice transcripts, and caregiver notes are preserved verbatim and **never automatically translated**.

### 7.3 Voice Interaction ("Talk to Me") Pipeline
- **Voice is Optional**: Touch controls remain universal and unblocked at all times.
- **Deterministic Intent Parsing**: `IntentService` maps spoken transcripts into structured actions (`familyQuery`, `reminderQuery`, `routineQuery`, `gameLaunch`, `greeting`, `medicalQuery`).
- **Strict Non-Clinical Boundary**: Clinical queries (`dementia`, `alzheimer`, `diagnos`, `stage`, `cure`, `donepezil`, `treatment`) trigger an immediate, localized compassion guardrail directing the patient to their physician or caregiver.
- **Memory Rescue**: Structured retrieval from local SQLite memories without external LLMs or hallucinations.
- **Calm Elderly UX**: Synchronized 20sp high-contrast visual text and 0.85x calm audio playback with zero RenderFlex overflow across 320dp–430dp viewports.

---

## 8. Phase 08 Caregiver Intelligence, Analytics & Observed Trends Architecture

### 8.1 Core Principle & Clinical Boundary
Patient activity recorded in offline SQLite is synced idempotently to PostgreSQL. The deterministic analytics engine aggregates this data into caregiver-facing insights.
- **Strict Non-Clinical Boundary**: SMRITI does not perform diagnostic scoring, dementia severity assessment, disease progression forecasting, or medical/treatment prescription.
- All metrics describe observed application activity, cognitive game comfort, and routine completion.

### 8.2 Metric-Specific Data Sufficiency & Trend Directionality
- **Activity Participation**: $\ge 2$ completed activities in both current and previous windows for comparative trend (`INCREASED`, `STABLE`, `DECREASED`); otherwise `INSUFFICIENT_DATA`.
- **Game Performance**: $\ge 2$ completed sessions in each period for trend (`IMPROVING`, `STABLE`, `DECLINING`); $\ge 1$ for current period averages.
- **Game Mistakes**: Inverted directional semantics (fewer mistakes $\rightarrow$ `IMPROVING`, more mistakes $\rightarrow$ `DECLINING`).
- **Response Time**: $\ge 2$ valid measurements ($>0\text{ms}$) per period; faster ($<-200\text{ms}$) $\rightarrow$ `IMPROVING`, slower $\rightarrow$ `DECLINING`.
- **Hints**: Descriptive-only observation (not classified as improving/declining).
- **Reminder Adherence**: Completed / Scheduled; scheduled occurrences strictly counted up to `now` (future scheduled occurrences today are excluded); `scheduled = 0` yields `adherence_rate = None` and `INSUFFICIENT_DATA`.

### 8.3 Caregiver Authorization & Cross-Patient Isolation
- Server-side RBAC enforced via `verify_patient_access` dependency.
- Caregiver A $\rightarrow$ Patient A: `200 OK`.
- Caregiver A $\rightarrow$ Patient B: `403 Forbidden`.
- Zero leakage of Patient B data in error messages, aggregate queries, or trends.

### 8.4 Caregiver Dashboard Structure
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
- Period switcher: 7-day, 14-day, and 30-day analytics windows.




