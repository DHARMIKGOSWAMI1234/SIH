import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/games/models/game_context.dart';
import 'package:patient_app/features/games/models/game_model.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_question.dart';

void main() {
  group('GameContext and Hint Models Tests', () {
    test('MemoryMatchGameHint produces exact gentle text without face-up card', () {
      const hint = MemoryMatchGameHint(
        card1Row: 2,
        card1Col: 3,
        card1Label: 'Mango',
        card2Row: 1,
        card2Col: 2,
        card2Label: 'Mango',
        hasFaceUpCard: false,
      );

      expect(hint.card1Row, 2);
      expect(hint.card1Col, 3);
      final text = hint.toGentleHintText();
      expect(text, contains('Row 2, Column 3'));
    });

    test('MemoryMatchGameHint produces exact gentle text with face-up card', () {
      const hint = MemoryMatchGameHint(
        card1Row: 1,
        card1Col: 1,
        card1Label: 'Clay Tea Cup',
        card2Row: 2,
        card2Col: 3,
        card2Label: 'Clay Tea Cup',
        hasFaceUpCard: true,
        faceUpRow: 1,
        faceUpCol: 1,
        faceUpLabel: 'Clay Tea Cup',
        targetMatchingRow: 2,
        targetMatchingCol: 3,
      );

      final text = hint.toGentleHintText();
      expect(text, contains('Clay Tea Cup'));
      expect(text, contains('Row 2, Column 3'));
    });

    test('PatternGameHint provides pattern rule guidance without fabricating answers', () {
      const hint = PatternGameHint(
        patternType: PatternType.alternating,
        patternRuleDescription: 'Alternates between Marigold and Diya',
        sequenceSummary: 'Marigold, Diya, Marigold, Diya',
      );

      final text = hint.toGentleHintText();
      expect(text, contains('alternate in turns'));
      expect(text, contains('Marigold, Diya, Marigold, Diya'));
    });

    test('RoutineRecallGameHint provides sequencing guidance based on placed steps', () {
      const initialHint = RoutineRecallGameHint(
        routineCategory: 'Daily Activities',
        routineTitle: 'Morning Tea',
        totalSteps: 3,
        currentPlacedSteps: 0,
      );
      expect(initialHint.toGentleHintText(), contains('Morning Tea'));
      expect(initialHint.toGentleHintText(), contains('what you typically do first'));

      const progressedHint = RoutineRecallGameHint(
        routineCategory: 'Daily Activities',
        routineTitle: 'Morning Tea',
        totalSteps: 3,
        currentPlacedSteps: 1,
        placedStepLabels: ['Boil water in kettle'],
        lastPlacedStepLabel: 'Boil water in kettle',
      );
      expect(progressedHint.toGentleHintText(), contains('Boil water in kettle'));
      expect(progressedHint.toGentleHintText(), contains('what naturally follows next'));
    });

    test('GameContext serializes toMap correctly and handles progress titles', () {
      final ctx = GameContext(
        gameType: CognitiveGameType.memoryMatch,
        gamePhase: 'playing',
        difficulty: 1,
        score: 20,
        mistakes: 1,
        hintsUsed: 1,
        progress: 0.5,
        isActive: true,
        isComplete: false,
      );

      expect(ctx.gameTitle, 'Memory Match');
      expect(ctx.progressDescription, contains('50% pairs found'));

      final map = ctx.toMap();
      expect(map['gameType'], 'memory_match');
      expect(map['score'], 20);
      expect(map['mistakes'], 1);
      expect(map['progress'], 0.5);
    });
  });
}
