import 'package:drift/drift.dart';

class SyncQueue extends Table {
  TextColumn get localId => text()();
  TextColumn get entityType => text()(); // GameSessions, Reminders, ReminderEvents, Routines, Memories
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // INSERT, UPDATE, DELETE
  TextColumn get status => text().withDefault(const Constant('pending'))(); // pending, syncing, synced, failed, conflict
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastAttemptAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}
