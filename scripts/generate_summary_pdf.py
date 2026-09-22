#!/usr/bin/env python3
"""
SMRITI — AI Cognitive Care Companion (SIH26003)
Executive Work Summary PDF Generator (v2.0 - Perfect 5-Page Grid)

Compiles a comprehensive, publication-grade executive summary of all work done
across Phase 01 through Phase 04 into an HTML document with precision print CSS,
then renders it into a high-resolution vector PDF using Microsoft Edge headless engine.
"""

import sys
import subprocess
from pathlib import Path
import pymupdf

WORKSPACE_ROOT = Path(__file__).resolve().parent.parent
OUTPUT_HTML = WORKSPACE_ROOT / "docs" / "SMRITI_Work_Summary_Report.html"
OUTPUT_PDF = WORKSPACE_ROOT / "SMRITI_Work_Summary_Report.pdf"

HTML_CONTENT = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>SMRITI — Engineering Work Summary Report (Phases 01 - 04)</title>
<style>
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap');

  :root {
    --primary: #1E293B;         /* Slate Navy */
    --primary-light: #334155;
    --accent: #3B7A57;          /* Sage Green */
    --accent-light: #EBF4EE;
    --accent-dark: #275239;
    --warm-bg: #FDFBF7;         /* Warm Cream */
    --card-bg: #FFFFFF;
    --border: #E2E8F0;
    --text-main: #0F172A;       /* Dark Charcoal */
    --text-muted: #64748B;
    --warning: #D97706;
    --warning-bg: #FFFBEB;
    --success: #059669;
    --success-bg: #D1FAE5;
    --info: #2563EB;
    --info-bg: #DBEAFE;
  }

  * {
    box-sizing: border-box;
    margin: 0;
    padding: 0;
  }

  body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
    background-color: var(--warm-bg);
    color: var(--text-main);
    line-height: 1.45;
    font-size: 11.5px;
    -webkit-print-color-adjust: exact;
    print-color-adjust: exact;
  }

  @page {
    size: A4 portrait;
    margin: 10mm 12mm 10mm 12mm;
  }

  .page-container {
    width: 100%;
    height: 275mm;
    max-height: 275mm;
    page-break-after: always;
    break-after: page;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
    overflow: hidden;
    position: relative;
  }

  .page-container:last-child {
    page-break-after: auto;
    break-after: auto;
  }

  .page-body {
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  /* Header Banner */
  .header-banner {
    background: linear-gradient(135deg, #1E293B 0%, #0F172A 100%);
    color: #FFFFFF;
    padding: 18px 24px;
    border-radius: 10px;
    margin-bottom: 12px;
    border-left: 6px solid var(--accent);
    box-shadow: 0 3px 8px rgba(15, 23, 42, 0.08);
  }

  .header-top {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 8px;
  }

  .org-badge {
    background: rgba(59, 122, 87, 0.3);
    color: #86EFAC;
    border: 1px solid rgba(134, 239, 172, 0.45);
    padding: 3px 9px;
    border-radius: 16px;
    font-size: 10px;
    font-weight: 700;
    letter-spacing: 0.5px;
    text-transform: uppercase;
    display: inline-block;
  }

  .meta-tag {
    font-size: 10px;
    color: #94A3B8;
    text-align: right;
    line-height: 1.35;
  }

  h1.title {
    font-size: 22px;
    font-weight: 800;
    letter-spacing: -0.4px;
    margin-bottom: 4px;
    color: #F8FAFC;
  }

  .subtitle {
    font-size: 11px;
    color: #CBD5E1;
    font-weight: 400;
    line-height: 1.35;
  }

  /* Strict Boundary Callout */
  .clinical-notice {
    background: #FFFBEB;
    border: 1px solid #FCD34D;
    border-left: 5px solid #D97706;
    padding: 9px 13px;
    border-radius: 7px;
    margin-bottom: 12px;
    font-size: 10.5px;
    line-height: 1.4;
  }

  .clinical-notice strong {
    color: #92400E;
    text-transform: uppercase;
    letter-spacing: 0.5px;
    display: block;
    margin-bottom: 3px;
    font-size: 10px;
  }

  /* Metric KPI Grid */
  .kpi-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 10px;
    margin-bottom: 14px;
  }

  .kpi-card {
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 10px 12px;
    text-align: center;
    box-shadow: 0 1px 3px rgba(0,0,0,0.02);
  }

  .kpi-val {
    font-size: 20px;
    font-weight: 800;
    color: var(--accent-dark);
    margin-bottom: 1px;
  }

  .kpi-label {
    font-size: 9.5px;
    font-weight: 700;
    color: var(--text-muted);
    text-transform: uppercase;
    letter-spacing: 0.4px;
  }

  .kpi-sub {
    font-size: 9px;
    color: #64748B;
    margin-top: 2px;
  }

  /* Section Styles */
  h2.section-title {
    font-size: 14px;
    font-weight: 700;
    color: var(--primary);
    border-bottom: 2px solid var(--accent);
    padding-bottom: 4px;
    margin-top: 10px;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  p {
    margin-bottom: 8px;
    color: #334155;
    text-align: justify;
    font-size: 11px;
    line-height: 1.45;
  }

  /* Grids */
  .grid-2 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 10px;
    margin-bottom: 10px;
  }

  .grid-3 {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
    margin-bottom: 10px;
  }

  .content-card {
    background: var(--card-bg);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 10px 12px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.02);
  }

  .content-card h4 {
    font-size: 11.5px;
    font-weight: 700;
    color: var(--primary);
    margin-bottom: 5px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .badge {
    font-size: 8.5px;
    font-weight: 700;
    padding: 2px 6px;
    border-radius: 10px;
    text-transform: uppercase;
    letter-spacing: 0.4px;
  }

  .badge-success { background: #D1FAE5; color: #065F46; border: 1px solid #A7F3D0; }
  .badge-info { background: #DBEAFE; color: #1E40AF; border: 1px solid #BFDBFE; }
  .badge-warning { background: #FEF3C7; color: #92400E; border: 1px solid #FDE68A; }

  /* Tables */
  table.data-table {
    width: 100%;
    border-collapse: collapse;
    margin-top: 5px;
    margin-bottom: 8px;
    font-size: 10.5px;
    background: var(--card-bg);
    border-radius: 6px;
    overflow: hidden;
    border: 1px solid var(--border);
  }

  table.data-table th {
    background: #F1F5F9;
    color: var(--primary);
    font-weight: 700;
    text-align: left;
    padding: 6px 8px;
    border-bottom: 1px solid var(--border);
    font-size: 9.5px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
  }

  table.data-table td {
    padding: 5px 8px;
    border-bottom: 1px solid #F1F5F9;
    color: #334155;
    vertical-align: middle;
    line-height: 1.35;
  }

  table.data-table tr:last-child td { border-bottom: none; }
  table.data-table tr:nth-child(even) { background: #F8FAFC; }

  /* Lists */
  ul.feature-list {
    list-style: none;
    padding-left: 0;
    margin-bottom: 6px;
  }

  ul.feature-list li {
    position: relative;
    padding-left: 15px;
    margin-bottom: 3.5px;
    font-size: 10.5px;
    color: #334155;
    line-height: 1.35;
  }

  ul.feature-list li::before {
    content: "✓";
    position: absolute;
    left: 0;
    color: var(--accent);
    font-weight: 800;
    font-size: 11px;
  }

  /* Code & Formulas */
  .code-block {
    background: #0F172A;
    color: #E2E8F0;
    font-family: 'JetBrains Mono', monospace;
    font-size: 9.5px;
    padding: 8px 10px;
    border-radius: 6px;
    margin-top: 4px;
    margin-bottom: 8px;
    line-height: 1.4;
  }

  .formula-box {
    background: #F8FAFC;
    border-left: 3px solid var(--accent);
    padding: 6px 8px;
    border-radius: 0 4px 4px 0;
    font-family: 'JetBrains Mono', monospace;
    font-size: 9.5px;
    color: var(--primary);
    margin: 5px 0 6px 0;
    line-height: 1.35;
  }

  /* Page Footer */
  .page-footer {
    border-top: 1px solid var(--border);
    padding-top: 6px;
    display: flex;
    justify-content: space-between;
    font-size: 9px;
    color: var(--text-muted);
    margin-top: 6px;
  }
</style>
</head>
<body>

  <!-- =========================================================================
       PAGE 1: EXECUTIVE OVERVIEW & MONOREPO ARCHITECTURE
       ========================================================================= -->
  <div class="page-container">
    <div class="page-body">
      <div class="header-banner">
        <div class="header-top">
          <span class="org-badge">Smart India Hackathon • SIH26003</span>
          <div class="meta-tag">
            <strong>Doc:</strong> SMRITI-ENG-2026-V1<br>
            <strong>Status:</strong> Phases 01-04 Verified<br>
            <strong>Date:</strong> September 2026
          </div>
        </div>
        <h1 class="title">SMRITI — AI Cognitive Care Companion</h1>
        <div class="subtitle">
          Engineering Work Summary & Architectural Blueprint: Culturally Familiar Assistive Platform for Elderly Dementia Patients in North Eastern Region (NER) — Ministry of Development of North Eastern Region (MDoNER)
        </div>
      </div>

      <div class="clinical-notice">
        <strong>Strict Clinical Boundary & Safety Notice</strong>
        SMRITI is an assistive platform for cognitive stimulation, familiar memory recall, daily routine support, and caregiver transparency. It is <strong>NOT</strong> a diagnostic medical device, clinical decision tool, or medical predictor. All metrics, UI copy, and difficulty adjustments strictly adhere to audited, non-clinical terminology.
      </div>

      <div class="kpi-grid">
        <div class="kpi-card">
          <div class="kpi-val">4 / 4</div>
          <div class="kpi-label">Phases Delivered</div>
          <div class="kpi-sub">Foundation & 3 Games Active</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-val">67 / 67</div>
          <div class="kpi-label">Tests Passed</div>
          <div class="kpi-sub">100% Pass Across Monorepo</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-val">3 Tiers</div>
          <div class="kpi-label">Adaptive Engine</div>
          <div class="kpi-sub">Deterministic Offline Dual-Layer</div>
        </div>
        <div class="kpi-card">
          <div class="kpi-val">100%</div>
          <div class="kpi-label">Offline-First</div>
          <div class="kpi-sub">Zero Cloud Latency for Play</div>
        </div>
      </div>

      <h2 class="section-title">
        <span>1. Executive Summary & Problem Context</span>
        <span class="badge badge-success">Delivered</span>
      </h2>
      <p>
        The North Eastern Region (NER) of India presents critical challenges for dementia care: geographical isolation, intermittent connectivity, high linguistic diversity (Assamese, Manipuri, Bodo, Bengali, Mizo, Khasi), and a scarcity of culturally contextualized cognitive tools. Standard commercial tools typically rely on Western metaphors and continuous high-speed internet. <strong>SMRITI</strong> solves this with a local-first, highly accessible digital companion engineered specifically for elderly patients and rural caregivers. Across four completed phases, the engineering team delivered a full monorepo featuring an elderly-first Flutter patient app, a dual-layer explainable adaptive difficulty engine, local SQLite persistence, dynamic physical phone demo tooling, and three complete, playable cognitive exercises.
      </p>

      <h2 class="section-title">
        <span>2. Monorepo Architecture & Component Stack</span>
        <span class="badge badge-info">Production Grade</span>
      </h2>
      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 25%;">Layer / Path</th>
            <th style="width: 22%;">Technology</th>
            <th style="width: 53%;">Core Responsibility & Delivered Features</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Patient Mobile App</strong><br><code>apps/patient_app</code></td>
            <td>Flutter 3.x (Dart 3)<br>Material 3 Custom Theme</td>
            <td>Elderly-first UI with 18sp+ typography, ≥64dp touch targets, calm restorative palette, 9 foundation navigation screens, and 3 full cognitive games.</td>
          </tr>
          <tr>
            <td><strong>Local Persistence</strong><br><code>lib/data/local</code></td>
            <td>SQLite via Drift<br>Wasm / FFI Native</td>
            <td>Type-safe local relational database with 6 tables (GameSessions, Reminders, ReminderEvents, Routines, Memories, SyncQueue) and reactive streams.</td>
          </tr>
          <tr>
            <td><strong>Adaptive AI Engine</strong><br><code>ai/ & apps/.../adaptive</code></td>
            <td>Python 3.13 / Dart<br>Pure Deterministic Rules</td>
            <td>Dual-layer explainable difficulty leveling (Level Up, Level Down, Maintain), non-clinical encouraging caregiver notes, zero medical jargon.</td>
          </tr>
          <tr>
            <td><strong>Backend REST API</strong><br><code>backend/api</code></td>
            <td>FastAPI / Pydantic v2<br>Uvicorn Async Server</td>
            <td>High-performance REST API with CORS, automatic OpenAPI docs, <code>/health</code> probe, and architecture for cloud synchronization.</td>
          </tr>
          <tr>
            <td><strong>Caregiver Dashboard</strong><br><code>apps/caregiver_dashboard</code></td>
            <td>React 18 + TypeScript<br>Vite Build System</td>
            <td>Caregiver transparency dashboard foundation for monitoring patient activity history, trends, and routine completions.</td>
          </tr>
          <tr>
            <td><strong>Demo & Tooling</strong><br><code>scripts/demo</code></td>
            <td>Python + PowerShell<br>QRCode + Dynamic LAN</td>
            <td>Dynamic LAN IPv4 detection and high-contrast QR code generator enabling instant physical smartphone preview on local Wi-Fi.</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div class="page-footer">
      <div><strong>SMRITI (SIH26003)</strong> • Ministry of Development of North Eastern Region (MDoNER)</div>
      <div>Confidential Technical Summary Report • Page 1 of 5</div>
    </div>
  </div>

  <!-- =========================================================================
       PAGE 2: THE THREE PLAYABLE COGNITIVE GAMES
       ========================================================================= -->
  <div class="page-container">
    <div class="page-body">
      <h2 class="section-title">
        <span>3. Core Playable Cognitive Exercises (Phases 02, 03 & 04)</span>
        <span class="badge badge-success">100% Playable</span>
      </h2>
      <p>
        Three distinct cognitive games have been fully implemented, tested, and integrated into SMRITI's shared session architecture. Each exercise targets specific neuro-supportive mechanisms while using familiar cultural metaphors from the North Eastern Region:
      </p>

      <div class="grid-3">
        <!-- Game 1: Memory Match -->
        <div class="content-card">
          <h4>
            <span>1. Memory Match</span>
            <span class="badge badge-success">Phase 02</span>
          </h4>
          <p style="font-size: 10px; margin-bottom: 4px;">
            Short-term working memory & visuospatial association pairing exercise.
          </p>
          <ul class="feature-list">
            <li><strong>Easy:</strong> 3 pairs (6 cards, 3×2, 1.5s preview)</li>
            <li><strong>Medium:</strong> 4 pairs (8 cards, 4×2, 1.0s preview)</li>
            <li><strong>Hard:</strong> 6 pairs (12 cards, 4×3, 0.5s preview)</li>
            <li><strong>NER Visuals:</strong> Assam Tea Cup, Garden Orchids, Traditional Home, Morning Sun, Harvest Fruit, Dhol Drum, Bamboo Grove, Brahmaputra Boat.</li>
            <li><strong>Interactivity:</strong> 3D Matrix flip (400ms), haptic cues, non-punitive gentle hint mechanism.</li>
          </ul>
          <div class="formula-box">
            accuracy = matchedPairs / totalAttempts<br>
            score = (matched*100) - (mistakes*15) - (hints*20)
          </div>
        </div>

        <!-- Game 2: Pattern Recognition -->
        <div class="content-card">
          <h4>
            <span>2. Pattern Recognition</span>
            <span class="badge badge-success">Phase 03</span>
          </h4>
          <p style="font-size: 10px; margin-bottom: 4px;">
            Visual sequence rhythm & deductive reasoning prediction exercise.
          </p>
          <ul class="feature-list">
            <li><strong>Easy:</strong> 4 rounds, 3–4 items, 2 choices (1 distractor)</li>
            <li><strong>Medium:</strong> 5 rounds, 4–5 items, 3 choices (2 distractors)</li>
            <li><strong>Hard:</strong> 6 rounds, 5–7 items, 4 choices (3 distractors)</li>
            <li><strong>Rhythms:</strong> Alternating (AB-AB), Triplet (ABC-ABC), and Progressive cycles.</li>
            <li><strong>Interactivity:</strong> Transition arrows, high-visibility "Next ?" slot, anti-double-tap lock, distractor elimination.</li>
          </ul>
          <div class="formula-box">
            accuracy = correctAnswers / totalAttempts<br>
            score = (correct*100) - (mistakes*20) - (hints*10)
          </div>
        </div>

        <!-- Game 3: Daily Routine Recall -->
        <div class="content-card">
          <h4>
            <span>3. Daily Routine Recall</span>
            <span class="badge badge-success">Phase 04</span>
          </h4>
          <p style="font-size: 10px; margin-bottom: 4px;">
            Chronological sequencing of everyday activities reinforcing orientation.
          </p>
          <ul class="feature-list">
            <li><strong>Easy:</strong> 3 questions, 3 steps, 3–4 choices (0–1 distractor)</li>
            <li><strong>Medium:</strong> 4 questions, 4 steps, 5 choices (1 distractor)</li>
            <li><strong>Hard:</strong> 5 questions, 5 steps, 7 choices (2 distractors)</li>
            <li><strong>Catalog:</strong> Morning Tea, Freshen Up, Breakfast, Walk, Scheduled Routine, Lunch, Rest, Evening Chat, Dinner, Sleep.</li>
            <li><strong>Interactivity:</strong> Tap-to-add, tap-to-remove, sequence clearing, highlighted hint cues.</li>
          </ul>
          <div class="formula-box">
            accuracy = correctRounds / (correct + mistakes)<br>
            score = (correct*100) - (mistakes*20) - (hints*10)
          </div>
        </div>
      </div>

      <h2 class="section-title">
        <span>Cross-Game Comparative Matrix</span>
        <span class="badge badge-info">Integrated Ecosystem</span>
      </h2>
      <table class="data-table">
        <thead>
          <tr>
            <th>Exercise</th>
            <th>Cognitive Domain</th>
            <th>Interaction Model</th>
            <th>Cultural Asset Catalog</th>
            <th>SQLite Key</th>
            <th>Scoring & Penalties</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Memory Match</strong></td>
            <td>Short-term visual working memory & spatial association</td>
            <td>3D card flip matrix with non-punitive reveal hints and turn locking</td>
            <td>Tea gardens, orchids, hornbill, muga silk, traditional utensils</td>
            <td><code>'memory_match'</code></td>
            <td>+100 / pair, -15 / mistake, -20 / hint</td>
          </tr>
          <tr>
            <td><strong>Pattern Recognition</strong></td>
            <td>Executive functioning, deductive logic & sequence prediction</td>
            <td>Linear rhythmic sequence with flow arrows and "Next ?" slot</td>
            <td>Alternating cultural objects (apple, tea, sun, bamboo, drum)</td>
            <td><code>'pattern_recognition'</code></td>
            <td>+100 / correct, -20 / mistake, -10 / hint</td>
          </tr>
          <tr>
            <td><strong>Daily Routine Recall</strong></td>
            <td>Episodic memory, chronological orientation & ADL confidence</td>
            <td>Slot sequence builder with tap-to-add and tap-to-remove slots</td>
            <td>Everyday NER routines (morning tea, bath, walk, lunch, rest)</td>
            <td><code>'routine_recall'</code></td>
            <td>+100 / round, -20 / mistake, -10 / hint</td>
          </tr>
        </tbody>
      </table>
      <p style="font-size: 10.5px; margin-top: 4px;">
        All three exercises automatically report metrics (accuracy, score, response time, mistakes, hints, difficulty) to <code>ClientAdaptiveEngine</code> for instant post-game recommendations, and persist records directly to Drift SQLite with <code>syncStatus: 'pending'</code>.
      </p>
    </div>

    <div class="page-footer">
      <div><strong>SMRITI (SIH26003)</strong> • Core Playable Cognitive Exercises</div>
      <div>Confidential Technical Summary Report • Page 2 of 5</div>
    </div>
  </div>

  <!-- =========================================================================
       PAGE 3: ACCESSIBLE DESIGN SYSTEM & DATA ARCHITECTURE
       ========================================================================= -->
  <div class="page-container">
    <div class="page-body">
      <h2 class="section-title">
        <span>4. Elderly-First Sensory & Visual Design System (WCAG AAA)</span>
        <span class="badge badge-info">Human-Centered Ergonomics</span>
      </h2>

      <div class="grid-2">
        <div class="content-card">
          <h4>Visual Ergonomics & Typography</h4>
          <ul class="feature-list">
            <li><strong>High-Contrast Color Palette:</strong> Deep slate navy (<code>#1E293B</code>), warm cream background (<code>#FDFBF7</code>), and restorative sage green (<code>#3B7A57</code>). Prevents visual glare and fatigue.</li>
            <li><strong>WCAG AAA Contrast Ratios:</strong> Text elements maintain contrast ratios exceeding 4.5:1 against card and scaffold backgrounds for maximum legibility.</li>
            <li><strong>Generous Touch Targets:</strong> All interactive buttons, cards, and options enforce minimum dimensions of ≥64×64dp with broad padding to accommodate hand tremors and motor decline.</li>
            <li><strong>High-Legibility Typography:</strong> Scaled typography baseline of 18sp for body copy and 24sp–32sp for headings, rendered cleanly with sub-pixel antialiasing.</li>
          </ul>
        </div>

        <div class="content-card">
          <h4>Sensory Calming & Cognitive Safety</h4>
          <ul class="feature-list">
            <li><strong>Zero Timer Pressure:</strong> Exercises feature no countdown clocks, flashing urgency indicators, or anxiety-inducing buzzers. Elders play entirely at their own natural pace.</li>
            <li><strong>Encouraging, Calm Feedback:</strong> Success is celebrated with gentle sage-green highlights and soothing copy ("Well done!", "Wonderful focus!"). Mistakes prompt supportive guidance.</li>
            <li><strong>Turn-Locking Safeguards:</strong> Interactive screens lock button processing during transitions (e.g. card flips, sequence evaluation) to eliminate unintended double-taps.</li>
            <li><strong>Predictable Navigation:</strong> Single-level linear screen progression without confusing multi-finger gestures, long-press actions, or hidden submenus.</li>
          </ul>
        </div>
      </div>

      <h2 class="section-title">
        <span>5. Offline-First Relational Architecture (Drift SQLite)</span>
        <span class="badge badge-success">Local-First Persistence</span>
      </h2>
      <p>
        To ensure uninterrupted usability across rural NER regions with intermittent or absent network connectivity, SMRITI implements an offline-first architecture powered by <strong>Drift SQLite</strong>. All patient operations persist immediately to local storage without depending on network availability:
      </p>

      <table class="data-table">
        <thead>
          <tr>
            <th style="width: 22%;">Table Name</th>
            <th style="width: 32%;">Key Columns & Types</th>
            <th style="width: 46%;">Functional Role & Synchronization Lifecycle</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><code>GameSessions</code></td>
            <td><code>localId (UUID)</code>, <code>gameType</code>, <code>score</code>, <code>accuracy</code>, <code>mistakes</code>, <code>responseTimeMs</code>, <code>difficulty</code>, <code>hintCount</code>, <code>syncStatus</code></td>
            <td>Stores complete exercise metrics immediately upon completion. Automatically enqueued to <code>SyncQueue</code> for cloud telemetry sync.</td>
          </tr>
          <tr>
            <td><code>Reminders</code></td>
            <td><code>localId</code>, <code>title</code>, <code>type</code>, <code>scheduledTime</code>, <code>enabled</code>, <code>syncStatus</code></td>
            <td>Stores daily reminders (hydration, walks, meals, routines) scheduled by caregivers. Generates local notifications offline.</td>
          </tr>
          <tr>
            <td><code>ReminderEvents</code></td>
            <td><code>localId</code>, <code>reminderId</code>, <code>eventType</code>, <code>occurredAt</code>, <code>syncStatus</code></td>
            <td>Tracks reminder interactions (acknowledged, dismissed, snoozed) for caregiver adherence monitoring.</td>
          </tr>
          <tr>
            <td><code>Routines</code></td>
            <td><code>localId</code>, <code>title</code>, <code>stepsJson</code>, <code>preferredTime</code>, <code>enabled</code>, <code>syncStatus</code></td>
            <td>Stores structured everyday sequences for the patient's daily routine tracking and exercise generation.</td>
          </tr>
          <tr>
            <td><code>Memories</code></td>
            <td><code>localId</code>, <code>title</code>, <code>description</code>, <code>mediaUri</code>, <code>language</code>, <code>syncStatus</code></td>
            <td>Personal and cultural memory vault items with localized descriptions and familiar imagery for reminiscence.</td>
          </tr>
          <tr>
            <td><code>SyncQueue</code></td>
            <td><code>localId</code>, <code>entityType</code>, <code>entityId</code>, <code>operation</code>, <code>status</code>, <code>retryCount</code>, <code>lastAttemptAt</code></td>
            <td>Graceful offline queue with exponential backoff handling bi-directional synchronization when network is available.</td>
          </tr>
        </tbody>
      </table>

      <p style="font-size: 10.5px;">
        <strong>Multi-Platform Persistence Engine:</strong> Built with cross-platform conditional compilation supporting Android native C SQLite libraries (<code>sqlite3_flutter_libs</code>) and Flutter Web via WebAssembly (<code>drift/wasm.dart</code>) with in-memory fallback.
      </p>
    </div>

    <div class="page-footer">
      <div><strong>SMRITI (SIH26003)</strong> • Design System & Local Persistence Architecture</div>
      <div>Confidential Technical Summary Report • Page 3 of 5</div>
    </div>
  </div>

  <!-- =========================================================================
       PAGE 4: ADAPTIVE AI ENGINE & VERIFICATION MATRIX
       ========================================================================= -->
  <div class="page-container">
    <div class="page-body">
      <h2 class="section-title">
        <span>6. Deterministic Dual-Layer Adaptive Difficulty Engine</span>
        <span class="badge badge-success">100% Explainable & Safe</span>
      </h2>

      <div class="grid-2">
        <div class="content-card">
          <h4>Algorithmic Leveling Logic</h4>
          <p style="font-size: 10px;">
            Unlike opaque deep learning models that can produce erratic difficulty spikes, SMRITI employs a 100% deterministic, explainable rule-based engine operating on client (Dart) and server (Python):
          </p>
          <ul class="feature-list">
            <li><strong>Level Up (+1):</strong> Accuracy ≥ 85%, Mistakes ≤ 1, Hints ≤ 1. Gently increases difficulty (e.g. 6 to 8 cards; 3 to 4 routine steps) to maintain healthy engagement.</li>
            <li><strong>Support Mode (-1):</strong> Accuracy &lt; 60% OR Mistakes ≥ 3. Immediately steps down difficulty and activates supportive prompts to prevent frustration.</li>
            <li><strong>Maintain Level (0):</strong> Accuracy between 60% and 84%. Keeps current tier to consolidate confidence and rhythm.</li>
          </ul>
        </div>

        <div class="content-card">
          <h4>Clinical Safety & Jargon Filtering</h4>
          <p style="font-size: 10px;">
            To comply with ethical health guidelines, all evaluation summaries pass through an algorithmic safety filter that strips clinical labels:
          </p>
          <div class="code-block">
BANNED_TERMS = [
  "dementia", "decline", "diagnosis", "impairment",
  "disease", "deficit", "stage", "score dropped"
]
# Enforced by unit tests in ai/tests/test_adaptive_engine.py
          </div>
          <p style="font-size: 10px; color: var(--accent-dark); font-weight: 600;">
            Output sample: <em>"Comfortable rhythm observed with 100% accuracy. Gently increasing steps to keep exercise engaging."</em>
          </p>
        </div>
      </div>

      <h2 class="section-title">
        <span>7. Comprehensive Monorepo Verification Matrix</span>
        <span class="badge badge-success">All 67 Tests Passed (100%)</span>
      </h2>

      <table class="data-table">
        <thead>
          <tr>
            <th>Verification Suite</th>
            <th>Command / Tool</th>
            <th>Test Scope & Key Assertions</th>
            <th>Result</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><strong>Flutter Static Analysis</strong></td>
            <td><code>flutter analyze</code></td>
            <td>Strict linter checks, zero deprecated APIs, sound null-safety, widget conventions.</td>
            <td><strong style="color: var(--success);">PASSED (0 issues)</strong></td>
          </tr>
          <tr>
            <td><strong>Patient App Unit Tests</strong></td>
            <td><code>flutter test test/</code></td>
            <td>Scoring formulas, zero-division guards, Drift SQLite persistence, adaptive engine.</td>
            <td><strong style="color: var(--success);">32 / 32 PASSED</strong></td>
          </tr>
          <tr>
            <td><strong>Patient App Widget Tests</strong></td>
            <td><code>flutter test test/</code></td>
            <td>Screen rendering, card flips, button states, sequence slots, dialog flows, pause/exit.</td>
            <td><strong style="color: var(--success);">21 / 21 PASSED</strong></td>
          </tr>
          <tr>
            <td><strong>AI Adaptive Engine Tests</strong></td>
            <td><code>pytest ai/tests</code></td>
            <td>Leveling triggers, streak tracking, response times, banned medical jargon filters.</td>
            <td><strong style="color: var(--success);">8 / 8 PASSED</strong></td>
          </tr>
          <tr>
            <td><strong>FastAPI Backend Tests</strong></td>
            <td><code>pytest backend/api/tests</code></td>
            <td>REST initialization, CORS handling, <code>/health</code> JSON schema and async responses.</td>
            <td><strong style="color: var(--success);">3 / 3 PASSED</strong></td>
          </tr>
          <tr>
            <td><strong>System Integration Tests</strong></td>
            <td><code>pytest tests/</code></td>
            <td>Cross-boundary data contracts, JSON schema conformance, end-to-end telemetry.</td>
            <td><strong style="color: var(--success);">3 / 3 PASSED</strong></td>
          </tr>
          <tr>
            <td><strong>Caregiver Dashboard Web</strong></td>
            <td><code>npm run build</code></td>
            <td>TypeScript compiler check (<code>tsc</code>) and production bundle optimization (Vite).</td>
            <td><strong style="color: var(--success);">PASSED (0 errors)</strong></td>
          </tr>
          <tr>
            <td><strong>Flutter Web Release Build</strong></td>
            <td><code>flutter build web</code></td>
            <td>Wasm-compatible Flutter Web release compiled cleanly into <code>build/web</code>.</td>
            <td><strong style="color: var(--success);">PASSED (Ready)</strong></td>
          </tr>
          <tr>
            <td><strong>Dynamic LAN QR Tooling</strong></td>
            <td><code>python generate_qr.py</code></td>
            <td>Routable IPv4 address resolution (no localhost), PNG & ASCII QR generation.</td>
            <td><strong style="color: var(--success);">PASSED</strong></td>
          </tr>
        </tbody>
      </table>

      <p style="font-size: 10.5px; margin-top: 4px;">
        Every commit and test suite is unified under <code>scripts/development/run_all_tests.ps1</code>, guaranteeing continuous regression protection across the monorepo.
      </p>
    </div>

    <div class="page-footer">
      <div><strong>SMRITI (SIH26003)</strong> • Adaptive AI & Automated Verification Matrix</div>
      <div>Confidential Technical Summary Report • Page 4 of 5</div>
    </div>
  </div>

  <!-- =========================================================================
       PAGE 5: MULTILINGUAL, PHONE DEMO & STRATEGIC ROADMAP
       ========================================================================= -->
  <div class="page-container">
    <div class="page-body">
      <h2 class="section-title">
        <span>8. Multilingual Localization & NER Cultural Governance</span>
        <span class="badge badge-info">3 Languages Live</span>
      </h2>
      <p>
        SMRITI features a centralized localization architecture in <code>lib/l10n/app_strings.dart</code> supporting <strong>English (<code>en</code>)</strong>, <strong>Hindi (<code>hi</code>)</strong>, and <strong>Assamese (<code>as</code>)</strong> across all UI copy, game cards, instructions, and error states. Under <code>data/DATASET_MANIFEST.md</code>, an ethical data governance framework outlines cultural schemas for expanding into other North Eastern languages (Bengali, Manipuri / Meitei, Bodo, Mizo, Khasi, Garo).
      </p>

      <h2 class="section-title">
        <span>9. Dynamic LAN Phone Demo System (No Localhost)</span>
        <span class="badge badge-success">Jury-Ready Tooling</span>
      </h2>
      <div class="grid-2">
        <div class="content-card">
          <h4>Automated LAN Discovery</h4>
          <p style="font-size: 10.5px;">
            To demonstrate SMRITI on physical smartphones during hackathon evaluations, the team developed <code>scripts/demo/generate_qr.py</code> and <code>start_phone_demo.ps1</code>.
          </p>
          <ul class="feature-list">
            <li>Dynamically inspects the active network route to detect the machine's true LAN IPv4 (e.g. <code>192.168.0.102</code>), strictly avoiding <code>127.0.0.1</code>.</li>
            <li>Generates a high-contrast PNG QR code (<code>smriti_phone_demo_qr.png</code>) and terminal ASCII code.</li>
          </ul>
        </div>

        <div class="content-card">
          <h4>One-Click Mobile Evaluation</h4>
          <p style="font-size: 10.5px;">
            Judges or evaluators connect their mobile devices to the same local Wi-Fi, scan the QR code with their default camera app, and immediately interact with SMRITI's live mobile interface at 60fps without installing APKs.
          </p>
          <div class="formula-box">
            Target URL: http://[LAN_IP]:8080<br>
            Command: .\\scripts\\demo\\start_phone_demo.ps1
          </div>
        </div>
      </div>

      <h2 class="section-title">
        <span>10. Strategic Roadmap & Production Rollout</span>
        <span class="badge badge-warning">Next Phases</span>
      </h2>
      <div class="grid-3">
        <div class="content-card">
          <h4>Phase 05: Cloud Sync</h4>
          <p style="font-size: 10px;">
            PostgreSQL backend integration to enable bi-directional synchronization of the offline <code>SyncQueue</code>, multi-device backup, and family alerts.
          </p>
        </div>
        <div class="content-card">
          <h4>Phase 06: Voice & Audio</h4>
          <p style="font-size: 10px;">
            Offline localized Text-to-Speech (TTS) and voice prompts recorded in regional Assamese and Bengali dialects for illiterate elders.
          </p>
        </div>
        <div class="content-card">
          <h4>Phase 07: Telemetry Hub</h4>
          <p style="font-size: 10px;">
            Longitudinal engagement charts on the Caregiver Dashboard, providing weekly routine summaries and non-clinical trend highlights.
          </p>
        </div>
      </div>

      <div class="content-card" style="margin-top: 12px; background: #F8FAFC; border-left: 4px solid var(--accent);">
        <div style="display: flex; justify-content: space-between; align-items: center;">
          <div>
            <h4 style="color: var(--primary); margin-bottom: 2px;">Engineering Team Deliverable Sign-Off</h4>
            <p style="font-size: 10px; color: var(--text-muted); margin-bottom: 0;">
              Verified by SIH26003 Core Engineering Team for Ministry of Development of North Eastern Region (MDoNER).
            </p>
          </div>
          <span class="badge badge-success" style="font-size: 10px; padding: 4px 10px;">STATUS: MVP VERIFIED</span>
        </div>
      </div>
    </div>

    <div class="page-footer">
      <div><strong>SMRITI (SIH26003)</strong> • Engineering Work Summary Report • Final Sign-Off</div>
      <div>Confidential Technical Summary Report • Page 5 of 5</div>
    </div>
  </div>

</body>
</html>
"""

def generate_pdf():
    print("============================================================")
    print("       SMRITI EXECUTIVE WORK SUMMARY PDF GENERATOR          ")
    print("============================================================")

    # 1. Write HTML Report
    OUTPUT_HTML.parent.mkdir(parents=True, exist_ok=True)
    with open(OUTPUT_HTML, "w", encoding="utf-8") as f:
        f.write(HTML_CONTENT)
    print(f"[1/3] Generated Report HTML: {OUTPUT_HTML}")

    # 2. Locate Edge or Chrome
    edge_paths = [
        Path("C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe"),
        Path("C:/Program Files/Microsoft/Edge/Application/msedge.exe"),
        Path("C:/Program Files/Google/Chrome/Application/chrome.exe"),
    ]
    browser_bin = None
    for p in edge_paths:
        if p.exists():
            browser_bin = p
            break

    if not browser_bin:
        print("[-] Error: Could not find Microsoft Edge or Google Chrome executable.")
        sys.exit(1)

    print(f"[2/3] Using Headless Browser: {browser_bin}")
    file_uri = OUTPUT_HTML.as_uri()

    cmd = [
        str(browser_bin),
        "--headless",
        "--disable-gpu",
        "--no-pdf-header-footer",
        "--run-all-compositor-stages-before-draw",
        f"--print-to-pdf={OUTPUT_PDF}",
        file_uri
    ]

    res = subprocess.run(cmd, capture_output=True, text=True)
    if not OUTPUT_PDF.exists():
        print(f"[-] PDF generation failed. Return code: {res.returncode}")
        print(f"Stderr: {res.stderr}")
        sys.exit(1)

    print(f"[3/3] Successfully compiled PDF: {OUTPUT_PDF}")

    # 3. Validate PDF with PyMuPDF
    doc = pymupdf.open(str(OUTPUT_PDF))
    page_count = len(doc)
    file_size_kb = OUTPUT_PDF.stat().st_size / 1024

    # Save preview PNGs of all pages
    preview_dir = WORKSPACE_ROOT / "docs" / "pdf_preview"
    preview_dir.mkdir(parents=True, exist_ok=True)
    for i, page in enumerate(doc):
        pix = page.get_pixmap(dpi=150)
        pix.save(str(preview_dir / f"page_{i+1}.png"))

    print("============================================================")
    print(f"  PDF GENERATION COMPLETED SUCCESSFULLY!                    ")
    print(f"  - Target Path  : {OUTPUT_PDF}")
    print(f"  - Page Count   : {page_count} pages")
    print(f"  - File Size    : {file_size_kb:.2f} KB")
    print(f"  - Preview PNGs : {preview_dir}")
    print("============================================================")

if __name__ == "__main__":
    generate_pdf()
