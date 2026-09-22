import 'package:drift/drift.dart';

class Memories extends Table {
  TextColumn get localId => text()();
  TextColumn get serverId => text().nullable()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  TextColumn get mediaUri => text().nullable()(); // v1 backward compatibility
  TextColumn get category => text().withDefault(const Constant('other'))();
  TextColumn get relationship => text().nullable()();
  TextColumn get personName => text().nullable()();
  TextColumn get location => text().nullable()();
  DateTimeColumn get eventDate => dateTime().nullable()();
  TextColumn get imagePath => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get language => text().withDefault(const Constant('en'))();
  TextColumn get region => text().nullable()();
  TextColumn get tags => text().nullable()();
  TextColumn get source => text().withDefault(const Constant('personal'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncAttempt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {localId};
}

