import 'package:drift/drift.dart';

class GameSessions extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get gameType => text()();
  IntColumn get score => integer()();
  RealColumn get accuracy => real()();
  IntColumn get mistakes => integer()();
  RealColumn get responseTimeMs => real()();
  IntColumn get difficulty => integer()();
  IntColumn get hintCount => integer()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}
