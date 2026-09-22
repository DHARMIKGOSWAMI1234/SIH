# ADR-001: Foundation Architecture & Technology Decisions

## Status
Accepted

## Context
The SMRITI project (SIH26003) requires an elderly-friendly, culturally familiar cognitive activity and memory assistance platform designed for the North Eastern Region (NER). Key operational constraints include:
- Unreliable internet connectivity across rural/semi-urban NER areas.
- Elderly users with diverse motor and visual capabilities.
- Strict clinical boundaries (no medical diagnosis or predictive claims).
- A six-person student hackathon engineering team requiring rapid velocity, clear separation of concerns, and clean maintainability.

## Decisions

### 1. Flutter + Dart for Patient Mobile Application
- **Decision:** Use Flutter with Dart for the patient-facing application (`apps/patient_app`).
- **Rationale:** Flutter provides unified single-codebase rendering across Android and Web with sub-pixel typography control, hardware-accelerated animations, rich accessibility APIs (semantics, high contrast, screen magnification support), and zero platform-specific UI divergence.

### 2. SQLite + Drift for Local Persistence
- **Decision:** Use Drift (formerly Moor) on top of SQLite for the client database.
- **Rationale:** Drift generates compile-time type-safe Dart APIs from SQL tables, supports reactive streams, handles database migrations cleanly, and supports both native Android SQLite (`sqlite3_flutter_libs`) and Web (`drift/wasm.dart` / web fallback). This ensures local-first operation where patients can play exercises, view reminders, and record routines completely offline.

### 3. FastAPI (Python) for Backend API
- **Decision:** Use FastAPI for backend services (`backend/api`).
- **Rationale:** High performance, asynchronous event loop, automatic OpenAPI/Swagger interactive documentation, seamless integration with Python's data analysis ecosystem (NumPy, Pandas), and simple deployment model.

### 4. Deterministic Rule-Based Adaptive Difficulty Engine
- **Decision:** Build the Phase 01 adaptive difficulty engine as pure deterministic rules rather than a deep learning/black-box model.
- **Rationale:**
  - Clinical safety: Predictable, testable, and explainable behavior without hallucinations or unpredictable difficulty spikes.
  - Performance: Operates with sub-millisecond latency on low-spec client hardware without GPU requirements.
  - Explainability: Caregivers receive clear, deterministic reasons for difficulty adjustments (e.g. *"Session completed with high accuracy and rapid response times"*).

### 5. Offline-First Architecture
- **Decision:** Design all patient-side core features to be completely functional offline.
- **Rationale:** The patient application must never block or crash due to a lack of network connectivity. Local actions are stored immediately in Drift tables and queued in a `SyncQueue` table with states `pending`, `syncing`, `synced`, and `failed`.

## Consequences
- **Positive:** Robust local user experience, zero dependency on cloud servers for patient gameplay, transparent and audit-safe difficulty adaptation.
- **Negative:** Requires careful client-side synchronization logic and cross-platform SQLite configuration for Flutter Web testing.
