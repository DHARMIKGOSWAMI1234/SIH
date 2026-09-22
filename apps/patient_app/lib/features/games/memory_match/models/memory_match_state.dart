import 'dart:math';
import 'memory_card_item.dart';

enum MemoryMatchDifficulty {
  easy,
  medium,
  hard,
}

extension MemoryMatchDifficultyExt on MemoryMatchDifficulty {
  String get displayName {
    switch (this) {
      case MemoryMatchDifficulty.easy:
        return 'Easy';
      case MemoryMatchDifficulty.medium:
        return 'Medium';
      case MemoryMatchDifficulty.hard:
        return 'Challenging';
    }
  }

  int get pairCount {
    switch (this) {
      case MemoryMatchDifficulty.easy:
        return 3;
      case MemoryMatchDifficulty.medium:
        return 4;
      case MemoryMatchDifficulty.hard:
        return 6;
    }
  }

  int get totalCards => pairCount * 2;

  int get levelNumber {
    switch (this) {
      case MemoryMatchDifficulty.easy:
        return 1;
      case MemoryMatchDifficulty.medium:
        return 2;
      case MemoryMatchDifficulty.hard:
        return 3;
    }
  }

  Duration get mismatchDisplayDuration {
    switch (this) {
      case MemoryMatchDifficulty.easy:
        return const Duration(milliseconds: 1100);
      case MemoryMatchDifficulty.medium:
        return const Duration(milliseconds: 900);
      case MemoryMatchDifficulty.hard:
        return const Duration(milliseconds: 700);
    }
  }
}

enum MemoryMatchStatus {
  idle,
  playing,
  checkingMatch,
  completed,
}

/// Calculated metrics and statistics for a completed Memory Match session.
class MemoryMatchMetrics {
  final MemoryMatchDifficulty difficulty;
  final int totalPairs;
  final int matchedPairs;
  final int totalAttempts;
  final int mistakes;
  final int hintCount;
  final double accuracy; // 0.0 to 1.0
  final int score;
  final DateTime startedAt;
  final DateTime completedAt;

  MemoryMatchMetrics({
    required this.difficulty,
    required this.totalPairs,
    required this.matchedPairs,
    required this.totalAttempts,
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

  static MemoryMatchMetrics calculate({
    required MemoryMatchDifficulty difficulty,
    required int matchedPairs,
    required int totalAttempts,
    required int mistakes,
    required int hintCount,
    required DateTime startedAt,
    required DateTime completedAt,
  }) {
    // Formula: accuracy = matchedPairs / max(1, totalAttempts)
    final double computedAccuracy = totalAttempts > 0
        ? (matchedPairs / totalAttempts).clamp(0.0, 1.0)
        : 1.0;

    // Formula: base 100 + (matchedPairs * 50) - (mistakes * 10) - (hintCount * 5)
    final int computedScore = max(
      0,
      100 + (matchedPairs * 50) - (mistakes * 10) - (hintCount * 5),
    );

    return MemoryMatchMetrics(
      difficulty: difficulty,
      totalPairs: difficulty.pairCount,
      matchedPairs: matchedPairs,
      totalAttempts: totalAttempts,
      mistakes: mistakes,
      hintCount: hintCount,
      accuracy: computedAccuracy,
      score: computedScore,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }
}

/// Factory utility to generate randomized card tiles for a session.
class MemoryCardGenerator {
  static List<MemoryCardTile> generateCards(
    MemoryMatchDifficulty difficulty, {
    Random? random,
  }) {
    final rng = random ?? Random();
    final allItems = List<MemoryMatchItemDefinition>.from(
      MemoryMatchCatalog.allItems,
    )..shuffle(rng);

    final selectedItems = allItems.take(difficulty.pairCount).toList();
    final List<MemoryCardTile> tiles = [];

    for (int i = 0; i < selectedItems.length; i++) {
      final item = selectedItems[i];
      // Create first card in pair
      tiles.add(
        MemoryCardTile(
          instanceId: '${item.key}_1',
          item: item,
        ),
      );
      // Create matching second card in pair
      tiles.add(
        MemoryCardTile(
          instanceId: '${item.key}_2',
          item: item,
        ),
      );
    }

    tiles.shuffle(rng);
    return tiles;
  }
}
