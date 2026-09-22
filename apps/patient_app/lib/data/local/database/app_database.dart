import 'package:drift/drift.dart';
import '../tables/game_sessions_table.dart';
import '../tables/reminders_table.dart';
import '../tables/reminder_events_table.dart';
import '../tables/routines_table.dart';
import '../tables/memories_table.dart';
import '../tables/sync_queue_table.dart';
import '../connection/connection.dart' as impl;

part 'app_database.g.dart';

@DriftDatabase(tables: [
  GameSessions,
  Reminders,
  ReminderEvents,
  Routines,
  Memories,
  SyncQueue,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? impl.connect());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(memories, memories.category);
            await m.addColumn(memories, memories.relationship);
            await m.addColumn(memories, memories.personName);
            await m.addColumn(memories, memories.location);
            await m.addColumn(memories, memories.eventDate);
            await m.addColumn(memories, memories.imagePath);
            await m.addColumn(memories, memories.audioPath);
            await m.addColumn(memories, memories.region);
            await m.addColumn(memories, memories.tags);
            await m.addColumn(memories, memories.source);
            await m.addColumn(memories, memories.createdAt);
            await m.addColumn(memories, memories.updatedAt);
            await m.addColumn(memories, memories.isFavorite);
            await m.addColumn(memories, memories.isArchived);
            await m.addColumn(memories, memories.retryCount);
            await m.addColumn(memories, memories.lastSyncAttempt);
          }
        },
      );
}
