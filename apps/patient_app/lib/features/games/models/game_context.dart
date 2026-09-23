import '../models/game_model.dart';
import '../pattern_recognition/models/pattern_question.dart';

/// Hint derived strictly from real active Memory Match card layout.
class MemoryMatchGameHint {
  final int card1Row;
  final int card1Col;
  final String card1Label;
  final int card2Row;
  final int card2Col;
  final String card2Label;
  final bool hasFaceUpCard;
  final int? faceUpRow;
  final int? faceUpCol;
  final String? faceUpLabel;
  final int? targetMatchingRow;
  final int? targetMatchingCol;

  const MemoryMatchGameHint({
    required this.card1Row,
    required this.card1Col,
    required this.card1Label,
    required this.card2Row,
    required this.card2Col,
    required this.card2Label,
    this.hasFaceUpCard = false,
    this.faceUpRow,
    this.faceUpCol,
    this.faceUpLabel,
    this.targetMatchingRow,
    this.targetMatchingCol,
  });

  /// Builds gentle, board-derived hint text without revealing the whole board.
  String toGentleHintText() {
    if (hasFaceUpCard && targetMatchingRow != null && targetMatchingCol != null) {
      final label = faceUpLabel ?? 'card';
      return 'You opened "$label". Look around Row $targetMatchingRow, Column $targetMatchingCol for its matching twin.';
    }
    return 'Look around Row $card1Row, Column $card1Col to find a matching card.';
  }
}

/// Hint derived strictly from real active Pattern Recognition sequence.
class PatternGameHint {
  final PatternType patternType;
  final String patternRuleDescription;
  final String sequenceSummary;
  final String? questionPrompt;

  const PatternGameHint({
    required this.patternType,
    required this.patternRuleDescription,
    required this.sequenceSummary,
    this.questionPrompt,
  });

  /// Builds gentle pattern structure guidance without fabricating answers.
  String toGentleHintText() {
    switch (patternType) {
      case PatternType.alternating:
        return 'Look at how the items alternate in turns ($sequenceSummary). Notice which item should come next in the rhythm.';
      case PatternType.repetition:
        return 'Notice how items repeat in steady groups. Follow the repeating cycle.';
      case PatternType.triplet:
        return 'Notice the three items repeating in order. Think about the third step in the cycle.';
      case PatternType.doublePair:
        return 'Notice the pairs of matching items taking turns. Look at which pair comes next.';
    }
  }
}

/// Hint derived strictly from real active Daily Routine Recall sequence.
class RoutineRecallGameHint {
  final String routineCategory;
  final String routineTitle;
  final int totalSteps;
  final int currentPlacedSteps;
  final List<String> placedStepLabels;
  final String? lastPlacedStepLabel;

  const RoutineRecallGameHint({
    required this.routineCategory,
    required this.routineTitle,
    required this.totalSteps,
    required this.currentPlacedSteps,
    this.placedStepLabels = const [],
    this.lastPlacedStepLabel,
  });

  /// Builds supportive routine sequencing guidance.
  String toGentleHintText() {
    if (currentPlacedSteps == 0) {
      return 'Think about what you typically do first during your $routineTitle.';
    }
    if (lastPlacedStepLabel != null && lastPlacedStepLabel!.isNotEmpty) {
      return 'You placed "$lastPlacedStepLabel". Think about what naturally follows next in your routine.';
    }
    return 'You have placed $currentPlacedSteps of $totalSteps steps. Take your time arranging the next step.';
  }
}

/// Reusable domain model capturing live game state for the BANDHU Help Assistant.
/// Strictly non-clinical, non-diagnostic, and populated only with genuine values.
class GameContext {
  final CognitiveGameType gameType;
  final String gamePhase; // e.g. 'playing', 'checking', 'arranging', 'completed'
  final int difficulty; // 1, 2, 3
  final int score;
  final int mistakes;
  final int hintsUsed;
  final Duration elapsedTime;
  final double progress; // 0.0 to 1.0
  final bool isActive;
  final bool isComplete;
  final int availableHints;

  // Specific genuine hint payloads (derived from live board state)
  final MemoryMatchGameHint? memoryMatchHint;
  final PatternGameHint? patternHint;
  final RoutineRecallGameHint? routineHint;

  const GameContext({
    required this.gameType,
    required this.gamePhase,
    required this.difficulty,
    this.score = 0,
    this.mistakes = 0,
    this.hintsUsed = 0,
    this.elapsedTime = Duration.zero,
    this.progress = 0.0,
    this.isActive = true,
    this.isComplete = false,
    this.availableHints = 1,
    this.memoryMatchHint,
    this.patternHint,
    this.routineHint,
  });

  /// Human-friendly display title for the active game.
  String get gameTitle {
    switch (gameType) {
      case CognitiveGameType.memoryMatch:
        return 'Memory Match';
      case CognitiveGameType.patternRecognition:
        return 'Pattern Recognition';
      case CognitiveGameType.dailyRoutineRecall:
        return 'Daily Routine Recall';
    }
  }

  /// Human-friendly summary of the current gameplay progress.
  String get progressDescription {
    if (isComplete) return 'Completed';
    switch (gameType) {
      case CognitiveGameType.memoryMatch:
        final percentage = (progress * 100).round();
        return 'Level $difficulty • $percentage% pairs found';
      case CognitiveGameType.patternRecognition:
        final percentage = (progress * 100).round();
        return 'Round progress • $percentage% complete';
      case CognitiveGameType.dailyRoutineRecall:
        final percentage = (progress * 100).round();
        return 'Routine sequence • $percentage% placed';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'gameType': gameType.code,
      'gamePhase': gamePhase,
      'difficulty': difficulty,
      'score': score,
      'mistakes': mistakes,
      'hintsUsed': hintsUsed,
      'elapsedSeconds': elapsedTime.inSeconds,
      'progress': progress,
      'isActive': isActive,
      'isComplete': isComplete,
      'availableHints': availableHints,
      'hasMemoryMatchHint': memoryMatchHint != null,
      'hasPatternHint': patternHint != null,
      'hasRoutineHint': routineHint != null,
    };
  }
}
