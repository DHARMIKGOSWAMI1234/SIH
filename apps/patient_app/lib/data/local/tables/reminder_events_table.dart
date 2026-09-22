import 'package:drift/drift.dart';

class ReminderEvents extends Table {
  TextColumn get localId => text()();
  TextColumn get reminderId => text()();
  TextColumn get eventType => text()(); // acknowledged, snoozed, missed
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {localId};
}
