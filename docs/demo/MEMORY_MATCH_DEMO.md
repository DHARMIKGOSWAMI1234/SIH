# SMRITI — Memory Match Game Demonstration & Verification Guide

This document provides complete instructions for demonstrating and verifying the **Memory Match** cognitive activity in SMRITI.

---

## 1. Clinical Boundary Notice
> [!IMPORTANT]
> **SMRITI Memory Match is an assistive cognitive stimulation and engagement activity.**
> It is **NOT** a dementia diagnostic test, severity score, or clinical evaluation.
> All terminology, scoring, and adaptive engine recommendations reflect game performance and engagement comfort only.

---

## 2. Product Experience & User Flow

```
Home Screen
    ↓
Tap [ Memory Match Game ]
    ↓
Memory Match Intro Screen
  - Simple instructions ("Find the two cards that belong together")
  - Select Difficulty: Easy (3 pairs), Medium (4 pairs), Challenging (6 pairs)
    ↓
Tap [ Start Game ]
    ↓
Card Grid Displayed
  - Touch target >= 64dp
  - Smooth 3D card flip animation
  - Tap Card 1 → Reveals picture
  - Tap Card 2 → Reveals picture & checks match
  - Match: Subtle green highlight & "You found a pair!"
  - Mismatch: Brief pause (1100ms) & "Not a match yet. Take your time."
  - Optional Hint Button: Highlights matching pair in warm amber
    ↓
All Pairs Found
    ↓
Results Screen
  - Pairs found: e.g. 3 of 3
  - Exercise Accuracy: e.g. 85%
  - Total Flips: e.g. 7
  - Supportive Hints Used: e.g. 1
  - Adaptive Suggestion: e.g. "Wonderful focus! Recommending slightly more cards."
  - Caregiver Activity Record: Non-clinical explanation
  - Automatic Local Persistence in SQLite
    ↓
Navigation: [ Play Again ] / [ Back to Games ] / [ Return to Home ]
```

---

## 3. Difficulty Levels

| Level | Name | Pairs | Total Cards | Mismatch Pause | Design Focus |
| :--- | :--- | :---: | :---: | :---: | :--- |
| **Level 1** | **Easy** | 3 | 6 cards | 1100 ms | Large cards (100x125dp), minimal choices, relaxed pace. |
| **Level 2** | **Medium** | 4 | 8 cards | 900 ms | Balanced variety of everyday familiar items. |
| **Level 3** | **Challenging** | 6 | 12 cards | 700 ms | Full set of cultural & nature items for active engagement. |

---

## 4. Scoring & Accuracy Formulas

- **Exercise Accuracy Formula:**
  $$\text{Accuracy} = \frac{\text{Matched Pairs}}{\max(1, \text{Total Attempts})}$$
  - Clamped between $0.0$ and $1.0$ (e.g. $85\%$).
- **Game Score Formula:**
  $$\text{Score} = \max\left(0, 100 + (\text{Matched Pairs} \times 50) - (\text{Mistakes} \times 10) - (\text{Hints} \times 5)\right)$$
- **Response Time:**
  - Total elapsed milliseconds from start to completion. Used for non-clinical comfort pacing only.

---

## 5. Client Deterministic Adaptive Engine

The client-side engine evaluates completed sessions locally without network dependencies:
1. **Promotion (Increase):** Accuracy $\ge 85\%$, $\le 2$ mistakes, 0 hints used $\to$ Suggests advancing to next level.
2. **Demotion (Decrease):** Accuracy $< 60\%$ or $\ge 4$ mistakes $\to$ Suggests gentler pace with fewer cards and activates supportive hints.
3. **Maintain:** Steady participation ($60\% - 84\%$) $\to$ Recommends continuing at current enjoyable level.
4. **Clinical Safety Ban:** Explanations strictly exclude prohibited words (*dementia*, *cure*, *diagnos\**, *decline*, *impairment*, *severity*).

---

## 6. Offline-First Verification & Local Persistence

1. Run the app on phone or Chrome:
   ```powershell
   .\scripts\demo\start_phone_demo.ps1
   ```
2. Disconnect Wi-Fi / enable phone Airplane Mode after page load.
3. Play a complete round of Memory Match.
4. Verify the Results Screen shows *"Preserved securely in local SQLite database"*.
5. Go to **Home $\to$ Activity History (Progress Screen)**.
6. Observe that your newly completed game appears at the top of the history list with exact date, time, difficulty, and accuracy percentage!
