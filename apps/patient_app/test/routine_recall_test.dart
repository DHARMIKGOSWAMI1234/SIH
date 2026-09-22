import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:patient_app/features/games/daily_routine_recall/models/routine_item.dart';
import 'package:patient_app/features/games/daily_routine_recall/models/routine_question.dart';
import 'package:patient_app/features/games/daily_routine_recall/models/routine_recall_state.dart';
import 'package:patient_app/features/games/adaptive/client_adaptive_engine.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';

void main() {
  group('Daily Routine Recall Catalog & Visual Resolver Tests', () {
    test('RoutineCatalog has distinct items with valid metadata', () {
      final items = RoutineCatalog.standardDailyItems;
      expect(items.length, greaterThanOrEqualTo(10));

      final keys = items.map((e) => e.key).toSet();
      expect(keys.length, items.length);

      for (final item in items) {
        expect(item.defaultLabel.isNotEmpty, true);
        expect(item.accessibilityDescription.isNotEmpty, true);
        expect(item.iconIdentifier.isNotEmpty, true);
        expect(item.colorIdentifier.isNotEmpty, true);
        expect(item.chronologicalOrder, greaterThan(0));
        expect(item.isDistractor, false);

        // Visual resolver validity
        final icon = RoutineVisualResolver.getIcon(item.iconIdentifier);
        final color = RoutineVisualResolver.getColor(item.colorIdentifier);
        expect(icon, isNotNull);
        expect(color, isNotNull);
      }
    });

    test('Scheduled Medicine item satisfies strict clinical safety boundary', () {
      final med = RoutineCatalog.scheduledMedicine;
      expect(med.key, 'scheduled_medicine');
      expect(med.defaultLabel, 'Scheduled Medicine');
      // Must not contain prescription or dosage keywords
      expect(med.defaultLabel.toLowerCase().contains('mg'), false);
      expect(med.defaultLabel.toLowerCase().contains('dose'), false);
      expect(med.defaultLabel.toLowerCase().contains('prescribe'), false);
      expect(med.accessibilityDescription.contains('caregiver'), true);
    });

    test('Distractors are properly flagged with distinct identifiers', () {
      final distractors = RoutineCatalog.distractors;
      expect(distractors.length, greaterThanOrEqualTo(3));
      for (final d in distractors) {
        expect(d.isDistractor, true);
        expect(d.timeCategory, RoutineTimeCategory.distractor);
      }
    });

    test('RoutineCatalog.getByKey retrieves matching item or default', () {
      final tea = RoutineCatalog.getByKey('morning_tea');
      expect(tea.key, 'morning_tea');
      expect(tea.chronologicalOrder, 3);

      final snack = RoutineCatalog.getByKey('midnight_snack');
      expect(snack.key, 'midnight_snack');
      expect(snack.isDistractor, true);

      final unknown = RoutineCatalog.getByKey('unknown_nonexistent');
      expect(unknown.key, RoutineCatalog.wakeUp.key);
    });
  });

  group('Daily Routine Recall Question Generator Tests', () {
    test('Easy difficulty generates 3 questions with 3 steps each', () {
      final questions = RoutineQuestionGenerator.generateQuestions(
        count: RoutineRecallDifficulty.easy.questionCount,
        difficultyLevel: RoutineRecallDifficulty.easy.levelNumber,
      );

      expect(questions.length, 3);
      for (final q in questions) {
        expect(q.correctSequence.length, 3);
        expect(q.availableOptions.length, inInclusiveRange(3, 4));
        expect(q.title.isNotEmpty, true);
        expect(q.scenarioDescription.isNotEmpty, true);

        // Verify chronological ordering of correct sequence
        for (int i = 0; i < q.correctSequence.length - 1; i++) {
          expect(
            q.correctSequence[i].chronologicalOrder,
            lessThan(q.correctSequence[i + 1].chronologicalOrder),
            reason: 'Sequence steps must be chronologically ordered',
          );
        }

        // Available options must contain all correct sequence items
        for (final item in q.correctSequence) {
          expect(q.availableOptions.contains(item), true);
        }
      }
    });

    test('Medium difficulty generates 4 questions with 4 steps each', () {
      final questions = RoutineQuestionGenerator.generateQuestions(
        count: RoutineRecallDifficulty.medium.questionCount,
        difficultyLevel: RoutineRecallDifficulty.medium.levelNumber,
      );

      expect(questions.length, 4);
      for (final q in questions) {
        expect(q.correctSequence.length, 4);
        expect(q.availableOptions.length, 5);
        expect(q.distractors.length, 1);

        // Verify chronological ordering
        for (int i = 0; i < q.correctSequence.length - 1; i++) {
          expect(
            q.correctSequence[i].chronologicalOrder,
            lessThan(q.correctSequence[i + 1].chronologicalOrder),
          );
        }
      }
    });

    test('Hard difficulty generates 5 questions with 5 steps and 2 distractors', () {
      final questions = RoutineQuestionGenerator.generateQuestions(
        count: RoutineRecallDifficulty.hard.questionCount,
        difficultyLevel: RoutineRecallDifficulty.hard.levelNumber,
      );

      expect(questions.length, 5);
      for (final q in questions) {
        expect(q.correctSequence.length, 5);
        expect(q.availableOptions.length, 7);
        expect(q.distractors.length, 2);

        // Verify chronological ordering
        for (int i = 0; i < q.correctSequence.length - 1; i++) {
          expect(
            q.correctSequence[i].chronologicalOrder,
            lessThan(q.correctSequence[i + 1].chronologicalOrder),
          );
        }
      }
    });
  });

  group('Daily Routine Recall Metrics & Deterministic Scoring Tests', () {
    test('Perfect session calculates 100% accuracy and expected score', () {
      final now = DateTime.now();
      final metrics = RoutineRecallMetrics.calculate(
        difficulty: RoutineRecallDifficulty.easy,
        totalQuestions: 3,
        correctAnswers: 3,
        mistakes: 0,
        hintCount: 0,
        startedAt: now.subtract(const Duration(seconds: 45)),
        completedAt: now,
      );

      expect(metrics.accuracy, 1.0);
      expect(metrics.accuracyPercentage, 100);
      expect(metrics.score, 300); // 3 * 100
      expect(metrics.durationSeconds, 45);
    });

    test('Session with mistakes and hints applies deterministic deductions', () {
      final now = DateTime.now();
      final metrics = RoutineRecallMetrics.calculate(
        difficulty: RoutineRecallDifficulty.medium,
        totalQuestions: 4,
        correctAnswers: 3,
        mistakes: 1,
        hintCount: 2,
        startedAt: now.subtract(const Duration(seconds: 60)),
        completedAt: now,
      );

      // accuracy = 3 / (3 + 1) = 0.75
      expect(metrics.accuracy, closeTo(0.75, 0.001));
      expect(metrics.accuracyPercentage, 75);
      // score = (3 * 100) - (1 * 20) - (2 * 10) = 300 - 20 - 20 = 260
      expect(metrics.score, 260);
    });

    test('Defensive formulas prevent negative score or division by zero', () {
      final now = DateTime.now();
      final zeroMetrics = RoutineRecallMetrics.calculate(
        difficulty: RoutineRecallDifficulty.easy,
        totalQuestions: 3,
        correctAnswers: 0,
        mistakes: 0,
        hintCount: 0,
        startedAt: now,
        completedAt: now,
      );
      expect(zeroMetrics.accuracy, 1.0);
      expect(zeroMetrics.score, 0);

      final penaltyMetrics = RoutineRecallMetrics.calculate(
        difficulty: RoutineRecallDifficulty.easy,
        totalQuestions: 3,
        correctAnswers: 1,
        mistakes: 10,
        hintCount: 5,
        startedAt: now,
        completedAt: now,
      );
      expect(penaltyMetrics.score, greaterThanOrEqualTo(0));
    });
  });

  group('Adaptive Difficulty Integration Tests for Daily Routine Recall', () {
    test('High accuracy triggers promotion to next difficulty level', () {
      final eval = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 1,
        accuracy: 1.0,
        mistakes: 0,
        hintsUsed: 0,
        responseTimeMs: 38000,
        completed: true,
      );

      expect(eval.action, AdaptiveDifficultyAction.increase);
      expect(eval.nextDifficulty, 2);
      expect(eval.caregiverExplanation.contains('High exercise accuracy'), true);
    });

    test('Low accuracy triggers support and gentler activity recommendation', () {
      final eval = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 2,
        accuracy: 0.5,
        mistakes: 4,
        hintsUsed: 2,
        responseTimeMs: 95000,
        completed: true,
      );

      expect(eval.action, AdaptiveDifficultyAction.decrease);
      expect(eval.nextDifficulty, 1);
      expect(eval.supportTriggers.containsKey('extra_hints'), true);
    });

    test('Non-clinical boundary rules are strictly enforced', () {
      final eval = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 2,
        accuracy: 0.75,
        mistakes: 1,
        hintsUsed: 1,
        responseTimeMs: 50000,
        completed: true,
      );

      final explanation = eval.caregiverExplanation.toLowerCase();
      final feedback = eval.patientFeedback.toLowerCase();

      for (final banned in ClientAdaptiveEngine.prohibitedClinicalTerms) {
        expect(explanation.contains(banned), false,
            reason: 'Banned clinical term found: $banned');
        expect(feedback.contains(banned), false,
            reason: 'Banned clinical term found: $banned');
      }
    });
  });

  group('Drift SQLite Local Persistence for Daily Routine Recall', () {
    late AppDatabase database;
    late SmritiRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = SmritiRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('Completed Daily Routine Recall session is persisted with pending sync', () async {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 2));
      final completedAt = DateTime.now();

      await repository.recordGameSession(
        gameType: 'routine_recall',
        score: 300,
        accuracy: 1.0,
        mistakes: 0,
        responseTimeMs: 40000,
        difficulty: 1,
        hintCount: 0,
        startedAt: startedAt,
        completedAt: completedAt,
      );

      final sessions = await repository.getRecentSessions();
      expect(sessions.length, 1);

      final s = sessions.first;
      expect(s.gameType, 'routine_recall');
      expect(s.score, 300);
      expect(s.accuracy, 1.0);
      expect(s.mistakes, 0);
      expect(s.difficulty, 1);
      expect(s.hintCount, 0);
      expect(s.syncStatus, 'pending');

      final queue = await database.select(database.syncQueue).get();
      expect(queue.length, 1);
      expect(queue.first.entityType, 'GameSessions');
      expect(queue.first.entityId, s.localId);
      expect(queue.first.status, 'pending');
    });
  });
}
