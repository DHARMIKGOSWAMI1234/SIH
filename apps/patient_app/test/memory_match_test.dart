import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:patient_app/features/games/memory_match/models/memory_match_state.dart';
import 'package:patient_app/features/games/adaptive/client_adaptive_engine.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';

void main() {
  group('Memory Match Card Generator Tests', () {
    test('Easy difficulty generates exactly 6 cards (3 matching pairs)', () {
      final cards = MemoryCardGenerator.generateCards(MemoryMatchDifficulty.easy);
      expect(cards.length, 6);

      // Verify every item key appears exactly twice
      final keyCounts = <String, int>{};
      for (final c in cards) {
        keyCounts[c.item.key] = (keyCounts[c.item.key] ?? 0) + 1;
      }
      expect(keyCounts.keys.length, 3);
      for (final count in keyCounts.values) {
        expect(count, 2);
      }
    });

    test('Medium difficulty generates exactly 8 cards (4 matching pairs)', () {
      final cards = MemoryCardGenerator.generateCards(MemoryMatchDifficulty.medium);
      expect(cards.length, 8);

      final keyCounts = <String, int>{};
      for (final c in cards) {
        keyCounts[c.item.key] = (keyCounts[c.item.key] ?? 0) + 1;
      }
      expect(keyCounts.keys.length, 4);
      for (final count in keyCounts.values) {
        expect(count, 2);
      }
    });

    test('Hard difficulty generates exactly 12 cards (6 matching pairs)', () {
      final cards = MemoryCardGenerator.generateCards(MemoryMatchDifficulty.hard);
      expect(cards.length, 12);

      final keyCounts = <String, int>{};
      for (final c in cards) {
        keyCounts[c.item.key] = (keyCounts[c.item.key] ?? 0) + 1;
      }
      expect(keyCounts.keys.length, 6);
      for (final count in keyCounts.values) {
        expect(count, 2);
      }
    });
  });

  group('Memory Match Metrics and Scoring Formula Tests', () {
    test('Perfect 3-pair session yields 100% accuracy and positive score', () {
      final now = DateTime.now();
      final metrics = MemoryMatchMetrics.calculate(
        difficulty: MemoryMatchDifficulty.easy,
        matchedPairs: 3,
        totalAttempts: 3,
        mistakes: 0,
        hintCount: 0,
        startedAt: now.subtract(const Duration(seconds: 45)),
        completedAt: now,
      );

      expect(metrics.accuracy, 1.0);
      expect(metrics.accuracyPercentage, 100);
      expect(metrics.mistakes, 0);
      expect(metrics.score, 100 + (3 * 50)); // 250
      expect(metrics.durationSeconds, 45);
    });

    test('Session with 3 mistakes computes correct accuracy and deduction', () {
      final now = DateTime.now();
      final metrics = MemoryMatchMetrics.calculate(
        difficulty: MemoryMatchDifficulty.easy,
        matchedPairs: 3,
        totalAttempts: 6,
        mistakes: 3,
        hintCount: 1,
        startedAt: now.subtract(const Duration(seconds: 90)),
        completedAt: now,
      );

      // accuracy = 3 / 6 = 0.5 (50%)
      expect(metrics.accuracy, 0.5);
      expect(metrics.accuracyPercentage, 50);
      // score: 100 + 150 - 30 - 5 = 215
      expect(metrics.score, 215);
    });

    test('Zero attempts guard avoids division by zero', () {
      final now = DateTime.now();
      final metrics = MemoryMatchMetrics.calculate(
        difficulty: MemoryMatchDifficulty.easy,
        matchedPairs: 0,
        totalAttempts: 0,
        mistakes: 0,
        hintCount: 0,
        startedAt: now,
        completedAt: now,
      );

      expect(metrics.accuracy, 1.0);
      expect(metrics.score, 100);
    });
  });

  group('Client Adaptive Difficulty Engine Tests', () {
    test('High accuracy promotion increases level', () {
      final res = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 1,
        accuracy: 0.95,
        mistakes: 1,
        hintsUsed: 0,
        responseTimeMs: 2500.0,
        completed: true,
      );

      expect(res.action, AdaptiveDifficultyAction.increase);
      expect(res.previousDifficulty, 1);
      expect(res.nextDifficulty, 2);
      expect(res.caregiverExplanation.contains('High exercise accuracy'), isTrue);
    });

    test('High accuracy at maximum level maintains level 3', () {
      final res = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 3,
        accuracy: 0.95,
        mistakes: 0,
        hintsUsed: 0,
        responseTimeMs: 2200.0,
        completed: true,
      );

      expect(res.action, AdaptiveDifficultyAction.maintain);
      expect(res.nextDifficulty, 3);
    });

    test('Low accuracy demotes level and activates supportive triggers', () {
      final res = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 2,
        accuracy: 0.45,
        mistakes: 5,
        hintsUsed: 1,
        responseTimeMs: 8000.0,
        completed: true,
      );

      expect(res.action, AdaptiveDifficultyAction.decrease);
      expect(res.nextDifficulty, 1);
      expect(res.supportTriggers['extra_hints'], isTrue);
    });

    test('Low accuracy at minimum level 1 activates hints without underflowing', () {
      final res = ClientAdaptiveEngine.evaluate(
        currentDifficulty: 1,
        accuracy: 0.40,
        mistakes: 6,
        hintsUsed: 2,
        responseTimeMs: 9500.0,
        completed: true,
      );

      expect(res.action, AdaptiveDifficultyAction.maintain);
      expect(res.nextDifficulty, 1);
      expect(res.supportTriggers['extra_hints'], isTrue);
    });

    test('Strict non-clinical validation guarantees zero medical jargon', () {
      for (int diff = 1; diff <= 3; diff++) {
        for (final acc in [0.3, 0.65, 0.92]) {
          final res = ClientAdaptiveEngine.evaluate(
            currentDifficulty: diff,
            accuracy: acc,
            mistakes: 1,
            hintsUsed: 0,
            responseTimeMs: 3000.0,
            completed: true,
          );
          final text = '${res.patientFeedback} ${res.caregiverExplanation}'.toLowerCase();
          for (final banned in ClientAdaptiveEngine.prohibitedClinicalTerms) {
            expect(text.contains(banned), isFalse, reason: 'Banned term $banned found');
          }
        }
      }
    });
  });

  group('Drift SQLite Local Persistence for Memory Match', () {
    late AppDatabase db;
    late SmritiRepository repository;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repository = SmritiRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Completed Memory Match session is persisted with pending sync', () async {
      final now = DateTime.now();
      await repository.recordGameSession(
        gameType: 'memory_match',
        score: 220,
        accuracy: 0.85,
        mistakes: 2,
        responseTimeMs: 4200.0,
        difficulty: 1,
        hintCount: 1,
        startedAt: now.subtract(const Duration(minutes: 1)),
        completedAt: now,
      );

      final sessions = await repository.getRecentSessions();
      expect(sessions.length, 1);

      final session = sessions.first;
      expect(session.gameType, 'memory_match');
      expect(session.score, 220);
      expect(session.accuracy, 0.85);
      expect(session.mistakes, 2);
      expect(session.hintCount, 1);
      expect(session.difficulty, 1);
      expect(session.syncStatus, 'pending');

      final pendingCount = await repository.getPendingSyncCount();
      expect(pendingCount, 1);
    });
  });
}
