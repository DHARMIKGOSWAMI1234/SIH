import 'package:drift/drift.dart';

class Routines extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get stepsJson => text()(); // JSON array of steps
  TextColumn get preferredTime => text()(); // e.g. "08:00 AM"
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}
