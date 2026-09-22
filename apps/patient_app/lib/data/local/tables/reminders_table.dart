import 'package:drift/drift.dart';

class Reminders extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get reminderType => text()(); // medication, hydration, routine
  TextColumn get scheduledTime => text()(); // e.g. "09:00"
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}
