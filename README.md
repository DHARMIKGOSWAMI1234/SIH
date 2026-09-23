# BANDHU — AI Cognitive Care Companion

### SIH26003: AI-Based Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in North Eastern Region (NER)
**Ministry of Development of North Eastern Region (MDoNER)**
**Team**: THE DEBUGGERS • **Document Version**: 2.0 • **Evaluation Checkpoint**: September 2026

[![Flutter](https://img.shields.io/badge/Flutter-3.47.2-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.2-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Python](https://img.shields.io/badge/Python-3.13.15-3776AB?logo=python&logoColor=white)](https://python.org)
[![Node.js](https://img.shields.io/badge/Node.js-24.18.0-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![React](https://img.shields.io/badge/React-18.3+-61DAFB?logo=react&logoColor=black)](https://react.dev)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.4+-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org)
[![SQLite](https://img.shields.io/badge/SQLite-Drift%202.35+-003B57?logo=sqlite&logoColor=white)](https://drift.simonbinder.eu)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20Web-brightgreen)](#patient-application)
[![Offline First](https://img.shields.io/badge/Architecture-Offline--First-blueviolet)](#offline-first-architecture)
[![Clinical Boundary](https://img.shields.io/badge/Clinical%20Boundary-Non--Diagnostic-orange)](#privacy-safety-clinical-boundary)

BANDHU is an offline-first, culturally familiar digital cognitive care companion engineered specifically for elderly individuals experiencing mild cognitive impairment, familiar memory challenges, or routine disorientation across India's North Eastern Region (NER). Built around an elderly-first accessibility design system, deterministic adaptive difficulty, and local-first SQLite persistence, BANDHU empowers older adults to participate in daily cognitive exercises, preserve cherished family memories, and navigate daily routines — while providing family caregivers transparent, patient-scoped activity monitoring without requiring continuous internet connectivity.

---

<a id="complete-project-plan"></a>
## 📘 Complete Project Plan

For the complete technical roadmap, implemented features, architecture, safety boundaries, verification status, GitHub documentation rules, and post-selection development plan, check out the complete BANDHU Project Navigation & Development Document.

**[📘 Check out BANDHU_PND.pdf — Complete Project Plan](./BANDHU_PND.pdf)**

---

## 📌 Quick Navigation

- [🧠 What is BANDHU?](#what-is-bandhu)
- [🎯 SIH Problem Statement](#sih-problem-statement)
- [🌍 Why This Problem Matters](#why-this-problem-matters)
- [💡 Our Solution](#our-solution)
- [👥 Target Users](#target-users)
- [✨ Key Features](#key-features)
- [🏗️ System Architecture](#system-architecture)
- [🔄 How BANDHU Works](#how-bandhu-works)
- [📱 Patient Application](#patient-application)
- [👨‍⚕️ Caregiver Dashboard](#caregiver-dashboard)
- [🎮 Cognitive Games](#cognitive-games)
- [🤖 Adaptive Difficulty](#adaptive-difficulty)
- [🆘 Context-Aware BANDHU Help](#context-aware-bandhu-help)
- [🧠 Personal Memory & Daily Assistance](#personal-memory-daily-assistance)
- [🌐 Languages & NER Cultural Support](#languages-ner-cultural-support)
- [🔒 Privacy, Safety & Clinical Boundary](#privacy-safety-clinical-boundary)
- [🤖 AI / ML Strategy](#ai-ml-strategy)
- [📊 Dataset & Research Strategy](#dataset-research-strategy)
- [📴 Offline-First Architecture](#offline-first-architecture)
- [🔗 Caregiver Pairing](#caregiver-pairing)
- [📁 Repository Structure](#repository-structure)
- [💻 Technology Stack](#technology-stack)
- [⚙️ Prerequisites](#prerequisites)
- [📥 Installation](#installation)
- [🚀 Quick Start](#quick-start)
- [🧑‍💻 Detailed Setup](#detailed-setup)
- [📱 Running on Android](#running-on-android)
- [💻 Running the Caregiver Dashboard](#running-the-caregiver-dashboard)
- [⚡ Running the Backend](#running-the-backend)
- [🔄 Running the Complete Demo](#running-the-complete-demo)
- [📴 Testing Offline Mode](#testing-offline-mode)
- [🧪 Testing & Verification](#testing-verification)
- [🛠️ Troubleshooting](#troubleshooting)
- [📘 Complete Project Plan](#complete-project-plan)
- [🗺️ Current Status](#current-status)
- [🚀 If Selected — Future Roadmap](#if-selected-future-roadmap)
- [⚠️ Important Technical Notes](#important-technical-notes)
- [📄 Documentation](#documentation)
- [👥 Team](#team)
- [📜 License / Project Notes](#license-project-notes)

---

<a id="what-is-bandhu"></a>
## 🧠 What is BANDHU?

**BANDHU** (*meaning "Friend / Companion"*) is an assistive, local-first software platform designed to support elderly individuals and their caregivers through non-pharmacological, culturally familiar cognitive stimulation and day-to-day routine management.

BANDHU bridges the critical care gap in the North Eastern Region by integrating:
1. **Culturally Resonant Cognitive Games**: Familiar exercises (Memory Match, Pattern Recognition, Daily Routine Recall) drawing on tea gardens, local flora, traditional architecture, and seasonal rhythms.
2. **Personal Memory Bank**: Secure, local multimedia storage for family photographs, voice notes, and milestone stories that prompt comforting reminiscence.
3. **Daily Routine & Medication Assistance**: Non-intrusive chronological timeline tracking daily hydration, meals, rest, and doctor-prescribed routines.
4. **Context-Aware BANDHU Help**: An offline, on-device assistant that senses when a senior is inactive or stuck, offering gentle, non-punitive hints derived from the active screen or game state.
5. **Caregiver Transparency Dashboard**: A companion web portal providing family members and attendants clear, aggregated visibility into exercise participation, adherence trends, and memory records.
6. **Robust Offline-First Continuity**: Complete standalone functionality on device SQLite with opportunistic background synchronization whenever Wi-Fi or cellular networks become available.

> [!IMPORTANT]
> **Strict Clinical Boundary Notice**
> **BANDHU IS NOT A DIAGNOSTIC SYSTEM, MEDICAL PREDICTOR, OR CLINICAL DECISION TOOL.**
> BANDHU is an assistive engagement and routine support platform. It does **not** diagnose dementia, estimate cognitive impairment stages, predict disease progression, or prescribe medications. It is **not** a replacement for neurologists, geriatricians, or licensed medical practitioners. All gameplay metrics, difficulty adjustments, and caregiver observations adhere strictly to audited, non-clinical terminology.

---

<a id="sih-problem-statement"></a>
## 🎯 SIH Problem Statement

- **Problem Statement ID**: `SIH26003`
- **Title**: **AI-Based Cognitive Gaming and Memory Assistance Platform for Elderly Dementia Patients in North Eastern Region (NER)**
- **Organization**: **Ministry of Development of North Eastern Region (MDoNER)**
- **Category**: Software
- **Focus Area**: Healthcare & Elderly Care Technology for Regional Populations

---

<a id="why-this-problem-matters"></a>
## 🌍 Why This Problem Matters

Caring for aging populations experiencing cognitive decline presents profound, compounding challenges across the North Eastern Region of India:

1. **Geographical Isolation & Infrastructure Constraints**: Rural hills, valleys, and river islands frequently experience intermittent power and cellular connectivity, rendering cloud-only applications unusable.
2. **High Linguistic Diversity**: Across the 8 North Eastern states, dozens of indigenous languages and dialects are spoken (Assamese, Manipuri/Meitei, Bodo, Mizo, Khasi, Garo, Bengali, etc.). Standard commercial tools rarely provide authentic regional language support.
3. **Cultural Alienation in Western Cognitive Apps**: Existing cognitive training apps rely on Western metaphors (playing cards, subway maps, unfamiliar cityscapes) that cause confusion and anxiety rather than reassurance.
4. **Caregiver Burden**: Family members often work away from home or balance demanding jobs, needing trustworthy visibility into their elder's daily activity, routines, and comfort without constant physical presence.
5. **Need for Safe, Non-Alarmist Technology**: Seniors need gentle cognitive encouragement, not stressful medical tests or intimidating diagnostic scorecards.

---

<a id="our-solution"></a>
## 💡 Our Solution

BANDHU solves these regional challenges through an integrated **Seven-Layer Assistance Architecture**:

```
+-------------------------------------------------------------------------+
| Layer 1: Cognitive Exercises (Memory Match, Pattern Recog, Routine)     |
+-------------------------------------------------------------------------+
| Layer 2: Personal Memory Bank & Verified NER Cultural Starter Pack     |
+-------------------------------------------------------------------------+
| Layer 3: Daily Routine Recall, My Day Timeline & Reminders              |
+-------------------------------------------------------------------------+
| Layer 4: Context-Aware BANDHU Help (Phase 1 Screen + Phase 3 Live Game)  |
+-------------------------------------------------------------------------+
| Layer 5: Caregiver Transparency Dashboard (Web + Deterministic Trends)   |
+-------------------------------------------------------------------------+
| Layer 6: Offline-First Drift SQLite & Operation-Level Idempotent Sync   |
+-------------------------------------------------------------------------+
| Layer 7: Universal Multilingual Framework (9 Regional NER Languages)     |
+-------------------------------------------------------------------------+
```

Each layer functions completely on-device without cloud dependency, while maintaining seamless capability to synchronize with the caregiver portal when connected.

---

<a id="target-users"></a>
## 👥 Target Users

1. **Elderly Individuals (Primary Users)**:
   - Seniors experiencing early-stage memory changes, mild cognitive disorientation, or normal age-related recall delays.
   - Older adults desiring daily mental stimulation, structured routines, and peaceful connection to family memories.
2. **Family Caregivers & Attendants (Secondary Users)**:
   - Adult children, spouses, and home attendants managing day-to-day care, medication schedules, and cognitive activity oversight.
3. **Community Healthcare Workers (ASHA / ANM / NGOs)**:
   - Grassroots healthcare facilitators monitoring elderly welfare in rural communities, requiring offline-operable verification tools.

---

<a id="key-features"></a>
## ✨ Key Features

### ✅ Implemented & Physically Verified
- **Elderly-First Flutter Patient Application**: High-contrast theme, minimum 56–64dp touch targets, 18sp+ typography, zero pinch-to-zoom requirements, calm restorative palette (Slate Navy `#1E293B`, Warm Cream `#FDFBF7`, Restorative Sage `#3B7A57`).
- **Responsive Layout Engine**: Dynamic breakpoint adaptation for mobile phones (`<600px`), tablets (`600–1023px`), and desktop monitors (`≥1024px`).
- **Interactive Memory Match Game**: Tactile card matching with 3D matrix flip animations, Easy (3 pairs), Medium (4 pairs), and Hard (6 pairs) tiers using culturally familiar North Eastern iconography.
- **Interactive Pattern Recognition Game**: Visual sequence rhythm completion with distractor elimination hints, turn locking to prevent accidental taps, and calm encouragement.
- **Interactive Daily Routine Recall Game**: Chronological event ordering (Morning Tea, Breakfast, Walk, Lunch, Rest, Evening Chat, Sleep) with tap-to-add / tap-to-remove sequence slots.
- **Deterministic Adaptive Difficulty (Tier 0)**: 100% explainable, rule-based client difficulty scaling based on validated attempt accuracy, mistake counts, and response latency.
- **Context-Aware BANDHU Help (Phase 1 & Phase 3)**:
  - Phase 1: Screen-aware routing context and deterministic guidance for every primary view.
  - Phase 3: Real-time game-aware inspection of live board state, placed slots, remaining pairs, and active sequence distractors.
  - Stuck Detection Policy: Natural prompt triggered after 20 seconds of inactivity or 2 consecutive errors, with 45-second cooldown and 10-second initial grace period.
- **Personal Memory Bank**: Categorized reminiscence cards (Family, Friends, Places, Traditions, Milestones) with local photo caching and audio voice note playback.
- **My Day & Mood Check-In**: Non-clinical self-reported emotional reflection and daily activity checklist.
- **Local Persistence via Drift / SQLite**: Type-safe local tables for sessions, memories, routines, reminders, and pending sync operations.
- **Caregiver Pairing Protocol**: 4-digit numeric code generation (1000–9999), cryptographically signed tokens, 10-minute expiry windows, and QR pairing payload (`smriti://pair?token=...`).
- **Caregiver Web Dashboard**: React 18 + TypeScript web app featuring high-level KPI cards, Recharts participation timeline, game performance tables, reminder adherence tracking, and multi-patient switching.
- **Multi-Patient Local Account Boundary**: Secure data isolation in SQLite tagged with active patient IDs, ensuring full privacy on shared household devices.
- **9-Language Multilingual Architecture**: Fully translation-verified in English (`en`), Hindi (`hi`), and Assamese (`as`); architecturally enabled for Bengali (`bn`), Meitei (`mni`), Bodo (`brx`), Mizo (`lus`), Khasi (`kha`), and Garo (`grt`).
- **Dynamic LAN Phone Demo Utility**: Automated host IPv4 detection, high-contrast QR generation (`scripts/demo/generate_qr.py`), and one-click PowerShell demo launcher (`scripts/demo/start_phone_demo.ps1`).

### 🧪 Foundation / Demo-Level Scope
- **My Life Story Timeline**: Chronological milestone foundation; graceful empty state encouraging real family input without synthetic hallucination.
- **Verified NER Cultural Starter Pack**: 14 open-license starter assets across all 8 NER states documented with full provenance in `data/DATASET_MANIFEST.md`.
- **Talk to Me Voice Interaction**: Deterministic local intent parsing (`IntentService`) and `MemoryRescueService` structured retrieval with safety guardrails.
- **FastAPI Backend Synchronization**: Asynchronous REST sync endpoints (`/api/v1/sync`) supporting operation-level idempotency (`operation_id`) and automated SQLite/PostgreSQL fallback.

### 🚀 Planned Post-Selection Capabilities
- Managed production PostgreSQL database clustering with automated cloud backups.
- Expanded native voice audio models calibrated for indigenous NER dialects.
- Rights-cleared regional folk music catalog for therapeutic reminiscence.
- Institutional healthcare provider multi-tenant portal with exportable audit logs.

---

<a id="system-architecture"></a>
## 🏗️ System Architecture

```
+-----------------------------------------------------------------------------------+
|                            BANDHU PATIENT APPLICATION                             |
|                                 (Flutter / Dart)                                  |
|                                                                                   |
|  +--------------------+  +----------------------+  +---------------------------+  |
|  |  Cognitive Games   |  |   Daily Routines     |  |    Personal Memory Bank   |  |
|  |  - Memory Match    |  |   - Routine Recall   |  |    - Photo & Audio Notes  |  |
|  |  - Pattern Recog   |  |   - Daily Reminders  |  |    - NER Cultural Pack    |  |
|  +---------+----------+  +----------+-----------+  +-------------+-------------+  |
|            |                        |                            |                |
|            +------------------------+----------------------------+                |
|                                     |                                             |
|                                     v                                             |
|                      +-----------------------------+                              |
|                      |  Drift / SQLite Persistence |                              |
|                      +--------------+--------------+                              |
|                                     |                                             |
|                 +-------------------+-------------------+                         |
|                 |                                       |                         |
|                 v                                       v                         |
|     +-----------------------+               +-----------------------+             |
|     |  Deterministic AI     |               |   Sync Queue Manager  |             |
|     |  - Adaptive Engine    |               |   - Idempotency UUIDs |             |
|     |  - Context-Aware Help |               |   - Offline Retention |             |
|     +-----------------------+               +-----------+-----------+             |
+---------------------------------------------------------|-------------------------+
                                                          |
                                           Opportunistic Network Sync
                                                          |
                                                          v
                                       +-------------------------------------+
                                       |         FastAPI REST Backend        |
                                       |         (Python 3.11–3.13)          |
                                       +------------------+------------------+
                                                          |
                                         +----------------+----------------+
                                         |                                 |
                                         v                                 v
                              +--------------------+             +--------------------+
                              | SQLite / Postgres  |             | Caregiver Web App  |
                              | Server Database    |             | (React 18 + TS)    |
                              +--------------------+             +--------------------+
```

### Component Breakdown
1. **Patient Client (`apps/patient_app`)**: Flutter cross-platform client managing user interaction, reactive audio-visual rendering, local SQLite database management, and on-device difficulty calculations.
2. **Local Persistence Engine**: Built on `drift` and `sqlite3_flutter_libs` to deliver atomic ACID transactions on physical mobile devices and web browsers.
3. **Adaptive Engine & Contextual Help**: Pure Dart implementation operating on local game state to ensure instant zero-latency feedback without external cloud network roundtrips.
4. **Synchronization Service**: Queues mutations locally with unique `operation_id` UUIDs. When internet connectivity is detected, it pushes batch operations to the REST backend idempotently.
5. **Backend REST API (`backend/api`)**: FastAPI application exposing JWT authentication, patient-caregiver association protocols, and idempotent data ingestion.
6. **Caregiver Portal (`apps/caregiver_dashboard`)**: Responsive Vite + React 18 dashboard rendering real synchronized patient metrics, adherence charts, and memory management tools.

---

<a id="how-bandhu-works"></a>
## 🔄 How BANDHU Works

1. **Patient Opens App**: The patient logs in or taps **"Continue Offline"**. The app immediately loads their profile, streak, and daily routine from local SQLite.
2. **Cognitive Gameplay**: The senior selects an exercise (e.g., Memory Match).
   - If the player hesitates or makes consecutive errors, the **BANDHU Help** prompt gently appears with actual-state hints.
   - Upon completion, the **Adaptive Engine** evaluates completion metrics and transparently adjusts difficulty for the next session.
3. **Immediate Local Logging**: All results, duration, hints used, and response latency are committed immediately to local SQLite.
4. **Opportunistic Background Sync**: The `SyncManager` detects network connectivity and uploads queued records to the FastAPI server. If offline, records wait safely indefinitely without data loss.
5. **Caregiver Review**: The caregiver logs into the React dashboard and reviews synchronized participation, observed adherence trends, and recently added family photographs.

---

<a id="patient-application"></a>
## 📱 Patient Application

The BANDHU Patient Application is architected from the ground up for older adults:

### Elderly-First Design Principles
- **Touch Ergonomics**: All interactive cards and buttons adhere to a minimum size of **56×56dp** (recommended **64×64dp**), separated by generous padding to eliminate accidental double-taps.
- **High-Contrast Readability**: Typography uses bold, easily legible typefaces with body text starting at **18sp** and headers at **24sp–32sp**.
- **Calm Visual Palette**: High-contrast, non-glare color tokens:
  - Deep Slate Navy: `#1E293B`
  - Restorative Sage: `#3B7A57`
  - Warm Cream Background: `#FDFBF7`
  - Dark Charcoal Copy: `#0F172A`
- **Predictable Navigation**: Persistent bottom navigation on phones; no hidden hamburger menus, swipe-to-dismiss traps, or complex multi-touch gestures.

### Responsive Breakpoint Specifications
Implemented in `SmritiResponsive` (`lib/core/responsive/smriti_responsive.dart`):
- **Phone (`< 600 px`)**: Single-column vertical layout, sticky bottom navigation bar, single-card focus.
- **Tablet (`600 – 1023 px`)**: Two-column adaptive grid, side `NavigationRail`, expanded touch areas.
- **Desktop / Large Displays (`≥ 1024 px`)**: Fixed max-content width (`1200 px`), persistent left sidebar navigation, dual-pane memory and routine views.

---

<a id="caregiver-dashboard"></a>
## 👨‍⚕️ Caregiver Dashboard

The Caregiver Dashboard (`apps/caregiver_dashboard`) provides family members and caregivers transparency into daily care without clinical overinterpretation:

- **Secure Caregiver Authentication**: Token-based authentication with session recovery.
- **Multi-Patient Switching**: Seamlessly manage and review multiple connected family members.
- **Activity & Participation Overview**: Recharts-powered 7-day, 14-day, and 30-day timelines tracking completed cognitive activities.
- **Cognitive Exercise Records**: Granular session history displaying game type, duration, hints requested, and accuracy rates.
- **Routine & Reminder Adherence**: Confirmed daily routines, scheduled medication reminders, and hydration events.
- **Family Memory Bank Manager**: Add family photos, update relationship titles, tag favorite reminiscence cards, and browse cultural starter packs.
- **Sync Status Monitor**: Real-time status dot (`● Synced` / `Pending`) reflecting backend communication status.

---

<a id="cognitive-games"></a>
## 🎮 Cognitive Games

BANDHU includes three distinct, fully playable cognitive exercises designed to stimulate recall, executive sequencing, and pattern processing:

### 1. Memory Match (`lib/features/games/memory_match`)
- **Objective**: Uncover card pairs by recalling spatial positions of culturally familiar symbols.
- **Tiers**:
  - *Easy*: 3 pairs (6 cards, 3×2 grid, 1.5s initial card preview).
  - *Medium*: 4 pairs (8 cards, 4×2 grid, 1.0s initial card preview).
  - *Hard*: 6 pairs (12 cards, 4×3 grid, 0.5s initial card preview).
- **Cultural Metaphors**: Assam Tea Cup (`local_cafe`), Garden Orchids (`local_florist`), Traditional Home (`home`), Morning Sun (`wb_sunny`), Harvest Fruit (`apple`), Festival Dhol (`music_note`), Bamboo Grove (`eco`), River Boat (`sailing`).
- **Live Game-Aware Help**: Inspects currently flipped cards, matched pairs, and unrevealed matching coordinates to highlight an exact matching pair.

### 2. Pattern Recognition (`lib/features/games/pattern_recognition`)
- **Objective**: Identify the next logical symbol in an alternating, cyclical, or triplet visual sequence.
- **Tiers**:
  - *Easy*: 4 sequence questions, 3–4 items in sequence, 2 answer choices (1 distractor).
  - *Medium*: 5 sequence questions, 4–5 items in sequence, 3 answer choices (2 distractors).
  - *Hard*: 6 sequence questions, 5–7 items in sequence, 4 answer choices (3 distractors).
- **Live Game-Aware Help**: Analyzes active sequence pattern rule and eliminates an incorrect distractor button while highlighting the sequence rhythm.

### 3. Daily Routine Recall (`lib/features/games/daily_routine_recall`)
- **Objective**: Reconstruct the natural chronological sequence of everyday daily events.
- **Tiers**:
  - *Easy*: 3 routine steps per round (e.g., Wake Up → Wash & Freshen Up → Morning Tea).
  - *Medium*: 4 routine steps per round.
  - *Hard*: 5 routine steps per round with distractor routines.
- **Live Game-Aware Help**: Identifies unfilled routine slots and gently highlights the correct next card in the candidate tray.

---

<a id="adaptive-difficulty"></a>
## 🤖 Adaptive Difficulty

BANDHU implements a **100% deterministic, explainable Tier-0 adaptive difficulty engine** (`ClientAdaptiveEngine` in Dart and `ai/adaptive_engine` in Python).

### Evaluation Rules
Following each exercise session, the engine evaluates completion parameters:
- **Level Up (`Difficulty + 1`)**:
  - Validated Accuracy $\ge 85\%$
  - Mistakes $\le 1$
  - Response time within comfortable pacing window
- **Maintain Current Level (`Difficulty Unchanged`)**:
  - Accuracy between $60\%$ and $84\%$
  - Stable, comfortable engagement
- **Support Trigger / Level Down (`Difficulty - 1`)**:
  - Accuracy $< 60\%$ or Mistakes $\ge 3$
  - Extended hesitation or high hint reliance
  - *Support actions*: Automatically increases preview display time, decreases active card pairs, or adds gentle visual cues.

> [!NOTE]
> Difficulty adaptation is an **interaction and pacing policy only**. It is never converted into a medical score, dementia risk index, or clinical decline metric.

---

<a id="context-aware-bandhu-help"></a>
## 🆘 Context-Aware BANDHU Help

BANDHU features an on-device contextual assistant that operates completely offline without external AI API latency.

### Phase 1: Screen-Aware Context
- Tracks the active application route via `HelpContextService`.
- Provides screen-specific navigation guidance and reassurance for Home, Memory, Games, My Day, Reminders, and Settings.

### Phase 3: Live Game-Aware Assistance
- **State Capture**: Inspects active game type, current difficulty, turn phase, board state, placed slots, mistakes count, and elapsed time.
- **Conservative Stuck Detection**:
  - **Idle Threshold**: 20 seconds without touch interaction.
  - **Error Trigger**: 2 consecutive mismatched attempts.
  - **Grace Period**: 10 seconds at the beginning of each round.
  - **Cooldown Period**: 45 seconds after a prompt is dismissed before re-triggering.
- **Gentle UX**: Displays a non-intrusive floating card:
  *"Need a little help?"* with explicit choices **[ Help me ]** or **[ Not now ]**.
- **Critical Safety Guardrail**: Hints must be calculated deterministically from the **actual current game state**. The system never hallucinates cards, patterns, or answers that do not exist on screen.

---

<a id="personal-memory-daily-assistance"></a>
## 🧠 Personal Memory & Daily Assistance

### 1. Personal Memory Bank
- Categorized reminiscence cards: Family, Friends, Places, Childhood, Food & Drink, Festivals, Traditions, Milestones, Music, Daily Life.
- Photos and audio recordings are stored strictly in local application storage (`smriti_memories_media/`).
- Zero automated cloud uploads or third-party computer vision indexing.

### 2. My Life Story Timeline
- Chronological timeline capturing personal milestones (birthplace, school, wedding, career, grandchildren).
- Graceful empty state encouraging authentic caregiver input with zero synthetic filler data.

### 3. Verified NER Cultural Starter Pack
- 14 verified open-license assets representing traditions, landmarks, and daily life across Assam, Meghalaya, Manipur, Nagaland, Mizoram, Tripura, Arunachal Pradesh, and Sikkim.
- Complete provenance and open licenses documented in `data/DATASET_MANIFEST.md`.

### 4. My Day & Mood Check-In
- Step-by-step daily routine card (Morning Tea, Walk, Meals, Evening Family Chat).
- Non-clinical self-reported feeling selector (Great, Peaceful, Calm, Tired, Low) stored locally for caregiver review.

### 5. Talk to Me (Voice Assistance Foundation)
- Hands-free conversational interface for seniors with tremor or motor challenges.
- Deterministic intent mapping (`familyQuery`, `reminderQuery`, `routineQuery`).
- Clinical queries immediately trigger compassion guardrails directing the elder to their caregiver or doctor.

---

<a id="languages-ner-cultural-support"></a>
## 🌐 Languages & NER Cultural Support

BANDHU provides a centralized localization architecture (`lib/l10n/app_strings.dart`) designed for the unique linguistic landscape of the North Eastern Region:

| Language | ISO Code | Script | Implementation Status |
| :--- | :--- | :--- | :--- |
| **English** | `en` | Latin | ✅ Fully Translation-Verified |
| **Hindi** | `hi` | Devanagari | ✅ Fully Translation-Verified |
| **Assamese** | `as` | Eastern Nagari | ✅ Fully Translation-Verified |
| **Bengali** | `bn` | Eastern Nagari | 🧪 Architecturally Supported (Key fallback ready) |
| **Meitei / Manipuri** | `mni` | Meitei Mayek / Bengali | 🧪 Architecturally Supported (Key fallback ready) |
| **Bodo** | `brx` | Devanagari | 🧪 Architecturally Supported (Key fallback ready) |
| **Mizo** | `lus` | Latin | 🧪 Architecturally Supported (Key fallback ready) |
| **Khasi** | `kha` | Latin | 🧪 Architecturally Supported (Key fallback ready) |
| **Garo** | `grt` | Latin | 🧪 Architecturally Supported (Key fallback ready) |

### Cultural Integrity & Fallback Policy
- **Deterministic English Fallback**: Any unreviewed or missing translation key safely falls back to English (`en`), guaranteeing zero UI crashes or blank labels.
- **Personal Content Preservation**: User-created names, personal memories, voice transcripts, and family notes are **never machine-translated**.
- **No Monolithic Generalization**: The platform explicitly respects that the North East comprises hundreds of distinct communities; cultural packs are segmented by state and community.

---

<a id="privacy-safety-clinical-boundary"></a>
## 🔒 Privacy, Safety & Clinical Boundary

### Strict Clinical Boundary
BANDHU is intentionally engineered as an assistive, supportive companion. It is strictly non-clinical.

| Prohibited Terminology / Claims | Approved BANDHU Terminology |
| :--- | :--- |
| ❌ "Dementia detected / diagnosed" | ✅ "Activity completed" |
| ❌ "Cognitive decline probability: 74%" | ✅ "Comfortable pacing observed" |
| ❌ "Stage 2 Alzheimer's Assessment" | ✅ "Recent engagement trend" |
| ❌ "Cure / Clinical therapy" | ✅ "Cognitive stimulation exercise" |
| ❌ "Automated medical decision" | ✅ "Caregiver review recommended" |

### On-Device Privacy
- Local SQLite database stored in sandbox application directories.
- Zero tracking of biometric facial features, unconsented ambient audio, or background location.
- Pairings use time-limited cryptographic tokens with manual patient approval.

---

<a id="ai-ml-strategy"></a>
## 🤖 AI / ML Strategy

BANDHU follows an ethical, layered AI strategy that separates deterministic gameplay from empirical research:

```
+-------------------------------------------------------------------------+
| Tier 0: Product Runtime Adaptation (100% Deterministic Dart & Python)   |
|         Rule-based difficulty scaling, stuck detection, local hints     |
+-------------------------------------------------------------------------+
| Tier 1: Offline Research Calibration (Empirical Neuro Datasets)         |
|         Benchmark reaction times and cognitive pacing calibration       |
+-------------------------------------------------------------------------+
| Tier 2: Future Consented Telemetry (Optional, Non-Clinical Expansion)   |
|         Longitudinal engagement trends with explicit caregiver consent  |
+-------------------------------------------------------------------------+
```

### Research Calibration Benchmarks (Tier 1)
- Evaluated against open-access cognitive pacing benchmarks:
  - **OpenNeuro Stroop (`ds000164`)**: 28 healthy subjects.
  - **OpenNeuro NYU Slow Flanker (`ds000102`)**: 26 healthy subjects.
  - Cumulative research baseline: 85 raw files, 54 subjects, 4,585 empirical trials.
  - Task-A random-forest benchmark: $\text{MAE} \approx 126.45\text{ ms}$, $\text{RMSE} \approx 170.85\text{ ms}$, $R^2 \approx 0.2268$.
- *Purpose*: Used solely to establish comfortable button-press pacing windows for elderly users; never used as a diagnostic classifier.

---

<a id="dataset-research-strategy"></a>
## 📊 Dataset & Research Strategy

BANDHU enforces a strict **Ethical Data Governance Policy** documented in `data/DATASET_MANIFEST.md`:

1. **No-Synthetic-Data Rule**: No artificially generated synthetic gameplay data is ever represented as real-world clinical evidence.
2. **Documented Open Provenance**:
   - `OpenNeuro Stroop (ds000164)`: Open-access research calibration.
   - `OpenNeuro NYU Slow Flanker (ds000102)`: Open-access pacing calibration.
   - `Common Voice (Assamese / Hindi)`: Creative Commons voice evaluation.
   - `AI4Bharat IndicConformer / IndicVoices`: Regional language references.
   - `DementiaBank (Pitt Corpus)`: Controlled research-only reference; excluded from runtime distribution.
3. **Cultural Assets**: All icons and photos in cultural starter packs utilize public-domain or permissive Creative Commons licenses with documented source archives.

---

<a id="offline-first-architecture"></a>
## 📴 Offline-First Architecture

Because rural and hilly areas of the North Eastern Region face intermittent cellular connectivity, BANDHU treats network connectivity as an **optional enhancement**, not a prerequisite.

### Architectural Flow
```text
Patient-side local persistence (Drift / SQLite)
       ↓
Local game / activity state (Memory Match, Pattern, Routine)
       ↓
Sync queue (Operation-level idempotency with UUIDs)
       ↓
Backend synchronization when available (FastAPI REST)
       ↓
Caregiver dashboard (React + Recharts)
```

### How Offline-First Operates
1. **Local Drift SQLite Database**: All game scores, memories, reminder events, and preferences write immediately to device storage (`smriti.sqlite` on Android / SQLite Wasm on Web).
2. **Operation-Level Idempotency (`SyncQueue`)**:
   - Each local operation generates a unique UUID `operation_id` distinct from entity IDs.
   - Mutated records enter `SyncQueue` with status `pending`.
   - Even if the network drops mid-transmission, retries reuse the same `operation_id`, preventing duplicate records on the server.
3. **Resilient Token Handling**: 401 Unauthorized or expired tokens never purge local records. Data remains intact until re-authentication.
4. **Local Prototype Storage**: The current working prototype is designed around on-device SQLite persistence and does not require PostgreSQL to execute the demo. Production database clustering (managed PostgreSQL) is planned for future post-selection hardening.

---

<a id="caregiver-pairing"></a>
## 🔗 Caregiver Pairing

Caregiver linking connects a patient app to the caregiver dashboard securely:

1. **Pairing Request Generation**: The caregiver clicks **"Add Patient"** on their dashboard.
2. **Cryptographic Token & 4-Digit Code**: The backend creates a 10-minute pairing request with a random 4-digit code (e.g., `4829`) and a secure URL-safe token.
3. **QR Code Generation**: The dashboard renders a QR code encoding the internal compatibility URI:
   ```text
   smriti://pair?token=32_BYTE_CRYPTO_TOKEN&code=4829
   ```
4. **Patient Confirmation**: The patient scans the QR code or types the 4-digit code on their mobile device and taps **[ Confirm Connection ]**.
5. **Patient-Scoped Access**: The caregiver is linked to the patient ID, enforcing strict RBAC boundary checks on all subsequent analytics queries.

---

<a id="repository-structure"></a>
## 📁 Repository Structure

```text
BANDHU-SIH26003/
├── apps/
│   ├── patient_app/                 # Flutter (Dart 3) elderly-first mobile & web app
│   │   ├── android/                 # Native Android Gradle configuration
│   │   ├── assets/                  # High-contrast audio and cultural assets
│   │   ├── lib/
│   │   │   ├── core/                # Design system, theme, voice, auth, responsive
│   │   │   ├── data/                # Drift SQLite database, repositories, sync client
│   │   │   ├── features/            # Games, memory, routines, help, profile, onboarding
│   │   │   └── l10n/                # Centralized 9-language localization engine
│   │   ├── test/                    # 311 unit and widget tests
│   │   └── pubspec.yaml             # Flutter package manifest
│   │
│   └── caregiver_dashboard/         # React 18 + TypeScript web dashboard
│       ├── src/
│       │   ├── api/                 # REST client for FastAPI synchronization
│       │   ├── components/          # Metric cards, recent sessions, memory manager
│       │   ├── context/             # Auth and localization state providers
│       │   └── layout/              # Sidebar, topbar, and page shells
│       ├── package.json             # NPM package manifest
│       └── vite.config.ts           # Vite build configuration
│
├── backend/
│   └── api/                         # FastAPI (Python 3.11–3.13) REST backend
│       ├── alembic/                 # Database migration scripts
│       ├── app/
│       │   ├── auth/                # JWT role-based access control
│       │   ├── core/                # Configuration and environment settings
│       │   ├── db/                  # SQLAlchemy sessions, engine, and seed data
│       │   ├── models/              # Relational models (Patients, Caregivers, Games)
│       │   ├── schemas/             # Pydantic v2 schemas and validation models
│       │   ├── services/            # Analytics, pairing, and synchronization logic
│       │   └── main.py              # FastAPI application entrypoint
│       ├── tests/                   # Pytest API and auth verification suite
│       └── requirements.txt         # Python dependencies
│
├── ai/
│   ├── adaptive_engine/             # Deterministic rule-based difficulty adjustment
│   ├── analytics/                   # Non-clinical trend calculations
│   ├── models/                      # Shared data models
│   └── tests/                       # Pytest suite for adaptive engine
│
├── data/
│   ├── raw/                         # Raw reference data
│   ├── processed/                   # Cultural assets and audio references
│   ├── demo/                        # Seed accounts and demo assets
│   └── DATASET_MANIFEST.md          # Ethical data provenance & NER schemas
│
├── shared/
│   ├── schemas/                     # Cross-boundary JSON schemas
│   └── constants/                   # System constants
│
├── docs/
│   ├── architecture/                # ARCHITECTURE.md system specification
│   ├── decisions/                   # ADR-001-foundation.md architecture decisions
│   ├── demo/                        # Memory Match, Pattern, and Phone demo guides
│   ├── pdf_preview/                 # High-resolution preview pages of summary PDF
│   ├── BACKEND_SYNC.md              # Database synchronization technical specification
│   ├── LOCALIZATION.md              # Multilingual system implementation guide
│   ├── PHASE_08_ANALYTICS.md        # Caregiver intelligence & analytics specification
│   ├── VOICE_ARCHITECTURE.md        # Hands-free voice architecture specification
│   └── BANDHU_Work_Summary_Report.html # Executive summary HTML report
│
├── scripts/
│   ├── demo/
│   │   ├── generate_qr.py           # LAN IP detection and high-contrast QR generator
│   │   ├── start_phone_demo.ps1     # One-click PowerShell demo launcher
│   │   └── README.md                # Phone demo instructions
│   ├── development/
│   │   └── run_all_tests.ps1        # Automated cross-component test runner
│   ├── setup/                       # Environment initialization helpers
│   └── generate_summary_pdf.py      # Automated vector PDF report compiler
│
├── tests/                           # Cross-boundary integration verification suites
├── .env.example                     # Environment variable template
├── .gitignore                       # Git repository ignore rules
├── BANDHU_PND.pdf                   # Complete Project Navigation & Development Document
├── BANDHU_MASTER_SPEC.md            # Comprehensive master technical specification
├── BANDHU_Work_Summary_Report.pdf   # Publication-grade executive summary PDF report
├── walkthrough.md                   # End-to-end physical device verification log
└── README.md                        # Master repository documentation
```

---

<a id="technology-stack"></a>
## 💻 Technology Stack

| Layer | Technology | Verified Environment Version | Rationale |
| :--- | :--- | :--- | :--- |
| **Mobile & Patient Web** | Flutter / Dart | 3.47.2 / 3.13.2 | Cross-platform (Android, Web), 60fps animations, rich accessibility controls. |
| **Local Persistence** | Drift (SQLite) | 2.35.0 | Type-safe, reactive local SQL database with Wasm support for web preview. |
| **Backend REST API** | FastAPI / Python | 0.110+ / 3.13.15 | High-performance asynchronous REST endpoints with auto OpenAPI docs. |
| **Server Persistence** | SQLite / PostgreSQL | SQLAlchemy 2.0 | Lightweight local SQLite (`smriti.db`) for demo; PostgreSQL-ready with Alembic. |
| **Caregiver Web App** | React / TypeScript | 18.3.1 / 5.4.5 | Modular, reactive dashboard foundation built with Vite 5. |
| **Analytics Charts** | Recharts | 3.10.1 | Declarative, accessible SVG charts for caregiver adherence and activity metrics. |
| **Adaptive Difficulty** | Python / Dart | Custom | 100% deterministic, explainable rule engine; zero opaque black-box AI. |
| **Demo Infrastructure** | PowerShell / Python | Custom | Zero-dependency dynamic LAN IP detection and high-contrast terminal QR generator. |

---

<a id="prerequisites"></a>
## ⚙️ Prerequisites

### Verified Development Environment
The codebase has been verified and tested under the following environment:
- **Flutter SDK**: `3.47.2`
- **Dart SDK**: `3.13.2` (included with Flutter)
- **Python**: `3.13.15`
- **pip**: `26.2.1`
- **Node.js**: `24.18.0`
- **npm**: `11.16.0`
- **Java Runtime**: `26.0.1` (OpenJDK / Android Studio JRE)
- **Android SDK / Platform-Tools**: `36.0.0` (with `adb`)
- **Web Browser**: Google Chrome or Microsoft Edge (required for web preview and PDF generation)
- **Git**: `2.30+`

### Tool Responsibilities
1. **Git**: Cloning the repository and managing branch checkpoints.
2. **Flutter & Dart SDK**: Compiling and testing the Patient Application (`apps/patient_app`) for Android and Web.
3. **Python & pip**: Running the FastAPI REST backend (`backend/api`), AI difficulty engine (`ai/`), and QR tooling (`scripts/demo/`).
4. **Node.js & npm**: Compiling and running the Caregiver Web Dashboard (`apps/caregiver_dashboard`).
5. **Java & Android SDK (`adb`)**: Deploying, reverse-tethering (`adb reverse tcp:8000 tcp:8000`), and debugging on physical Android devices.
6. **Web Browser (Chrome / Edge)**: Previewing web builds and compiling vector PDF executive reports.

---

<a id="installation"></a>
## 📥 Installation

Clone the repository and inspect the workspace:

```powershell
git clone https://github.com/DHARMIKGOSWAMI1234/SIH.git BANDHU
cd BANDHU
```

---

<a id="quick-start"></a>
## 🚀 Quick Start (3 Terminals)

To quickly run the entire BANDHU ecosystem locally on your development PC:

### Terminal 1: FastAPI Backend
```powershell
cd backend/api
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
*Verify*: Open `http://127.0.0.1:8000/health` in your browser. Expected: `{"status":"ok"}`.

### Terminal 2: Caregiver Dashboard
```powershell
cd apps/caregiver_dashboard
npm install
npm run dev
```
*Verify*: Open `http://localhost:5173` to access the Caregiver Portal.

### Terminal 3: Patient Application (Chrome Web Preview)
```powershell
cd apps/patient_app
flutter pub get
flutter run -d chrome
```

---

<a id="detailed-setup"></a>
## 🧑‍💻 Detailed Setup

### 1. Environment Configuration
Copy the template configuration to create your local `.env`:
```powershell
Copy-Item .env.example .env
Copy-Item .env.example backend/api/.env
```
Default demo settings in `.env` are pre-configured to use local SQLite (`sqlite:///./smriti.db`) out-of-the-box without requiring a running PostgreSQL server.

### 2. Patient App Dependencies
```powershell
cd apps/patient_app
flutter pub get
```

### 3. Backend API Virtual Environment
```powershell
cd backend/api
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### 4. Caregiver Dashboard Packages
```powershell
cd apps/caregiver_dashboard
npm install
```

---

<a id="running-on-android"></a>
## 📱 Running on Android

To run BANDHU on a physical Android smartphone or emulator:

1. **Enable Developer Options & USB Debugging** on your Android phone.
2. Connect your phone via USB cable and verify device detection:
   ```powershell
   adb devices
   flutter devices
   ```
3. **Enable Reverse Port Forwarding** (allows the phone to communicate with your PC's local FastAPI backend):
   ```powershell
   adb reverse tcp:8000 tcp:8000
   ```
4. **Launch Patient Application**:
   ```powershell
   cd apps/patient_app
   flutter run
   ```
   Select your connected Android phone from the device picker prompt.
5. **Alternative — Build Debug APK**:
   ```powershell
   cd apps/patient_app
   flutter build apk --debug
   ```
   The compiled APK will be located at:
   `apps/patient_app/build/app/outputs/flutter-apk/app-debug.apk`

---

<a id="running-the-caregiver-dashboard"></a>
## 💻 Running the Caregiver Dashboard

The Caregiver Dashboard is a Vite-powered single-page application:

```powershell
cd apps/caregiver_dashboard
npm run dev
```

- Local URL: `http://localhost:5173`
- Default Seed Caregiver Login:
  - **Email**: `caregiver@smriti.care`
  - **Password**: `Caregiver123!`

---

<a id="running-the-backend"></a>
## ⚡ Running the Backend

The backend is built with FastAPI:

```powershell
cd backend/api
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --port 8000
```

- **Interactive API Documentation (Swagger UI)**: `http://127.0.0.1:8000/docs`
- **Alternative Redoc Documentation**: `http://127.0.0.1:8000/redoc`
- **Health Check Endpoint**: `http://127.0.0.1:8000/health`

---

<a id="running-the-complete-demo"></a>
## 🔄 Running the Complete Demo (Dynamic LAN Phone Demo)

For live hackathon evaluations, presentations, or testing on physical phones over Wi-Fi **without installing an APK**:

1. Connect your PC and smartphone to the **same local Wi-Fi router** or phone mobile hotspot.
2. From the repository root, execute the one-click PowerShell launcher:
   ```powershell
   .\scripts\demo\start_phone_demo.ps1
   ```
3. **What happens automatically**:
   - Detects your PC's active LAN IPv4 address (e.g., `192.168.1.15`).
   - Generates a high-contrast QR code image (`smriti_phone_demo_qr.png`) and ASCII QR code in your terminal.
   - Binds the Flutter web server to `0.0.0.0:8080`.
4. Open the default camera app on your phone and scan the QR code.
5. BANDHU launches immediately in your phone's browser at 60fps.

---

<a id="testing-offline-mode"></a>
## 📴 Testing Offline Mode

To verify that BANDHU functions seamlessly without internet:

1. **Launch BANDHU** on your phone or web browser.
2. Select **"Continue Offline"** on the login screen.
3. **Disable Connectivity**:
   - On a physical phone: Turn on **Airplane Mode** (disable Wi-Fi and Cellular).
   - In Google Chrome: Press `F12` → Network tab → select **Offline** from the throttling dropdown.
4. **Interact**:
   - Play a round of **Memory Match** or **Pattern Recognition**.
   - Trigger the **BANDHU Help** button to verify instant local guidance.
   - Complete the game and open the **Progress** tab. Observe that the session is persisted locally in SQLite.
5. **Reconnect**:
   - Re-enable Wi-Fi.
   - Navigate to Settings & Accessibility → tap **[ Verify Local Sync ]**.
   - All pending operations in `SyncQueue` upload cleanly to the backend database.

---

<a id="testing-verification"></a>
## 🧪 Testing & Verification

BANDHU includes comprehensive automated test suites across all layers.

### Run All Tests via Automated Script
```powershell
.\scripts\development\run_all_tests.ps1
```
This script executes:
1. AI Adaptive Engine Pytest suite
2. Backend API health and auth test suite
3. Flutter patient app static analysis (`flutter analyze`)
4. Flutter widget & unit test suite (`flutter test`)
5. Dynamic LAN IP and QR generator test

### Individual Test Suites

#### 1. Patient App Flutter Tests (311 Tests)
```powershell
cd apps/patient_app
flutter analyze
flutter test
```

#### 2. Backend API Tests (27 Tests)
```powershell
cd backend/api
.\.venv\Scripts\Activate.ps1
pytest tests/
```

#### 3. AI Adaptive Engine Tests
```powershell
pytest ai/tests/
```

#### 4. Caregiver Dashboard TypeScript Build Check
```powershell
cd apps/caregiver_dashboard
npm run build
```

---

<a id="troubleshooting"></a>
## 🛠️ Troubleshooting

| Issue | Cause | Solution |
| :--- | :--- | :--- |
| `flutter: command not found` | Flutter SDK not added to system PATH | Add `<flutter-sdk-path>\bin` to your environment PATH variable and restart terminal. |
| `PowerShell script execution disabled` | Windows execution policy restriction | Run `Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass` in PowerShell. |
| `Phone cannot open LAN URL` | Wi-Fi Client Isolation or Firewall | Ensure PC and phone are on the same Wi-Fi network; permit port 8080 through Windows Defender Firewall. |
| `Port 8000 or 8080 already in use` | Another process is occupying the port | Pass custom port: `.\scripts\demo\start_phone_demo.ps1 -PreferredPort 9000` or specify `--port 8001` in Uvicorn. |
| `adb devices shows unauthorized` | Phone USB debugging prompt not accepted | Unlock your phone screen and tap "Always allow from this computer". |
| `sqlite3_flutter_libs missing on Linux` | Missing native SQLite development library | Run `sudo apt-get install libsqlite3-dev` on Linux environments. |

---

<a id="current-status"></a>
## 🗺️ Current Status

- **Status**: **Phase 01 through Phase 04 Fully Implemented & Physically Verified Prototype (Working SIH Demo)**.
- **Physical Verification**: Successfully verified on physical Android hardware (`CPH2717` / `FMXKV84T9D7LRSNR`) and Google Chrome / Microsoft Edge.
- **Regression Status**: 311 Flutter tests passing, 27 backend tests passing, 0 lint errors, clean TypeScript build.
- **Demo Baseline**: Working prototype baseline frozen for SIH evaluation.

---

<a id="if-selected-future-roadmap"></a>
## 🚀 If Selected — Future Roadmap

If BANDHU is selected for further development and deployment by the Ministry of Development of North Eastern Region (MDoNER), the engineering team plans the following phased roadmap:

### Phase A: Demo Stabilization & Baseline Hardening
- Complete user acceptance testing with representative elder-caregiver dyads.
- Package signed production release APKs for regional Android distributions.

### Phase B: Production Backend & Cloud Security
- Deploy managed PostgreSQL with encrypted volume storage and automated daily backups.
- Implement server-side JWT key rotation and OWASP-compliant API rate limiting.
- Establish appropriate data protection boundaries aligned with applicable Indian digital data privacy standards (DPDP).

### Phase C: Regional Accessibility & Language Expansion
- Complete secondary native-speaker linguistic reviews for Bengali, Meitei, Bodo, Mizo, Khasi, and Garo.
- Introduce customizable high-contrast sensory color profiles for color-vision deficiencies.
- Partner with North Eastern cultural organizations to curate state-specific oral history assets.

### Phase D: Consented Personalization Research
- Establish an ethically governed, IRB-approved clinical research telemetry protocol.
- Evaluate long-term cognitive engagement trends without converting telemetry into diagnostic labels.

### Phase E: Community Pilot & Scale
- Conduct field pilots with ASHA workers and community elder-care centers in Assam and Meghalaya.
- Refine low-bandwidth data synchronization over 2G/3G networks.

---

<a id="important-technical-notes"></a>
## ⚠️ Important Technical Notes

1. **Public Branding vs. Technical Identifiers**:
   - The public-facing product name is **BANDHU**.
   - In accordance with software engineering best practices, internal technical identifiers, package names (`org.sih26003.smriti.patient_app`), pairing URI schemes (`smriti://pair`), SQLite database names (`smriti.sqlite`, `smriti.db`), and Dart class names (`SmritiRepository`, `SmritiTheme`) are **deliberately preserved** to avoid breaking running builds, database schemas, and backward compatibility.
2. **Git Commit History**:
   - Historical Git commits created during earlier hackathon phases (such as `SMRITI: working SIH demo checkpoint`) are preserved untouched.
3. **No Synthetic Data Claim**:
   - BANDHU does not use synthetic benchmarks to make claims about dementia care efficacy.

---

<a id="documentation"></a>
## 📄 Documentation

Comprehensive technical documentation is maintained within the repository:

- **[📘 BANDHU_PND.pdf](./BANDHU_PND.pdf)**: Complete Project Navigation & Development Document (26-Page Specification & Roadmap).
- **[BANDHU_MASTER_SPEC.md](./BANDHU_MASTER_SPEC.md)**: Master Engineering Specification (v1.0.0).
- **[walkthrough.md](./walkthrough.md)**: Physical Device End-to-End Test Execution Log.
- **[docs/architecture/ARCHITECTURE.md](./docs/architecture/ARCHITECTURE.md)**: Deep-dive system architecture specification and component diagrams.
- **[docs/BACKEND_SYNC.md](./docs/BACKEND_SYNC.md)**: Offline sync queue and idempotency protocol.
- **[docs/LOCALIZATION.md](./docs/LOCALIZATION.md)**: Multilingual 9-language localization architecture.
- **[docs/PHASE_08_ANALYTICS.md](./docs/PHASE_08_ANALYTICS.md)**: Deterministic caregiver analytics and trend calculations.
- **[docs/VOICE_ARCHITECTURE.md](./docs/VOICE_ARCHITECTURE.md)**: "Talk to Me" voice pipeline and safety guardrails.
- **[docs/decisions/ADR-001-foundation.md](./docs/decisions/ADR-001-foundation.md)**: Architecture Decision Record for offline-first stack.
- **[docs/demo/MEMORY_MATCH_DEMO.md](./docs/demo/MEMORY_MATCH_DEMO.md)**: Memory Match gameplay demonstration guide.
- **[docs/demo/PATTERN_RECOGNITION_DEMO.md](./docs/demo/PATTERN_RECOGNITION_DEMO.md)**: Pattern Recognition gameplay demonstration guide.
- **[docs/demo/PHONE_DEMO.md](./docs/demo/PHONE_DEMO.md)**: Local phone preview testing guide.
- **[data/DATASET_MANIFEST.md](./data/DATASET_MANIFEST.md)**: Ethical data governance and NER cultural asset catalog.
- **[scripts/demo/README.md](./scripts/demo/README.md)**: Dynamic LAN IP detection and QR tooling guide.
- **[BANDHU_Work_Summary_Report.pdf](./BANDHU_Work_Summary_Report.pdf)**: Publication-grade vector executive summary report.
- **[docs/BANDHU_Work_Summary_Report.html](./docs/BANDHU_Work_Summary_Report.html)**: Executive summary report HTML source.

---

<a id="team"></a>
## 👥 Team

- **Team Name**: **THE DEBUGGERS**
- **Smart India Hackathon**: **SIH 2026**
- **Problem Statement**: `SIH26003`
- **Nodal Ministry**: **Ministry of Development of North Eastern Region (MDoNER)**

---

<a id="license-project-notes"></a>
## 📜 License / Project Notes

This software repository has been developed for the **Smart India Hackathon (SIH26003)** under the auspices of the **Ministry of Development of North Eastern Region (MDoNER)**.

All original code, documentation, and cultural integration assets are subject to evaluation and academic review guidelines. Proprietary third-party libraries and open datasets remain subject to their respective licenses (Flutter / BSD-3, FastAPI / MIT, React / MIT, OpenNeuro / CC0 / ODC-By).
