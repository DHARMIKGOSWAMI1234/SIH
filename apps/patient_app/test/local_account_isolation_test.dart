import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
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

  test('Local Account Data Isolation: Multi-patient privacy without data deletion', () async {
    // 1. Patient A logs in
    repository.setActivePatientId('patient-alpha-001');

    // 2. Patient A creates a personal memory
    final memIdA = await repository.insertMemory(
      title: 'Family Gathering in Guwahati',
      description: 'Celebrating with family during autumn festival.',
      category: 'family',
      personName: 'Son & Daughter-in-law',
      location: 'Guwahati',
    );
    expect(memIdA, isNotEmpty);

    // Patient A can see their memory
    final listA = await repository.getMemories();
    expect(listA.length, 1);
    expect(listA.first.title, 'Family Gathering in Guwahati');

    // 3. Patient A logs out
    repository.setActivePatientId(null);

    // 4. Patient B logs in
    repository.setActivePatientId('patient-beta-002');

    // 5. Patient B MUST NOT see Patient A's memory
    final listB = await repository.getMemories();
    expect(listB.isEmpty, isTrue, reason: "Patient B must NOT see Patient A's private memories");

    final directQueryB = await repository.getMemoryById(memIdA);
    expect(directQueryB, isNull, reason: "Patient B must NOT be able to access Patient A's memory by ID");

    // Patient B creates their own memory
    final memIdB = await repository.insertMemory(
      title: 'Garden Tea Time in Jorhat',
      description: 'Drinking fresh Assam tea in the garden.',
      category: 'routine',
      location: 'Jorhat',
    );
    expect(memIdB, isNotEmpty);

    // Patient B sees only their memory
    final listBAfter = await repository.getMemories();
    expect(listBAfter.length, 1);
    expect(listBAfter.first.title, 'Garden Tea Time in Jorhat');

    // 6. Patient B logs out
    repository.setActivePatientId(null);

    // 7. Patient A logs back in
    repository.setActivePatientId('patient-alpha-001');

    // 8. Patient A sees their original memory intact (zero data deletion!)
    final listARestored = await repository.getMemories();
    expect(listARestored.length, 1);
    expect(listARestored.first.title, 'Family Gathering in Guwahati');
    expect(listARestored.first.localId, memIdA);

    // Patient A does NOT see Patient B's memory
    final directQueryA = await repository.getMemoryById(memIdB);
    expect(directQueryA, isNull, reason: "Patient A must NOT see Patient B's memory");

    // 9. Cultural memories remain accessible to both patients
    await repository.insertMemory(
      title: 'Bihu Harvest Tradition',
      description: 'Traditional Assam harvest celebration.',
      category: 'tradition',
      source: 'cultural',
    );

    final listAWithCultural = await repository.getMemories();
    expect(listAWithCultural.length, 2, reason: 'Patient A sees their personal memory + cultural memory');

    repository.setActivePatientId('patient-beta-002');
    final listBWithCultural = await repository.getMemories();
    expect(listBWithCultural.length, 2, reason: 'Patient B sees their personal memory + cultural memory');
  });
}
