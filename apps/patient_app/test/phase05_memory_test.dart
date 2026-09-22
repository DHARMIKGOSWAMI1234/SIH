import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/features/memory/services/cultural_pack_service.dart';
import 'package:patient_app/features/memory/services/memory_activity_generator.dart';
import 'package:patient_app/features/memory/services/memory_rescue_service.dart';

void main() {
  group('Phase 05: Drift SQLite Migration & Persistence Safety', () {
    late AppDatabase db;
    late SmritiRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = SmritiRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('Memories table v2 schema includes all required fields and safe defaults', () async {
      final localId = await repo.insertMemory(
        title: 'Morning Garden Walk',
        description: 'Walking peacefully past blooming orchids.',
        category: 'daily_life',
        location: 'Home Garden',
        personName: 'Rahul',
        relationship: 'Grandson',
      );

      final mem = await repo.getMemoryById(localId);
      expect(mem, isNotNull);
      expect(mem!.title, 'Morning Garden Walk');
      expect(mem.description, 'Walking peacefully past blooming orchids.');
      expect(mem.category, 'daily_life');
      expect(mem.personName, 'Rahul');
      expect(mem.relationship, 'Grandson');
      expect(mem.location, 'Home Garden');
      expect(mem.isFavorite, false);
      expect(mem.isArchived, false);
      expect(mem.retryCount, 0);
      expect(mem.syncStatus, 'pending');

      // Verify SyncQueue entry was created
      final pendingCount = await repo.getPendingSyncCount();
      expect(pendingCount, greaterThanOrEqualTo(1));
    });

    test('Migration v1 to v2 preserves existing memory records without data loss', () async {
      final migrationDb = AppDatabase(NativeDatabase.memory());
      final migrator = migrationDb.createMigrator();
      await migrator.createAll();

      // Insert record matching v1 structure with defaults
      await migrationDb.into(migrationDb.memories).insert(
            MemoriesCompanion.insert(
              localId: 'v1_mem_01',
              title: 'Veranda Tea',
              description: 'Drinking afternoon tea',
              mediaUri: const drift.Value('tea.jpg'),
              syncStatus: const drift.Value('pending'),
            ),
          );

      final migrationRepo = SmritiRepository(migrationDb);

      // Verify existing row is preserved completely with safe v2 defaults
      final migratedMem = await migrationRepo.getMemoryById('v1_mem_01');
      expect(migratedMem, isNotNull);
      expect(migratedMem!.localId, 'v1_mem_01');
      expect(migratedMem.title, 'Veranda Tea');
      expect(migratedMem.description, 'Drinking afternoon tea');
      expect(migratedMem.mediaUri, 'tea.jpg');
      expect(migratedMem.category, 'other'); // Safe default applied
      expect(migratedMem.isFavorite, false); // Safe default applied
      expect(migratedMem.isArchived, false); // Safe default applied
      expect(migratedMem.personName, isNull); // Nullable field safe
      expect(migratedMem.relationship, isNull); // Nullable field safe

      await migrationDb.close();
    });

    test('Memory CRUD, favorite toggling, and archive operations work correctly', () async {
      final id = await repo.insertMemory(
        title: 'Bihu Dhol Practice',
        description: 'Listening to traditional drum beats.',
        category: 'festivals',
      );

      // Toggle favorite
      await repo.toggleFavorite(id, true);
      var mem = await repo.getMemoryById(id);
      expect(mem!.isFavorite, true);

      // Archive
      await repo.archiveMemory(id, true);
      mem = await repo.getMemoryById(id);
      expect(mem!.isArchived, true);

      // Filter query should not return archived
      var activeList = await repo.getMemories(includeArchived: false);
      expect(activeList.any((m) => m.localId == id), false);

      // Include archived should return it
      var allList = await repo.getMemories(includeArchived: true);
      expect(allList.any((m) => m.localId == id), true);

      // Delete
      await repo.deleteMemory(id);
      mem = await repo.getMemoryById(id);
      expect(mem, isNull);
    });

    test('searchMemories correctly matches by title, name, relationship, and location', () async {
      await repo.insertMemory(
        title: 'Spring Festival Celebration',
        description: 'Making Pitha with family.',
        category: 'festivals',
        personName: 'Ananya',
        relationship: 'Daughter',
        location: 'Guwahati',
      );

      final byName = await repo.searchMemories('Ananya');
      expect(byName.length, 1);

      final byRel = await repo.searchMemories('Daughter');
      expect(byRel.length, 1);

      final byLoc = await repo.searchMemories('Guwahati');
      expect(byLoc.length, 1);

      final byEmpty = await repo.searchMemories('NonExistentQuery');
      expect(byEmpty, isEmpty);
    });
  });

  group('Phase 05: Cultural Content Pack & Provenance', () {
    test('Starter pack items have valid provenance, license, and alt text', () {
      final items = CulturalPackService.getAllItems();
      expect(items, isNotEmpty);
      expect(items.length, greaterThanOrEqualTo(14));

      for (final item in items) {
        expect(item.id, isNotEmpty);
        expect(item.title, isNotEmpty);
        expect(item.description, isNotEmpty);
        expect(item.region, isNotEmpty);
        expect(item.license, isNotEmpty);
        expect(item.source, isNotEmpty);
        expect(item.altText, isNotEmpty);
      }
    });

    test('Filtering cultural items by region and category works accurately', () {
      final assamItems = CulturalPackService.getItemsByRegion('Assam');
      expect(assamItems, isNotEmpty);
      expect(assamItems.every((i) => i.region == 'Assam'), true);

      final placeItems = CulturalPackService.getItemsByCategory('places');
      expect(placeItems, isNotEmpty);
      expect(placeItems.every((i) => i.category == 'places'), true);

      final singleItem = CulturalPackService.getItemById('ner_assam_01');
      expect(singleItem, isNotNull);
      expect(singleItem!.title, 'Kaziranga Sanctuary');
    });
  });

  group('Phase 05: Memory-Based Activity Generator', () {
    test('Generates "Who is this?" activity when personal memory has a person/relationship', () {
      final sampleMem = Memory(
        localId: 'mem_p1',
        title: 'Family Garden Afternoon',
        description: 'Sitting peacefully with grandson Rahul.',
        mediaUri: null,
        category: 'family',
        relationship: 'Grandson',
        personName: 'Rahul',
        location: 'Garden',
        eventDate: null,
        imagePath: null,
        audioPath: null,
        language: 'en',
        region: 'Assam',
        tags: null,
        source: 'personal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        isArchived: false,
        syncStatus: 'pending',
        retryCount: 0,
        lastSyncAttempt: null,
      );

      final questions = MemoryActivityGenerator.generateActivities(
        personalMemories: [sampleMem],
        targetCount: 1,
      );

      expect(questions, isNotEmpty);
      final q = questions.first;
      expect(q.type, MemoryActivityType.whoIsThis);
      expect(q.correctAnswer, 'Grandson');
      expect(q.options.contains('Grandson'), true);
      expect(q.options.length, 3);
    });

    test('Supplements with NER cultural pack items when personal memories are insufficient', () {
      final questions = MemoryActivityGenerator.generateActivities(
        personalMemories: [],
        targetCount: 3,
      );

      expect(questions.length, 3);
      for (final q in questions) {
        expect(q.options.length, 3);
        expect(q.options.contains(q.correctAnswer), true);
        expect(q.hintText, isNotEmpty);
      }
    });
  });

  group('Phase 05: Memory Rescue Service (Deterministic Local Retrieval)', () {
    late AppDatabase db;
    late SmritiRepository repo;
    late MemoryRescueService rescue;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = SmritiRepository(db);
      rescue = MemoryRescueService(repo);
    });

    tearDown(() async {
      await db.close();
    });

    test('Retrieves person relationship without hallucination', () async {
      await repo.insertMemory(
        title: 'Visiting Grandson',
        description: 'Rahul visits on Sundays.',
        personName: 'Rahul',
        relationship: 'grandson',
        category: 'family',
      );

      final answer = await rescue.query('Who is Rahul?');
      expect(answer, 'Rahul is your grandson.');

      final answerRel = await rescue.query('What is my grandson\'s name?');
      expect(answerRel, 'Rahul is your grandson.');
    });

    test('Retrieves upcoming reminder information', () async {
      await repo.insertReminder(
        title: 'Morning Medicine',
        reminderType: 'medication',
        scheduledTime: '9:00 AM',
      );

      final answer = await rescue.query('When is my medicine?');
      expect(answer, contains('Morning Medicine'));
      expect(answer, contains('9:00 AM'));
    });

    test('Returns exact fallback message when information does not exist', () async {
      final answer = await rescue.query('Where are my flight tickets to Paris?');
      expect(answer, MemoryRescueService.fallbackMessage);
    });
  });
}
