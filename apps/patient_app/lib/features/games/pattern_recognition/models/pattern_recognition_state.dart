import 'dart:math';
import 'pattern_question.dart';

enum PatternDifficulty {
  easy,
  medium,
  hard,
}

extension PatternDifficultyExt on PatternDifficulty {
  String get displayName {
    switch (this) {
      case PatternDifficulty.easy:
        return 'Easy';
      case PatternDifficulty.medium:
        return 'Medium';
      case PatternDifficulty.hard:
        return 'Challenging';
    }
  }

  int get levelNumber {
    switch (this) {
      case PatternDifficulty.easy:
        return 1;
      case PatternDifficulty.medium:
        return 2;
      case PatternDifficulty.hard:
        return 3;
    }
  }

  int get questionCount {
    switch (this) {
      case PatternDifficulty.easy:
        return 4;
      case PatternDifficulty.medium:
        return 5;
      case PatternDifficulty.hard:
        return 6;
    }
  }

  int get optionCount {
    switch (this) {
      case PatternDifficulty.easy:
        return 2;
      case PatternDifficulty.medium:
        return 3;
      case PatternDifficulty.hard:
        return 4;
    }
  }
}

enum PatternGameStatus {
  intro,
  playing,
  checkingAnswer,
  completed,
}

/// Record of interaction metrics for a single round of Pattern Recognition.
class PatternRoundRecord {
  final int roundNumber;
  final PatternType patternType;
  final DateTime roundStartedAt;
  final DateTime answerSelectedAt;
  final double responseTimeMs;
  final bool isCorrect;
  final int mistakesInRound;
  final int hintsUsedInRound;

  const PatternRoundRecord({
    required this.roundNumber,
    required this.patternType,
    required this.roundStartedAt,
    required this.answerSelectedAt,
    required this.responseTimeMs,
    required this.isCorrect,
    this.mistakesInRound = 0,
    this.hintsUsedInRound = 0,
  });
}

/// Defensive, transparent activity metrics calculated for a completed Pattern Recognition session.
/// Strictly non-clinical and non-diagnostic.
class PatternRecognitionMetrics {
  final PatternDifficulty difficulty;
  final int totalQuestions;
  final int correctAnswers;
  final int mistakes;
  final int hintCount;
  final double accuracy; // 0.0 to 1.0
  final int score;
  final DateTime startedAt;
  final DateTime completedAt;
  final List<PatternRoundRecord> roundRecords;
  final double averageResponseTimeMs;

  const PatternRecognitionMetrics({
    required this.difficulty,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.mistakes,
    required this.hintCount,
    required this.accuracy,
    required this.score,
    required this.startedAt,
    required this.completedAt,
    this.roundRecords = const [],
    this.averageResponseTimeMs = 0.0,
  });

  int get durationSeconds =>
      completedAt.difference(startedAt).inSeconds.clamp(1, 3600);

  /// Stored into Drift GameSessions responseTimeMs field.
  /// Uses average response time across rounds if available, otherwise total duration.
  double get responseTimeMs => averageResponseTimeMs > 0
      ? averageResponseTimeMs
      : completedAt.difference(startedAt).inMilliseconds.toDouble();

  int get accuracyPercentage => (accuracy * 100).round().clamp(0, 100);

  static PatternRecognitionMetrics calculate({
    required PatternDifficulty difficulty,
    required int totalQuestions,
    required int correctAnswers,
    required int mistakes,
    required int hintCount,
    required DateTime startedAt,
    required DateTime completedAt,
    List<PatternRoundRecord> roundRecords = const [],
  }) {
    final int totalAttempts = correctAnswers + mistakes;
    // Formula: accuracy = correctAnswers / max(1, totalAttempts)
    final double computedAccuracy = totalAttempts > 0
        ? (correctAnswers / totalAttempts).clamp(0.0, 1.0)
        : 1.0;

    // Formula: (correctAnswers * 100) - (mistakes * 20) - (hintCount * 10)
    final int computedScore = max(
      0,
      (correctAnswers * 100) - (mistakes * 20) - (hintCount * 10),
    );

    double avgResponseTime = 0.0;
    if (roundRecords.isNotEmpty) {
      final totalMs = roundRecords.fold<double>(
        0.0,
        (prev, r) => prev + r.responseTimeMs,
      );
      avgResponseTime = totalMs / roundRecords.length;
    } else {
      final totalMs = completedAt.difference(startedAt).inMilliseconds.toDouble();
      avgResponseTime = totalQuestions > 0 ? (totalMs / totalQuestions) : totalMs;
    }

    return PatternRecognitionMetrics(
      difficulty: difficulty,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      mistakes: mistakes,
      hintCount: hintCount,
      accuracy: computedAccuracy,
      score: computedScore,
      startedAt: startedAt,
      completedAt: completedAt,
      roundRecords: roundRecords,
      averageResponseTimeMs: avgResponseTime,
    );
  }
}
