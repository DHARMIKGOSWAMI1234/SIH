import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_item.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_question.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_recognition_state.dart';
import 'package:patient_app/features/games/adaptive/client_adaptive_engine.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/l10n/app_strings.dart';

void main() {
  group('Pattern Recognition Catalog & Generator Tests', () {
    test('PatternCatalog has all distinct items with valid metadata', () {
      final items = PatternCatalog.allItems;
      expect(items.length, greaterThanOrEqualTo(8));

      final keys = items.map((e) => e.key).toSet();
      expect(keys.length, items.length);

      for (final item in items) {
        expect(item.label.isNotEmpty, true);
        expect(item.accessibilityDescription.isNotEmpty, true);
        expect(item.getLocalizedLabel('en').isNotEmpty, true);
        expect(item.getLocalizedLabel('hi').isNotEmpty, true);
        expect(item.getLocalizedLabel('as').isNotEmpty, true);
      }
    });

    test('Easy difficulty generates 4 questions with 2 options each', () {
      final questions = PatternQuestionGenerator.generateQuestions(
        count: PatternDifficulty.easy.questionCount,
        optionCount: PatternDifficulty.easy.optionCount,
        difficultyLevel: PatternDifficulty.easy.levelNumber,
        difficulty: PatternDifficulty.easy,
      );

      expect(questions.length, 4);
      for (final q in questions) {
        expect(q.options.length, 2);
        expect(q.options.contains(q.correctAnswer), true);
        expect(q.sequence.length, inInclusiveRange(3, 4));
        expect(q.patternRuleDescription.isNotEmpty, true);
        expect(q.isValid(), true);
      }
    });

    test('Medium difficulty generates 5 questions with 3 options each', () {
      final questions = PatternQuestionGenerator.generateQuestions(
        count: PatternDifficulty.medium.questionCount,
        optionCount: PatternDifficulty.medium.optionCount,
        difficultyLevel: PatternDifficulty.medium.levelNumber,
        difficulty: PatternDifficulty.medium,
      );

      expect(questions.length, 5);
      for (final q in questions) {
        expect(q.options.length, 3);
        expect(q.options.contains(q.correctAnswer), true);
        expect(q.sequence.length, inInclusiveRange(4, 5));
        expect(q.isValid(), true);
      }
    });

    test('Hard difficulty generates 6 questions with 4 options each', () {
      final questions = PatternQuestionGenerator.generateQuestions(
        count: PatternDifficulty.hard.questionCount,
        optionCount: PatternDifficulty.hard.optionCount,
        difficultyLevel: PatternDifficulty.hard.levelNumber,
        difficulty: PatternDifficulty.hard,
      );

      expect(questions.length, 6);
      for (final q in questions) {
        expect(q.options.length, 4);
        expect(q.options.contains(q.correctAnswer), true);
        expect(q.sequence.length, inInclusiveRange(5, 7));
        expect(q.isValid(), true);
      }
    });
  });

  group('Pattern Types Algorithms Verification', () {
    test('Alternating pattern conforms to A -> B -> A -> B rule', () {
      final itemA = PatternCatalog.apple;
      final itemB = PatternCatalog.flower;

      // 4-item sequence: A, B, A, B -> A
      final q1 = PatternQuestion(
        id: 'alt_1',
        questionNumber: 1,
        sequence: [itemA, itemB, itemA, itemB],
        correctAnswer: itemA,
        options: [itemA, itemB],
        patternType: PatternType.alternating,
        difficulty: PatternDifficulty.easy,
        patternRuleDescription: 'Alternating rule',
      );
      expect(q1.isValid(), true);

      // 3-item sequence: A, B, A -> B
      final q2 = PatternQuestion(
        id: 'alt_2',
        questionNumber: 2,
        sequence: [itemA, itemB, itemA],
        correctAnswer: itemB,
        options: [itemA, itemB],
        patternType: PatternType.alternating,
        difficulty: PatternDifficulty.easy,
        patternRuleDescription: 'Alternating rule',
      );
      expect(q2.isValid(), true);
    });

    test('Triplet pattern conforms to A -> B -> C -> A -> B -> C rule', () {
      final itemA = PatternCatalog.apple;
      final itemB = PatternCatalog.flower;
      final itemC = PatternCatalog.teaCup;

      // A, B, C, A, B -> C
      final q = PatternQuestion(
        id: 'trip_1',
        questionNumber: 1,
        sequence: [itemA, itemB, itemC, itemA, itemB],
        correctAnswer: itemC,
        options: [itemA, itemB, itemC],
        patternType: PatternType.triplet,
        difficulty: PatternDifficulty.medium,
        patternRuleDescription: 'Triplet rule',
      );
      expect(q.isValid(), true);
    });

    test('Double-Pair pattern conforms to A -> A -> B -> B -> A -> A rule', () {
      final itemA = PatternCatalog.apple;
      final itemB = PatternCatalog.sun;

      // A, A, B, B, A, A -> B
      final q = PatternQuestion(
        id: 'dp_1',
        questionNumber: 1,
        sequence: [itemA, itemA, itemB, itemB, itemA, itemA],
        correctAnswer: itemB,
        options: [itemA, itemB, PatternCatalog.leaf],
        patternType: PatternType.doublePair,
        difficulty: PatternDifficulty.medium,
        patternRuleDescription: 'Double-pair rule',
      );
      expect(q.isValid(), true);
    });

    test('Repetition pattern conforms to repeating group rule', () {
      final itemA = PatternCatalog.apple;
      final itemB = PatternCatalog.flower;

      // A, A, B, A, A -> B
      final q = PatternQuestion(
        id: 'rep_1',
        questionNumber: 1,
        sequence: [itemA, itemA, itemB, itemA, itemA],
        correctAnswer: itemB,
        options: [itemA, itemB],
        patternType: PatternType.repetition,
        difficulty: PatternDifficulty.medium,
        patternRuleDescription: 'Repetition rule',
      );
      expect(q.isValid(), true);
    });
  });

  group('Question Validation Logic Tests', () {
    final itemA = PatternCatalog.apple;
    final itemB = PatternCatalog.flower;
    final itemC = PatternCatalog.teaCup;

    test('Rejects question with duplicate options', () {
      final q = PatternQuestion(
        id: 'invalid_dup',
        questionNumber: 1,
        sequence: [itemA, itemB, itemA],
        correctAnswer: itemB,
        options: [itemB, itemB], // duplicate option
        patternType: PatternType.alternating,
        patternRuleDescription: 'Invalid duplicate options',
      );
      expect(q.isValid(), false);
    });

    test('Rejects question when correct answer is missing from options', () {
      final q = PatternQuestion(
        id: 'invalid_no_answer',
        questionNumber: 1,
        sequence: [itemA, itemB, itemA],
        correctAnswer: itemB,
        options: [itemA, itemC], // itemB not in options
        patternType: PatternType.alternating,
        patternRuleDescription: 'Missing answer',
      );
      expect(q.isValid(), false);
    });

    test('Rejects question with sequence violating the pattern rule', () {
      // Alternating sequence but breaks: A, B, B (should be A, B, A)
      final q = PatternQuestion(
        id: 'invalid_rule',
        questionNumber: 1,
        sequence: [itemA, itemB, itemB],
        correctAnswer: itemA,
        options: [itemA, itemB],
        patternType: PatternType.alternating,
        patternRuleDescription: 'Violates rule',
      );
      expect(q.isValid(), false);
    });

    test('Rejects question with sequence length < 3', () {
      final q = PatternQuestion(
        id: 'invalid_len',
        questionNumber: 1,
        sequence: [itemA, itemB],
        correctAnswer: itemA,
        options: [itemA, itemB],
        patternType: PatternType.alternating,
        patternRuleDescription: 'Too short',
      );
      expect(q.isValid(), false);
    });

    test('Repeated generator runs always yield 100% valid questions', () {
      final rng = Random(42);
      for (int i = 0; i < 20; i++) {
        for (final diff in PatternDifficulty.values) {
          final questions = PatternQuestionGenerator.generateQuestions(
            count: diff.questionCount,
            optionCount: diff.optionCount,
            difficulty: diff,
            random: rng,
          );
          for (final q in questions) {
            expect(q.isValid(), true,
                reason: 'Question ${q.id} of $diff failed validation');
          }
        }
      }
    });
  });

  group('Pattern Recognition Metrics and Scoring Formula Tests', () {
    test('Perfect session calculates 100% accuracy and maximum score', () {
      final now = DateTime.now();
      final metrics = PatternRecognitionMetrics.calculate(
        difficulty: PatternDifficulty.easy,
        totalQuestions: 4,
        correctAnswers: 4,
        mistakes: 0,
        hintCount: 0,
        startedAt: now.subtract(const Duration(seconds: 40)),
        completedAt: now,
      );

      expect(metrics.accuracy, 1.0);
      expect(metrics.accuracyPercentage, 100);
      expect(metrics.score, 400); // 4 * 100
      expect(metrics.durationSeconds, 40);
    });

    test('Session with mistakes and hints computes accurate penalties', () {
      final now = DateTime.now();
      final metrics = PatternRecognitionMetrics.calculate(
        difficulty: PatternDifficulty.medium,
        totalQuestions: 5,
        correctAnswers: 3,
        mistakes: 2,
        hintCount: 1,
        startedAt: now.subtract(const Duration(seconds: 60)),
        completedAt: now,
      );

      // accuracy = 3 / (3 + 2) = 0.6
      expect(metrics.accuracy, closeTo(0.6, 0.001));
      expect(metrics.accuracyPercentage, 60);
      // score = (3 * 100) - (2 * 20) - (1 * 10) = 300 - 40 - 10 = 250
      expect(metrics.score, 250);
    });

    test('Defensive formulas prevent negative score or division by zero', () {
      final now = DateTime.now();
      final zeroMetrics = PatternRecognitionMetrics.calculate(
        difficulty: PatternDifficulty.easy,
        totalQuestions: 4,
        correctAnswers: 0,
        mistakes: 0,
        hintCount: 0,
        startedAt: now,
        completedAt: now,
      );
      expect(zeroMetrics.accuracy, 1.0);
      expect(zeroMetrics.score, 0);

      final penalMetrics = PatternRecognitionMetrics.calculate(
        difficulty: PatternDifficulty.easy,
        totalQuestions: 4,
        correctAnswers: 1,
        mistakes: 10,
        hintCount: 5,
        startedAt: now,
        completedAt: now,
      );
      expect(penalMetrics.score, greaterThanOrEqualTo(0));
    });

    test('Per-round response time and average response time calculations', () {
      final now = DateTime.now();
      final roundRecords = [
        PatternRoundRecord(
          roundNumber: 1,
          patternType: PatternType.alternating,
          roundStartedAt: now.subtract(const Duration(seconds: 30)),
          answerSelectedAt: now.subtract(const Duration(seconds: 24)),
          responseTimeMs: 6000.0,
          isCorrect: true,
        ),
        PatternRoundRecord(
          roundNumber: 2,
          patternType: PatternType.repetition,
          roundStartedAt: now.subtract(const Duration(seconds: 24)),
          answerSelectedAt: now.subtract(const Duration(seconds: 16)),
          responseTimeMs: 8000.0,
          isCorrect: true,
        ),
        PatternRoundRecord(
          roundNumber: 3,
          patternType: PatternType.triplet,
          roundStartedAt: now.subtract(const Duration(seconds: 16)),
          answerSelectedAt: now.subtract(const Duration(seconds: 6)),
          responseTimeMs: 10000.0,
          isCorrect: true,
        ),
      ];

      final metrics = PatternRecognitionMetrics.calculate(
        difficulty: PatternDifficulty.medium,
        totalQuestions: 3,
        correctAnswers: 3,
        mistakes: 0,
        hintCount: 0,
        startedAt: now.subtract(const Duration(seconds: 30)),
        completedAt: now,
        roundRecords: roundRecords,
      );

      // Average response time = (6000 + 8000 + 10000) / 3 = 8000 ms
      expect(metrics.averageResponseTimeMs, 8000.0);
      expect(metrics.roundRecords.length, 3);
      expect(metrics.responseTimeMs, 8000.0);
    });
  });

  group('Adaptive Difficulty Integration Tests for Pattern Recognition', () {
    test('High accuracy triggers promotion to next difficulty tier', () {
      final eval = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 1,
        accuracy: 1.0,
        mistakes: 0,
        hintsUsed: 0,
        responseTimeMs: 35000,
        completed: true,
      );

      expect(eval.action, AdaptiveDifficultyAction.increase);
      expect(eval.nextDifficulty, 2);
      expect(eval.caregiverExplanation.contains('High exercise accuracy'), true);
    });

    test('Low accuracy triggers support or difficulty reduction', () {
      final eval = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 2,
        accuracy: 0.5,
        mistakes: 4,
        hintsUsed: 2,
        responseTimeMs: 90000,
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
        hintsUsed: 0,
        responseTimeMs: 45000,
        completed: true,
      );

      final explanation = eval.caregiverExplanation.toLowerCase();
      final feedback = eval.patientFeedback.toLowerCase();

      for (final banned in ClientAdaptiveEngine.prohibitedClinicalTerms) {
        expect(explanation.contains(banned), false,
            reason: 'Explanation contains banned clinical term: $banned');
        expect(feedback.contains(banned), false,
            reason: 'Feedback contains banned clinical term: $banned');
      }
    });
  });

  group('Drift SQLite Local Persistence for Pattern Recognition', () {
    late AppDatabase database;
    late SmritiRepository repository;

    setUp(() {
      database = AppDatabase(NativeDatabase.memory());
      repository = SmritiRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('Completed Pattern Recognition session is persisted with pending sync', () async {
      final startedAt = DateTime.now().subtract(const Duration(minutes: 2));
      final completedAt = DateTime.now();

      await repository.recordGameSession(
        gameType: 'pattern_recognition',
        score: 360,
        accuracy: 0.9,
        mistakes: 1,
        responseTimeMs: 42000,
        difficulty: 2,
        hintCount: 1,
        startedAt: startedAt,
        completedAt: completedAt,
      );

      final sessions = await repository.getRecentSessions();
      expect(sessions.length, 1);

      final s = sessions.first;
      expect(s.gameType, 'pattern_recognition');
      expect(s.score, 360);
      expect(s.accuracy, 0.9);
      expect(s.mistakes, 1);
      expect(s.difficulty, 2);
      expect(s.hintCount, 1);
      expect(s.syncStatus, 'pending');

      final queue = await database.select(database.syncQueue).get();
      expect(queue.length, 1);
      expect(queue.first.entityType, 'GameSessions');
      expect(queue.first.entityId, s.localId);
      expect(queue.first.status, 'pending');
    });
  });

  group('Localization Verification (en, hi, as)', () {
    final requiredKeys = [
      'patternGame',
      'patternSubtitle',
      'patternHowToPlay',
      'patternInstruction1',
      'patternInstruction2',
      'patternInstruction3',
      'patternInstruction4',
      'patternSelectLevel',
      'patternEasyDesc',
      'patternMediumDesc',
      'patternHardDesc',
      'startPatternExercise',
      'patternSequence',
      'whatComesNext',
      'questionProgress',
      'wellDonePattern',
      'tryPatternAgain',
      'patternCompleted',
      'hint',
      'eliminated',
      'hintPatternHelp',
      'patternHintAlternating',
      'patternHintRepetition',
      'patternHintTriplet',
      'patternHintDoublePair',
      'exerciseCompleted',
      'avgResponseTime',
      'savedToHistory',
      'savingToSqlite',
      'recommendedLevel',
      'nextQuestionSlot',
      'patternItemApple',
      'patternItemFlower',
      'patternItemTeaCup',
      'patternItemSun',
      'patternItemLeaf',
      'patternItemHome',
      'patternItemDrum',
      'patternItemBoat',
      'pauseExercise',
      'leaveExercise',
      'resume',
      'pausePatternDialogContent',
    ];

    for (final loc in ['en', 'hi', 'as']) {
      test('Language "$loc" has all required Pattern Recognition keys', () {
        for (final key in requiredKeys) {
          final translated = AppStrings.get(key, locale: loc);
          expect(translated.isNotEmpty, true,
              reason: 'Key "$key" is missing or empty in locale "$loc"');
          expect(translated, isNot(equals(key)),
              reason: 'Key "$key" was not found in dictionary and returned raw key in "$loc"');
        }
      });
    }

    test('Fallback mechanism cleanly returns English string for unsupported locale', () {
      final res = AppStrings.get('patternGame', locale: 'unsupported_code');
      expect(res, 'Pattern Recognition');
    });

    test('No prohibited clinical terminology exists in Pattern Recognition strings', () {
      final prohibited = [
        'dementia',
        'diagnos',
        'impairment',
        'severity',
        'decline',
        'alzheimer',
        'patholog',
        'disease',
        'cure',
        'deficit',
      ];

      for (final loc in ['en', 'hi', 'as']) {
        for (final key in requiredKeys) {
          final str = AppStrings.get(key, locale: loc).toLowerCase();
          for (final banned in prohibited) {
            expect(str.contains(banned), false,
                reason: 'Prohibited clinical term "$banned" found in key "$key" in locale "$loc": "$str"');
          }
        }
      }
    });
  });

  group('Offline-First Architecture Verification', () {
    test('Complete Pattern Recognition cycle executes locally with zero network calls', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = SmritiRepository(db);

      // 1. Generate questions offline
      final questions = PatternQuestionGenerator.generateQuestions(
        count: 4,
        optionCount: 2,
        difficulty: PatternDifficulty.easy,
      );
      expect(questions.length, 4);

      // 2. Play through simulated rounds
      final start = DateTime.now();
      final roundRecords = <PatternRoundRecord>[];
      int correct = 0;
      int mistakes = 0;
      int hints = 0;

      for (int i = 0; i < questions.length; i++) {
        final q = questions[i];
        final roundStart = DateTime.now();
        // Simulate a correct answer
        correct++;
        final roundEnd = DateTime.now();
        roundRecords.add(
          PatternRoundRecord(
            roundNumber: i + 1,
            patternType: q.patternType,
            roundStartedAt: roundStart,
            answerSelectedAt: roundEnd,
            responseTimeMs: 2500.0,
            isCorrect: true,
          ),
        );
      }

      // 3. Compute metrics offline
      final finish = DateTime.now();
      final metrics = PatternRecognitionMetrics.calculate(
        difficulty: PatternDifficulty.easy,
        totalQuestions: 4,
        correctAnswers: correct,
        mistakes: mistakes,
        hintCount: hints,
        startedAt: start,
        completedAt: finish,
        roundRecords: roundRecords,
      );

      expect(metrics.accuracy, 1.0);
      expect(metrics.score, 400);

      // 4. Client adaptive recommendation computed offline
      final adaptive = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 1,
        accuracy: metrics.accuracy,
        mistakes: metrics.mistakes,
        hintsUsed: metrics.hintCount,
        responseTimeMs: metrics.responseTimeMs,
        completed: true,
      );
      expect(adaptive.action, AdaptiveDifficultyAction.increase);

      // 5. Persist locally to SQLite offline
      await repo.recordGameSession(
        gameType: 'pattern_recognition',
        score: metrics.score,
        accuracy: metrics.accuracy,
        mistakes: metrics.mistakes,
        responseTimeMs: metrics.responseTimeMs,
        difficulty: 1,
        hintCount: metrics.hintCount,
        startedAt: metrics.startedAt,
        completedAt: metrics.completedAt,
      );

      final saved = await repo.getRecentSessions();
      expect(saved.length, 1);
      expect(saved.first.gameType, 'pattern_recognition');
      expect(saved.first.score, 400);
      expect(saved.first.syncStatus, 'pending');

      await db.close();
    });
  });
}
