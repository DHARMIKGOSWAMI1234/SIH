import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';

void main() {
  late AppDatabase db;
  late SmritiRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SmritiRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('Drift SQLite Local Persistence Tests', () {
    test('Can record game session and verify pending sync queue', () async {
      final now = DateTime.now();
      await repository.recordGameSession(
        gameType: 'memory_match',
        score: 100,
        accuracy: 0.95,
        mistakes: 1,
        responseTimeMs: 3500.0,
        difficulty: 2,
        hintCount: 0,
        startedAt: now.subtract(const Duration(minutes: 2)),
        completedAt: now,
      );

      final sessions = await repository.getRecentSessions();
      expect(sessions.length, 1);
      expect(sessions.first.gameType, 'memory_match');
      expect(sessions.first.score, 100);
      expect(sessions.first.syncStatus, 'pending');

      final pendingCount = await repository.getPendingSyncCount();
      expect(pendingCount, 1);
    });

    test('Can insert and retrieve reminders', () async {
      await repository.insertReminder(
        title: 'Morning Water Reminder',
        reminderType: 'Hydration',
        scheduledTime: '08:30 AM',
      );

      final reminders = await repository.getReminders();
      expect(reminders.length, 1);
      expect(reminders.first.title, 'Morning Water Reminder');
      expect(reminders.first.enabled, isTrue);
    });

    test('Can insert and retrieve cultural memories', () async {
      await repository.insertMemory(
        title: 'Brahmaputra Sunset',
        description: 'Peaceful boat ride near Majuli island.',
        language: 'as',
      );

      final memories = await repository.getMemories();
      expect(memories.length, 1);
      expect(memories.first.title, 'Brahmaputra Sunset');
      expect(memories.first.language, 'as');
    });
  });
}
