# SMRITI — Voice Interaction Architecture ("Talk to Me")

**Phase 07 Technical Specification**  
**Team**: THE DEBUGGERS | **SIH26003** | **Project**: SMRITI — AI Cognitive Care Companion

---

## 1. Executive Summary & Design Philosophy

The SMRITI Voice Interaction pipeline ("Talk to Me") provides an intuitive, hands-free conversational layer for elderly individuals experiencing mild cognitive impairment (MCI) or early-stage dementia.

### Core Architectural Principles:
1. **Voice is Optional, Touch is Universal**:
   - Voice interaction is strictly an augmentative channel. Every screen and operation has full, high-contrast, touch-based equivalents.
   - The user can close or cancel the voice interface at any instant without loss of state.
2. **Deterministic, Hallucination-Free Retrieval**:
   - No external generative Large Language Models (LLMs) are used in the runtime voice loop.
   - All factual queries (family relationships, memories, reminders, routines) are resolved against the local SQLite/Drift database.
3. **Strict Non-Clinical Boundary**:
   - The voice system **never** provides medical diagnosis, dementia staging, symptom assessment, or pharmacological/treatment advice.
   - Any clinical inquiry triggers an immediate, compassionate medical guardrail directing the patient to their physician or caregiver.
4. **Offline-First & Privacy Preserving**:
   - Voice transcripts and audio are processed locally without cloud transmission or third-party audio telemetry.
   - Personal user memories, names, family descriptions, and caregiver notes are preserved verbatim and **never automatically translated**.

---

## 2. 9 Supported Languages & Voice Capability Matrix

SMRITI supports **9 regional languages of India**, with special emphasis on the North-Eastern Region (NER) and major Indian languages.

> [!IMPORTANT]
> SMRITI strictly defines **9 supported languages**. In accordance with clinical and software verification standards, capabilities are explicitly divided into:
> - **Fully Translation-Verified**: Complete human review of all UI and conversational strings.
> - **Architecturally Supported / Translation Review Required**: Localization pipeline and starter lexicons in place, awaiting secondary native speaker review.
> - **Verified on Device**: Tested and confirmed working on the Android target platform.

| Language | Code | Translation Status | ASR Arch. | ASR Tested | TTS Arch. | TTS Tested | Offline Verified |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **English** | `en` | **Verified** | Yes | **Verified** | Yes | **Verified** | Yes |
| **Hindi** | `hi` | **Verified** | Yes | **Verified** | Yes | **Verified** | Yes |
| **Assamese** | `as` | **Verified** | Yes | Review Req. | Yes | Review Req. | Pending Engine |
| **Bengali** | `bn` | Review Req. | Yes | Review Req. | Yes | Review Req. | Pending Engine |
| **Meitei/Manipuri** | `mni` | Review Req. | Yes | Review Req. | Yes | Review Req. | Pending Engine |
| **Bodo** | `brx` | Review Req. | Yes | Review Req. | Yes | Review Req. | Pending Engine |
| **Mizo** | `lus` | Review Req. | Yes | Review Req. | Yes | Review Req. | Pending Engine |
| **Khasi** | `kha` | Review Req. | Yes | Review Req. | Yes | Review Req. | Pending Engine |
| **Garo** | `grt` | Review Req. | Yes | Review Req. | Yes | Review Req. | Pending Engine |

---

## 3. Pipeline Architecture

```
                       ┌────────────────────────────────────────┐
                       │           Microphone Input             │
                       └───────────────────┬────────────────────┘
                                           │
                                           ▼
                       ┌────────────────────────────────────────┐
                       │     SpeechRecognitionService (ASR)     │
                       │   - Platform Speech / Headless Mock    │
                       └───────────────────┬────────────────────┘
                                           │ (Transcript)
                                           ▼
                       ┌────────────────────────────────────────┐
                       │             IntentService              │
                       │   - Deterministic Regex & Keyword Match│
                       └───────────────────┬────────────────────┘
                                           │
         ┌──────────────────┬──────────────┴─────┬─────────────────┬──────────────────┐
         │                  │                    │                 │                  │
         ▼                  ▼                    ▼                 ▼                  ▼
┌──────────────────┐┌───────────────┐  ┌──────────────────┐┌───────────────┐  ┌───────────────┐
│ Medical Guardrail││ Family Query  │  │ Reminder Query   ││ Routine Query │  │ Game Launch   │
│ (Strict Boundary)││ (MemoryRescue)│  │ (SmritiRepo)     ││ (SmritiRepo)  │  │ (App Shell)   │
└────────┬─────────┘└───────┬───────┘  └─────────┬────────┘└───────┬───────┘  └───────┬───────┘
         │                  │                    │                 │                  │
         └──────────────────┼────────────────────┴─────────────────┴──────────────────┘
                            │ (Structured Response: spokenText + visualText)
                            ▼
         ┌────────────────────────────────────────────────────────┐
         │              TextToSpeechService (TTS)                 │
         │   - Calm pacing, speech-rate 0.85x for elderly         │
         └────────────────────────────────────────────────────────┘
```

### 3.1. Intent Parsing & Non-Clinical Guardrails

The `IntentService` maps user speech into 6 discrete intent categories:
1. `medicalQuery`: Detected via clinical terms (`dementia`, `alzheimer`, `diagnos`, `stage`, `cure`, `donepezil`, `treatment`, `am i sick`).
   - **Response**: *"I am your memory companion, not a doctor. For any medical or health questions, please consult your doctor or caregiver."* (Localized in all 9 languages).
2. `familyQuery`: Queries about family relationships or names (`Who is Ananya?`, `Tell me about Rahul`, `What is my grandson's name?`).
   - Resolved deterministically via `MemoryRescueService` against local SQLite `memories`.
3. `reminderQuery`: Queries about schedules (`What is my next reminder?`, `What medicine do I need to take?`).
   - Resolved deterministically via `SmritiRepository.getReminders()`.
4. `routineQuery`: Queries regarding daily steps (`What should I do today?`, `What is my routine?`).
   - Resolved deterministically via `SmritiRepository.getRoutines()`.
5. `gameLaunch`: Cognitive stimulation launch commands (`Play memory match`, `Start pattern game`).
   - Dispatches navigation to the requested cognitive exercise.
6. `greeting`: Friendly welcoming statements (`Hello`, `Namaste`, `Nomoskar`).

---

## 4. UI/UX: The Elderly-First Voice Sheet

The `VoiceInteractionSheet` adheres to strict accessibility and elderly-first ergonomics:
- **Large Target Area**: 96x96dp pulsating microphone button with dual-ring status indicator.
- **Calm Visual Feedback**:
  - Listening: Soft Sage pulsator (`#4A6B5D`)
  - Processing: Amber pulsing spinner
  - Speaking: Waveform visualizer
  - Error: Calm Slate with clear retry and touch fallback buttons.
- **Synchronized Visual & Audio**: Every spoken sentence is simultaneously rendered on screen in high-contrast (minimum 7:1 contrast ratio) 20sp text for hard-of-hearing users.
- **Zero RenderFlex Overflow**: Tested across 320dp, 360dp, 390dp, 412dp, and 430dp screen widths.

---

## 5. Fallback Safety & Error Handling

1. **Hardware / Permission Denied**:
   - If microphone permissions are rejected or hardware is unavailable, the sheet displays a polite message (`voiceNotAvailable`) and automatically highlights touch navigation options.
2. **Speech Timeout**:
   - If no speech is detected after 5 seconds of listening, the sheet provides a gentle hint (`voiceNoSpeechDetected`) and returns to idle.
3. **Missing Engine**:
   - On devices lacking native TTS engines for specific regional languages, the app falls back to visual display of the response without throwing unhandled exceptions.
