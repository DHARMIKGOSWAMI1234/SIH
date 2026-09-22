enum AdaptiveDifficultyAction {
  increase,
  maintain,
  decrease,
}

class AdaptiveEvaluationResult {
  final AdaptiveDifficultyAction action;
  final int previousDifficulty;
  final int nextDifficulty;
  final String patientFeedback;
  final String caregiverExplanation;
  final Map<String, dynamic> supportTriggers;

  const AdaptiveEvaluationResult({
    required this.action,
    required this.previousDifficulty,
    required this.nextDifficulty,
    required this.patientFeedback,
    required this.caregiverExplanation,
    this.supportTriggers = const {},
  });
}

/// Offline-First Client Adaptive Difficulty Engine for SMRITI.
///
/// 100% deterministic, explainable, and non-clinical.
/// Mirrors the core AI rules without requiring a network connection.
class ClientAdaptiveEngine {
  static const int minDifficulty = 1;
  static const int maxDifficulty = 3; // Easy (1), Medium (2), Hard (3) in Phase 02

  static const double highAccuracyThreshold = 0.85;
  static const double lowAccuracyThreshold = 0.60;
  static const int maxMistakesForPromotion = 2;
  static const int mistakesTriggerSupport = 4;

  // Prohibited clinical words that must never appear in explanations
  static const Set<String> prohibitedClinicalTerms = {
    'dementia',
    'alzheimer',
    'cure',
    'diagnos',
    'severity',
    'decline',
    'patholog',
    'impairment',
    'prognosis',
    'deficit',
    'symptom',
  };

  static AdaptiveEvaluationResult evaluate({
    required int currentDifficulty,
    required double accuracy,
    required int mistakes,
    required int hintsUsed,
    required double responseTimeMs,
    required bool completed,
  }) {
    final curDiff = currentDifficulty.clamp(minDifficulty, maxDifficulty);
    AdaptiveDifficultyAction action;
    int nextDiff;
    String patientFeedback;
    String caregiverExplanation;
    Map<String, dynamic> supportTriggers = {};

    // Rule 1: High performance promotion
    if (accuracy >= highAccuracyThreshold &&
        mistakes <= maxMistakesForPromotion &&
        hintsUsed == 0 &&
        completed) {
      if (curDiff < maxDifficulty) {
        nextDiff = curDiff + 1;
        action = AdaptiveDifficultyAction.increase;
        patientFeedback =
            'Wonderful focus! You matched every pair smoothly. The next exercise can include a few more cards.';
        caregiverExplanation =
            'High exercise accuracy (${(accuracy * 100).round()}%) and relaxed pace observed. Recommending a slightly more varied activity level.';
      } else {
        nextDiff = maxDifficulty;
        action = AdaptiveDifficultyAction.maintain;
        patientFeedback =
            'Superb consistency at this level! Let’s keep this comfortable rhythm going.';
        caregiverExplanation =
            'Consistent high performance at top activity tier. Maintaining current settings for ongoing engagement.';
      }
    }
    // Rule 2: Support / Difficulty reduction
    else if (accuracy < lowAccuracyThreshold ||
        mistakes >= mistakesTriggerSupport ||
        !completed) {
      if (curDiff > minDifficulty) {
        nextDiff = curDiff - 1;
        action = AdaptiveDifficultyAction.decrease;
        patientFeedback =
            'Good effort! We will adjust the next activity with fewer cards so you can relax and enjoy.';
        caregiverExplanation =
            'Recent session presented a challenge. Adjusting to a gentler pace with fewer cards to ensure comfort.';
        supportTriggers = {'extra_hints': true, 'reduced_item_count': true};
      } else {
        nextDiff = minDifficulty;
        action = AdaptiveDifficultyAction.maintain;
        patientFeedback =
            'You did very well spending time with the cards. Helpful hints will stay ready whenever you wish.';
        caregiverExplanation =
            'Providing supportive visual prompts and extended viewing time for comfortable exercise completion.';
        supportTriggers = {'extra_hints': true, 'extended_time': true};
      }
    }
    // Rule 3: Balanced steady participation
    else {
      nextDiff = curDiff;
      action = AdaptiveDifficultyAction.maintain;
      patientFeedback =
          'Steady and enjoyable participation! Let’s maintain this comfortable level.';
      caregiverExplanation =
          'Steady exercise completion (${(accuracy * 100).round()}% accuracy). Maintaining current level for consistent engagement.';
    }

    // Clinical boundary verification
    _assertNonClinical(caregiverExplanation);
    _assertNonClinical(patientFeedback);

    return AdaptiveEvaluationResult(
      action: action,
      previousDifficulty: curDiff,
      nextDifficulty: nextDiff,
      patientFeedback: patientFeedback,
      caregiverExplanation: caregiverExplanation,
      supportTriggers: supportTriggers,
    );
  }

  static void _assertNonClinical(String text) {
    final lower = text.toLowerCase();
    for (final term in prohibitedClinicalTerms) {
      if (lower.contains(term)) {
        throw StateError(
          'Clinical boundary violation: prohibited term "$term" found in "$text"',
        );
      }
    }
  }
}
