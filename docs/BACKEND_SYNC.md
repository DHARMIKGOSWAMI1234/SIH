# SMRITI — Backend Synchronization & Database Architecture

## 1. Architectural Overview

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
|                                 v                           |
|                   +---------------------------+             |
|                   |   SyncQueue (Local Table) |             |
|                   +-------------+-------------+             |
|                                 |                           |
|                                 v                           |
|                   +---------------------------+             |
|                   |        SyncManager        |             |
|                   |  (Exponential Backoff)    |             |
|                   +-------------+-------------+             |
+---------------------------------|---------------------------+
                                  |
                      HTTP POST /api/v1/sync
                         (Bearer JWT Auth)
                                  |
                                  v
                   +-----------------------------+
                   |     FastAPI Backend API     |
                   |   - Idempotency Verifier    |
                   |   - Conflict Evaluator      |
                   +--------------+--------------+
                                  |
                                  v
                   +-----------------------------+
                   |     PostgreSQL Database     |
                   | (or local SQLite in dev/ci) |
                   +--------------+--------------+
                                  |
                                  v
                   +-----------------------------+
                   |  Caregiver React Dashboard  |
                   |  - Authorized Patient Views |
                   |  - Non-Clinical Summaries   |
                   +-----------------------------+
```

---

## 2. Core Principles

1. **Local-First & Offline-First**:
   - The Flutter Patient App writes immediately to local Drift SQLite.
   - Core patient activities (Memory Match, Pattern Recognition, Daily Routine Recall, Memory Bank, Reminders) never require active network connectivity.
   - Network connectivity is strictly a background synchronization concern.

2. **Strict Non-Clinical Boundaries**:
   - Zero medical diagnostic claims or predictions.
   - Prohibited terms: *"dementia detected"*, *"dementia severity"*, *"cognitive decline %"*.
   - Allowed terms: *activity performance*, *engagement comfort*, *observed trend*, *scheduled reminder*.

3. **Operation-Level Idempotency (`operation_id != entity.localId`)**:
   - An entity has one `localId` across its lifecycle.
   - Each synchronization mutation creates a distinct `operation_id` (UUID) in the `SyncQueue`.
   - Examples:
     - `CREATE` memory $\rightarrow$ `operation_id` A
     - `UPDATE` memory $\rightarrow$ `operation_id` B
     - `ARCHIVE` memory $\rightarrow$ `operation_id` C
   - When a network request is retried, the `operation_id` remains stable.
   - The server tracks processed `operation_id`s in `sync_operations`. If already processed, it returns `status: "already_processed"` with the existing `server_id` without duplicating records.

4. **Deterministic Conflict Resolution**:
   - **Append-Only Entities** (`GameSessions`, `ReminderEvents`): Both records are preserved; never overwritten.
   - **Mutable Entities** (`Memories`, `Reminders`, `Routines`): Version and timestamp-aware comparison.
     - If client update timestamp is older than server's `updated_at`, server returns `status: "conflict"` with conflict details.
     - Local records are preserved without silent data loss.

---

## 3. Database Schema (PostgreSQL DDL)

The database schema is managed via SQLAlchemy and Alembic migrations:

### Tables
1. **`users`**:
   - `id` (VARCHAR(36) PK)
   - `email` (VARCHAR(255) UNIQUE NOT NULL)
   - `password_hash` (VARCHAR(255) NOT NULL)
   - `full_name` (VARCHAR(255) NOT NULL)
   - `role` (VARCHAR(50) NOT NULL: `PATIENT`, `CAREGIVER`, `ADMIN`)
   - `created_at`, `updated_at` (TIMESTAMP)

2. **`patients`**:
   - `id` (VARCHAR(36) PK)
   - `user_id` (VARCHAR(36) FK `users.id` UNIQUE)
   - `anonymous_alias` (VARCHAR(100) NOT NULL)
   - `preferred_language` (VARCHAR(10) NOT NULL DEFAULT 'en')
   - `font_scale_preference` (FLOAT DEFAULT 1.0)
   - `contrast_preference` (VARCHAR(20) DEFAULT 'standard')

3. **`caregivers`**:
   - `id` (VARCHAR(36) PK)
   - `user_id` (VARCHAR(36) FK `users.id` UNIQUE)
   - `full_name` (VARCHAR(255) NOT NULL)
   - `phone_number` (VARCHAR(50))
   - `relationship_to_patient` (VARCHAR(100))

4. **`patient_caregivers`** (Access Authorization):
   - `id` (VARCHAR(36) PK)
   - `patient_id` (VARCHAR(36) FK `patients.id`)
   - `caregiver_id` (VARCHAR(36) FK `caregivers.id`)
   - `can_view` (BOOLEAN DEFAULT TRUE)
   - `can_edit` (BOOLEAN DEFAULT FALSE)
   - UNIQUE(`patient_id`, `caregiver_id`)

5. **`memories`**:
   - `id` (VARCHAR(36) PK)
   - `patient_id` (VARCHAR(36) FK `patients.id`)
   - `local_id` (VARCHAR(36) NOT NULL)
   - `title` (VARCHAR(255) NOT NULL)
   - `description` (TEXT NOT NULL)
   - `category`, `relationship`, `person_name`, `location`, `event_date`
   - `image_path`, `audio_path`, `media_uri`, `language`, `region`, `tags`
   - `is_favorite`, `is_archived`, `version`
   - UNIQUE(`patient_id`, `local_id`)

6. **`game_sessions`**:
   - `id` (VARCHAR(36) PK)
   - `patient_id` (VARCHAR(36) FK `patients.id`)
   - `local_id` (VARCHAR(36) NOT NULL)
   - `game_type` (VARCHAR(100) NOT NULL)
   - `score` (INTEGER), `accuracy` (FLOAT), `mistakes` (INTEGER)
   - `response_time_ms` (FLOAT), `difficulty` (INTEGER), `hint_count` (INTEGER)
   - `started_at`, `completed_at` (TIMESTAMP)
   - UNIQUE(`patient_id`, `local_id`)

7. **`reminders`** & **`reminder_events`**:
   - `reminders`: `id`, `patient_id`, `local_id`, `title`, `reminder_type`, `scheduled_time`, `enabled`, `version`
   - `reminder_events`: `id`, `patient_id`, `local_id`, `reminder_id`, `event_type`, `occurred_at`

8. **`routines`**:
   - `id`, `patient_id`, `local_id`, `title`, `steps_json`, `preferred_time`, `enabled`, `version`

9. **`sync_operations`** (Idempotency Audit Table):
   - `id` (VARCHAR(36) PK)
   - `operation_id` (VARCHAR(64) UNIQUE NOT NULL)
   - `patient_id` (VARCHAR(36) FK `patients.id`)
   - `entity_type` (VARCHAR(50) NOT NULL)
   - `operation` (VARCHAR(20) NOT NULL)
   - `local_id` (VARCHAR(36) NOT NULL)
   - `server_id` (VARCHAR(36))
   - `status` (VARCHAR(30) NOT NULL)
   - `client_updated_at`, `processed_at` (TIMESTAMP)

---

## 4. API Endpoints

### Authentication & Profile
- `POST /api/v1/auth/register`: Register user + Patient/Caregiver profile $\rightarrow$ JWT Token
- `POST /api/v1/auth/login`: Authenticate credentials $\rightarrow$ JWT Token
- `GET /api/v1/auth/me`: Get current user and profile details
- `PUT /api/v1/auth/patient-profile`: Update patient language, font scale, or contrast preferences

### Synchronization
- `POST /api/v1/sync`: Batch sync endpoint with idempotency verification
- `POST /api/v1/sync/memories`: Single memory sync endpoint

### Memories
- `GET /api/v1/memories`: List memories for authenticated patient
- `GET /api/v1/memories/{id}`: Get memory by ID
- `PUT /api/v1/memories/{id}`: Update memory
- `DELETE /api/v1/memories/{id}`: Delete memory

### Caregiver Dashboard
- `POST /api/v1/caregivers/link-patient`: Link caregiver to patient by email (masks account existence on failure)
- `GET /api/v1/caregivers/patients`: List authorized patients
- `GET /api/v1/caregivers/patients/{id}/summary`: Aggregated non-clinical metrics
- `GET /api/v1/caregivers/patients/{id}/game-sessions`: Paginated session history
- `GET /api/v1/caregivers/patients/{id}/memories`: Memories
- `GET /api/v1/caregivers/patients/{id}/reminders`: Reminders
- `GET /api/v1/caregivers/patients/{id}/routines`: Routines

---

## 5. Local Account Data Isolation & Auth Safety

### Multi-Patient Local Boundary
- Logout **preserves** local SQLite records and `SyncQueue` for all patients.
- Patient queries filter strictly by the active authenticated patient (`owner:$activePatientId` tag).
- Logging in as Patient B ensures Patient B **cannot** see Patient A's memories.
- Logging back in as Patient A makes Patient A's memories fully visible again.
- No local data is deleted during account switches.

### HTTP 401 & Token Expiration Safety
- When JWT expires or the server returns `HTTP 401`:
  1. Local database records are untouched.
  2. `SyncQueue` operations are preserved without retry penalty.
  3. Operations are **never** marked as permanently lost.
  4. Authentication state transitions safely to `unauthenticated`.
  5. Sync automatically resumes upon re-authentication.

---

## 6. Local Setup Instructions

### Backend (Python FastAPI)
```bash
cd backend/api
python -m venv .venv
# On Windows:
.venv\Scripts\activate
# On Linux/macOS:
source .venv/bin/activate

pip install -r requirements.txt
uvicorn backend.api.app.main:app --reload --host 0.0.0.0 --port 8000
```

### PostgreSQL Setup
1. Local live PostgreSQL 18 instance running on `localhost:5432`:
   - Database: `smriti_db`
   - User: `smriti_user`
2. Configure `.env`:
   ```env
   DATABASE_URL=postgresql+psycopg2://smriti_user:<LOCAL_PASSWORD>@localhost:5432/smriti_db
   ```
3. Run Alembic migrations:
   ```bash
   alembic upgrade head
   ```

### Running Tests
```bash
# Backend pytest suite (17 tests across backend/api/tests and tests/):
$env:PYTHONPATH="."
python -m pytest backend/api/tests/ tests/ -v

# Patient App Flutter test suite (117 tests):
cd apps/patient_app
flutter test

# Caregiver Dashboard build:
cd apps/caregiver_dashboard
npm run build
```

