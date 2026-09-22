import 'dart:math';

enum RoutineRecallDifficulty {
  easy,
  medium,
  hard,
}

extension RoutineRecallDifficultyExt on RoutineRecallDifficulty {
  String get displayName {
    switch (this) {
      case RoutineRecallDifficulty.easy:
        return 'Easy';
      case RoutineRecallDifficulty.medium:
        return 'Medium';
      case RoutineRecallDifficulty.hard:
        return 'Challenging';
    }
  }

  int get levelNumber {
    switch (this) {
      case RoutineRecallDifficulty.easy:
        return 1;
      case RoutineRecallDifficulty.medium:
        return 2;
      case RoutineRecallDifficulty.hard:
        return 3;
    }
  }

  int get questionCount {
    switch (this) {
      case RoutineRecallDifficulty.easy:
        return 3;
      case RoutineRecallDifficulty.medium:
        return 4;
      case RoutineRecallDifficulty.hard:
        return 5;
    }
  }

  String get stepCountDescription {
    switch (this) {
      case RoutineRecallDifficulty.easy:
        return '3 daily steps • Generous hints';
      case RoutineRecallDifficulty.medium:
        return '4 daily steps • Moderate choices';
      case RoutineRecallDifficulty.hard:
        return '5 daily steps • Full day sequence';
    }
  }
}

enum RoutineGameStatus {
  intro,
  arranging,
  evaluating,
  completed,
}

/// Calculated metrics and statistics for a completed Daily Routine Recall session.
class RoutineRecallMetrics {
  final RoutineRecallDifficulty difficulty;
  final int totalQuestions;
  final int correctAnswers;
  final int mistakes;
  final int hintCount;
  final double accuracy; // 0.0 to 1.0
  final int score;
  final DateTime startedAt;
  final DateTime completedAt;

  const RoutineRecallMetrics({
    required this.difficulty,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.mistakes,
    required this.hintCount,
    required this.accuracy,
    required this.score,
    required this.startedAt,
    required this.completedAt,
  });

  int get durationSeconds =>
      completedAt.difference(startedAt).inSeconds.clamp(1, 3600);

  double get responseTimeMs =>
      completedAt.difference(startedAt).inMilliseconds.toDouble();

  int get accuracyPercentage => (accuracy * 100).round().clamp(0, 100);

  static RoutineRecallMetrics calculate({
    required RoutineRecallDifficulty difficulty,
    required int totalQuestions,
    required int correctAnswers,
    required int mistakes,
    required int hintCount,
    required DateTime startedAt,
    required DateTime completedAt,
  }) {
    final int totalAttempts = correctAnswers + mistakes;
    final double computedAccuracy = totalAttempts > 0
        ? (correctAnswers / totalAttempts).clamp(0.0, 1.0)
        : 1.0;

    // Formula consistent with Pattern Recognition & SMRITI Master Spec:
    // (correctAnswers * 100) - (mistakes * 20) - (hintCount * 10)
    final int computedScore = max(
      0,
      (correctAnswers * 100) - (mistakes * 20) - (hintCount * 10),
    );

    return RoutineRecallMetrics(
      difficulty: difficulty,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      mistakes: mistakes,
      hintCount: hintCount,
      accuracy: computedAccuracy,
      score: computedScore,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }
}
