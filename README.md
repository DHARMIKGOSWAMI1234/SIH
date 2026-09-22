# SMRITI — AI Cognitive Care Companion
### SIH26003: AI-Based Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in North Eastern Region (NER)
**Ministry of Development of North Eastern Region (MDoNER)**

---

## Strict Clinical Boundary Notice
> [!IMPORTANT]
> **SMRITI IS NOT A DIAGNOSTIC SYSTEM, MEDICAL PREDICTOR, OR CLINICAL DECISION TOOL.**
> SMRITI is an assistive platform for cognitive stimulation, familiar memory recall, daily routine support, and caregiver transparency. It does not detect, diagnose, treat, or cure dementia or any other neurological condition. All metrics and UI copy adhere strictly to safe, non-clinical terminology.

---

## Status & Roadmap

| Feature Area | Status | Notes |
| :--- | :--- | :--- |
| **Monorepo Architecture** | **IMPLEMENTED** | Monorepo layout with clear separation of apps, backend, AI, shared, docs, scripts. |
| **Elderly-First Design System** | **IMPLEMENTED** | High-contrast, large touch targets, 18sp+ typography, calm restorative palette. |
| **Patient App Foundation** | **IMPLEMENTED** | Flutter app supporting Android and Web with 9 foundation screens. |
| **Playable Memory Match Game** | **IMPLEMENTED** | Real interactive card pairing across Easy, Medium, and Hard with 3D flip animation. |
| **Playable Pattern Recognition** | **IMPLEMENTED** | Real sequence rhythm recall with Easy, Medium, Hard tiers, hint elimination, and calm feedback. |
| **Daily Routine Recall** | **IMPLEMENTED** | Real chronological daily sequence recall with Easy, Medium, Hard tiers, gentle hints, and calm feedback. |
| **Personal Memory Bank** | **IMPLEMENTED** | Personalized reminiscence cards, local photo storage, voice note player, favorites, and archive. |
| **My Life Story Timeline** | **IMPLEMENTED** | Chronological personal milestones timeline with zero synthetic data and graceful empty state. |
| **NER Cultural Content Packs** | **IMPLEMENTED** | 14 verified starter pack items across 8 NER states with documented provenance in `DATASET_MANIFEST.md`. |
| **Memory-Based Activities** | **IMPLEMENTED** | Data-driven cognitive activities ("Who is this?", "What is this place?", gentle hints, reminiscence prompt). |
| **Memory Rescue Foundation** | **IMPLEMENTED** | Local structured retrieval from Memories + Reminders + Routines with zero hallucinations. |
| **Caregiver Memory Portal** | **IMPLEMENTED** | React dashboard with Memory Library, Add Memory, Categories, Favorites, and Cultural Content viewer. |
| **Local Drift/SQLite Database** | **IMPLEMENTED** | Type-safe persistence for sessions, reminders, routines, memories (v2 schema), and sync queue. |
| **Deterministic Adaptive Engine** | **IMPLEMENTED** | 100% explainable rule-based difficulty adjustment (Python & Dart client engine). |
| **Session Activity History** | **IMPLEMENTED** | Dynamically queries Memory Match, Pattern Recognition, and Routine Recall sessions from local SQLite. |
| **FastAPI Backend Foundation** | **IMPLEMENTED** | Async API with CORS, `/health` endpoint, and architecture for future sync. |
| **Dynamic LAN Phone Demo** | **IMPLEMENTED** | Automated IP detection, QR generation, and one-click PowerShell launcher. |
| **Server-side PostgreSQL Sync & Idempotency** | **IMPLEMENTED** | Real FastAPI sync endpoints, PostgreSQL schema, Alembic migrations, operation-level idempotency, and caregiver dashboard connectivity. |
| **Real JWT Auth & Role Enforcement** | **IMPLEMENTED** | FastAPI JWT auth with `PATIENT`, `CAREGIVER`, `ADMIN` roles, 403 Forbidden enforcement for cross-patient data access. |
| **Multi-Patient Local Account Isolation** | **IMPLEMENTED** | Drift SQLite multi-patient data boundary. Logout preserves records; new patient login isolates data without deletion. |
| **Caregiver-Patient Linking Flow** | **IMPLEMENTED** | Privacy-conscious email linking endpoint and React dashboard UI with error masking. |
| **Elderly-First Auth UI (Flutter)** | **IMPLEMENTED** | 56–64dp touch targets, 18sp+ typography, offline continuity, and 401 sync retention. |
| **9-Language Multilingual Localization** | **IMPLEMENTED** | Universal localization (en, hi, as verified; bn, mni, brx, lus, kha, grt supported) with deterministic English fallback. |
| **Voice Interaction ("Talk to Me")** | **IMPLEMENTED** | Hands-free deterministic retrieval (family memories, reminders, routines) with strict non-clinical safety and touch fallback. |

---

## Monorepo Layout

```
SMRITI-SIH26003/
├── apps/
│   ├── patient_app/             # Flutter + Dart elderly-first app
│   └── caregiver_dashboard/     # React + TypeScript clean foundation
├── backend/
│   └── api/                     # Python + FastAPI REST server
├── ai/
│   ├── adaptive_engine/         # Deterministic difficulty engine
│   ├── analytics/               # Non-clinical trend calculations
│   ├── models/                  # Shared data models
│   └── tests/                   # Pytest suite
├── data/
│   ├── raw/
│   ├── processed/
│   ├── demo/
│   └── DATASET_MANIFEST.md      # Data governance & NER cultural schema
├── shared/
│   ├── schemas/                 # Shared data schemas
│   └── constants/               # System constants
├── docs/
│   ├── architecture/            # Architecture specifications
│   ├── decisions/               # ADR-001 Architecture Decision Record
│   └── demo/                    # Phone demo instructions
├── scripts/
│   └── demo/                    # Dynamic LAN IP detection and QR generator
├── tests/                       # Integration test suites
├── .gitignore
├── .env.example
├── README.md
└── SMRITI_MASTER_SPEC.md
```

---

## Quick Start & Setup

### 1. Patient App (Flutter)
```powershell
cd apps/patient_app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test
flutter run -d chrome
```

### 2. Backend API (FastAPI)
```powershell
cd backend/api
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pytest tests/
uvicorn app.main:app --reload --port 8000
```
Health endpoint test: `curl http://127.0.0.1:8000/health` -> `{"status": "ok"}`

### 3. AI Adaptive Engine (Python)
```powershell
pytest ai/tests
```

### 4. Physical Phone Demo (Dynamic LAN QR)
Connect your PC and smartphone to the same Wi-Fi network, then run:
```powershell
.\scripts\demo\start_phone_demo.ps1
```
Scan the generated QR code with your phone camera to preview the live application.

### 5. Caregiver Dashboard (React + Recharts)
```powershell
cd apps/caregiver_dashboard
npm install
npm run dev
```
Access the Caregiver Dashboard at `http://localhost:5173` with 7/14/30-day deterministic analytics, Recharts participation timeline, game performance, reminder adherence, and sync health.
