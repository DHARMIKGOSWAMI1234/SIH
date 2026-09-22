enum CognitiveGameType {
  memoryMatch,
  patternRecognition,
  dailyRoutineRecall,
}

extension CognitiveGameTypeExt on CognitiveGameType {
  String get displayName {
    switch (this) {
      case CognitiveGameType.memoryMatch:
        return 'Memory Match';
      case CognitiveGameType.patternRecognition:
        return 'Pattern Recall';
      case CognitiveGameType.dailyRoutineRecall:
        return 'Daily Routine Steps';
    }
  }

  String get code {
    switch (this) {
      case CognitiveGameType.memoryMatch:
        return 'memory_match';
      case CognitiveGameType.patternRecognition:
        return 'pattern_recognition';
      case CognitiveGameType.dailyRoutineRecall:
        return 'routine_recall';
    }
  }

  String get description {
    switch (this) {
      case CognitiveGameType.memoryMatch:
        return 'Match pairs of culturally familiar cards at a relaxed pace.';
      case CognitiveGameType.patternRecognition:
        return 'Observe gentle sequences and recall the order.';
      case CognitiveGameType.dailyRoutineRecall:
        return 'Place daily routine activities in comfortable chronological order.';
    }
  }
}

class GameCardItem {
  final String id;
  final String label;
  final String category;
  final String? assetPath;
  bool isFaceUp;
  bool isMatched;

  GameCardItem({
    required this.id,
    required this.label,
    required this.category,
    this.assetPath,
    this.isFaceUp = false,
    this.isMatched = false,
  });
}

class GameSessionResult {
  final CognitiveGameType gameType;
  final int score;
  final double accuracy;
  final int mistakes;
  final double responseTimeMs;
  final int difficulty;
  final int hintCount;
  final DateTime startedAt;
  final DateTime completedAt;

  const GameSessionResult({
    required this.gameType,
    required this.score,
    required this.accuracy,
    required this.mistakes,
    required this.responseTimeMs,
    required this.difficulty,
    required this.hintCount,
    required this.startedAt,
    required this.completedAt,
  });
}
