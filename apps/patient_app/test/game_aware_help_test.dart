import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/games/models/game_context.dart';
import 'package:patient_app/features/games/models/game_model.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_question.dart';
import 'package:patient_app/features/help/models/help_context.dart';
import 'package:patient_app/features/help/models/help_request.dart';
import 'package:patient_app/features/help/models/help_screen_id.dart';
import 'package:patient_app/features/help/services/help_context_service.dart';
import 'package:patient_app/features/help/services/local_help_engine.dart';
import 'package:patient_app/features/help/widgets/gentle_help_prompt.dart';

void main() {
  group('Game-Aware Contextual Help Tests', () {
    const engine = LocalHelpEngine();

    test('LocalHelpEngine returns real board hint when MemoryMatchGameHint is available', () async {
      const hint = MemoryMatchGameHint(
        card1Row: 1,
        card1Col: 2,
        card1Label: 'Clay Tea Cup',
        card2Row: 2,
        card2Col: 3,
        card2Label: 'Clay Tea Cup',
        hasFaceUpCard: true,
        faceUpRow: 1,
        faceUpCol: 2,
        faceUpLabel: 'Clay Tea Cup',
        targetMatchingRow: 2,
        targetMatchingCol: 3,
      );

      final gameCtx = GameContext(
        gameType: CognitiveGameType.memoryMatch,
        gamePhase: 'playing',
        difficulty: 1,
        memoryMatchHint: hint,
      );

      final helpCtx = HelpContext.fromScreenId(
        HelpScreenId.memoryMatch,
        gameContext: gameCtx,
      );

      final response = await engine.getHelp(
        helpCtx,
        HelpRequest.action(HelpActionType.hint),
      );

      expect(response.message, contains('Clay Tea Cup'));
      expect(response.message, contains('Row 2, Column 3'));
      expect(response.isOffline, isTrue);
    });

    test('LocalHelpEngine returns pattern rhythm guidance when PatternGameHint is available', () async {
      const hint = PatternGameHint(
        patternType: PatternType.alternating,
        patternRuleDescription: 'Alternating sequence of Diya and Lotus',
        sequenceSummary: 'Diya, Lotus, Diya, Lotus',
      );

      final gameCtx = GameContext(
        gameType: CognitiveGameType.patternRecognition,
        gamePhase: 'playing',
        difficulty: 1,
        patternHint: hint,
      );

      final helpCtx = HelpContext.fromScreenId(
        HelpScreenId.patternRecognition,
        gameContext: gameCtx,
      );

      final response = await engine.getHelp(
        helpCtx,
        HelpRequest.action(HelpActionType.hint),
      );

      expect(response.message, contains('alternate in turns'));
      expect(response.message, contains('Diya, Lotus, Diya, Lotus'));
    });

    test('LocalHelpEngine returns sequence guidance when RoutineRecallGameHint is available', () async {
      const hint = RoutineRecallGameHint(
        routineCategory: 'Daily Activities',
        routineTitle: 'Morning Walk',
        totalSteps: 3,
        currentPlacedSteps: 1,
        lastPlacedStepLabel: 'Put on walking shoes',
      );

      final gameCtx = GameContext(
        gameType: CognitiveGameType.dailyRoutineRecall,
        gamePhase: 'arranging',
        difficulty: 1,
        routineHint: hint,
      );

      final helpCtx = HelpContext.fromScreenId(
        HelpScreenId.routine,
        gameContext: gameCtx,
      );

      final response = await engine.getHelp(
        helpCtx,
        HelpRequest.action(HelpActionType.hint),
      );

      expect(response.message, contains('Put on walking shoes'));
      expect(response.message, contains('what naturally follows next'));
    });

    test('HelpContextService correctly stores and updates gameContext', () {
      final service = HelpContextService.instance;
      final gameCtx = GameContext(
        gameType: CognitiveGameType.memoryMatch,
        gamePhase: 'playing',
        difficulty: 2,
        mistakes: 3,
        hintsUsed: 1,
      );

      service.updateGameContext(gameCtx);
      expect(service.currentContext.gameContext, isNotNull);
      expect(service.currentContext.difficulty, 2);
      expect(service.currentContext.mistakes, 3);
    });

    testWidgets('GentleHelpPrompt renders supportive text and handles button taps', (tester) async {
      bool helpTapped = false;
      bool notNowTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GentleHelpPrompt(
              onHelpMe: () => helpTapped = true,
              onNotNow: () => notNowTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Need a little help?'), findsOneWidget);
      expect(find.text('Help me'), findsOneWidget);
      expect(find.text('Not now'), findsOneWidget);

      await tester.tap(find.text('Help me'));
      await tester.pumpAndSettle();
      expect(helpTapped, isTrue);

      await tester.tap(find.text('Not now'));
      await tester.pumpAndSettle();
      expect(notNowTapped, isTrue);
    });
  });
}
