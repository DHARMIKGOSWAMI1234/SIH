import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/local/sync/sync_manager.dart';
import 'package:patient_app/data/remote/sync_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'dart:convert';

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

  group('SyncManager & Idempotency Tests', () {
    test('Empty queue returns idle status without network calls', () async {
      final mockClient = MockClient((request) async {
        fail('Should not make network call for empty queue');
      });
      final apiClient = SyncApiClient(client: mockClient);
      final manager = SyncManager(repository: repository, apiClient: apiClient);

      final report = await manager.synchronize();
      expect(report.state, SyncManagerState.idle);
      expect(report.syncedCount, 0);
    });

    test('Pending items use queueItem.localId as operation_id idempotency key', () async {
      // 1. Record a game session (queues INSERT with unique operation_id)
      await repository.recordGameSession(
        gameType: 'Memory Match',
        score: 100,
        accuracy: 1.0,
        mistakes: 0,
        responseTimeMs: 1200.0,
        difficulty: 1,
        hintCount: 0,
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      // Verify queue has 1 pending item
      final pending = await repository.getPendingQueueItems();
      expect(pending.length, 1);
      final queueOpId = pending.first.localId;
      final entityLocalId = pending.first.entityId;
      expect(queueOpId, isNotEmpty);
      expect(entityLocalId, isNotEmpty);
      expect(queueOpId, isNot(equals(entityLocalId))); // Distinct operation ID!

      // 2. Mock API client verifying operation_id and local_id
      String? capturedOpId;
      String? capturedLocalId;
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final items = body['items'] as List<dynamic>;
        capturedOpId = items.first['operation_id'];
        capturedLocalId = items.first['local_id'];

        return http.Response(
          jsonEncode({
            'processed_count': 1,
            'server_time': DateTime.now().toUtc().toIso8601String(),
            'results': [
              {
                'operation_id': capturedOpId,
                'status': 'synced',
                'server_id': 'srv-uuid-999',
                'server_updated_at': DateTime.now().toUtc().toIso8601String(),
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = SyncApiClient(client: mockClient);
      final manager = SyncManager(repository: repository, apiClient: apiClient);

      final report = await manager.synchronize();
      expect(report.syncedCount, 1);
      expect(capturedOpId, queueOpId);
      expect(capturedLocalId, entityLocalId);

      // 3. Confirm queue item marked synced and gameSession serverId updated
      final queueAfter = await db.select(db.syncQueue).get();
      expect(queueAfter.first.status, 'synced');

      final sessionAfter = await db.select(db.gameSessions).get();
      expect(sessionAfter.first.syncStatus, 'synced');
      expect(sessionAfter.first.serverId, 'srv-uuid-999');
    });

    test('Network failure marks items failed with incremented retry count without deleting', () async {
      await repository.insertReminder(
        title: 'Drink Water',
        reminderType: 'hydration',
        scheduledTime: '10:00',
      );

      // Mock network failure (e.g. 503 service unavailable)
      final mockClient = MockClient((request) async {
        return http.Response('Service Unavailable', 503);
      });

      final apiClient = SyncApiClient(client: mockClient);
      final manager = SyncManager(repository: repository, apiClient: apiClient);

      final report = await manager.synchronize();
      expect(report.state, SyncManagerState.offline);

      // Queue item must still exist in DB, marked failed, retryCount = 1
      final queueItems = await db.select(db.syncQueue).get();
      expect(queueItems.length, 1);
      expect(queueItems.first.status, 'failed');
      expect(queueItems.first.retryCount, 1);
    });

    test('Conflict response marks item as conflict without deleting local record', () async {
      final memLocalId = await repository.insertMemory(
        title: 'My Memory',
        description: 'Testing conflict preservation',
      );

      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final opId = body['items'][0]['operation_id'];
        return http.Response(
          jsonEncode({
            'processed_count': 1,
            'server_time': DateTime.now().toUtc().toIso8601String(),
            'results': [
              {
                'operation_id': opId,
                'status': 'conflict',
                'message': 'Server record is newer than client update',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = SyncApiClient(client: mockClient);
      final manager = SyncManager(repository: repository, apiClient: apiClient);

      final report = await manager.synchronize();
      expect(report.conflictCount, 1);

      // Local memory must still exist intact!
      final memory = await repository.getMemoryById(memLocalId);
      expect(memory, isNotNull);
      expect(memory!.title, 'My Memory');

      final queue = await db.select(db.syncQueue).get();
      expect(queue.first.status, 'conflict');
    });

    test('already_processed server response marks session and queue as synced without duplicate error', () async {
      await repository.recordGameSession(
        gameType: 'Pattern Recognition',
        score: 95,
        accuracy: 0.95,
        mistakes: 1,
        responseTimeMs: 1400.0,
        difficulty: 1,
        hintCount: 1,
        startedAt: DateTime.now().subtract(const Duration(minutes: 3)),
        completedAt: DateTime.now(),
      );

      final pending = await repository.getPendingQueueItems();
      expect(pending.length, 1);
      final opId = pending.first.localId;

      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'processed_count': 1,
            'server_time': DateTime.now().toUtc().toIso8601String(),
            'results': [
              {
                'operation_id': opId,
                'status': 'already_processed',
                'server_id': 'srv-existing-session-123',
                'server_updated_at': DateTime.now().toUtc().toIso8601String(),
                'message': 'Operation previously processed and acknowledged',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = SyncApiClient(client: mockClient);
      final manager = SyncManager(repository: repository, apiClient: apiClient);

      final report = await manager.synchronize();
      expect(report.syncedCount, 1);

      // Verify queue item and game session are marked synced
      final queueItems = await db.select(db.syncQueue).get();
      expect(queueItems.first.status, 'synced');

      final sessions = await db.select(db.gameSessions).get();
      expect(sessions.first.syncStatus, 'synced');
      expect(sessions.first.serverId, 'srv-existing-session-123');
    });

    test('SyncManager resolves active patient ID dynamically from repository', () async {
      repository.setActivePatientId('patient-dynamic-777');

      await repository.recordGameSession(
        gameType: 'Memory Match',
        score: 100,
        accuracy: 1.0,
        mistakes: 0,
        responseTimeMs: 1100.0,
        difficulty: 1,
        hintCount: 0,
        startedAt: DateTime.now(),
        completedAt: DateTime.now(),
      );

      String? capturedPatientId;
      final mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        capturedPatientId = body['patient_id'] as String?;
        return http.Response(
          jsonEncode({
            'processed_count': 1,
            'results': [
              {
                'operation_id': body['items'][0]['operation_id'],
                'status': 'synced',
                'server_id': 'srv-dyn-1',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final apiClient = SyncApiClient(client: mockClient);
      final manager = SyncManager(repository: repository, apiClient: apiClient);

      expect(manager.patientId, 'patient-dynamic-777');
      final report = await manager.synchronize();
      expect(report.syncedCount, 1);
      expect(capturedPatientId, 'patient-dynamic-777');
    });

    test('Offline sovereignty: session saved locally remains available offline', () async {
      // 1. Play & save Pattern Recognition offline
      await repository.recordGameSession(
        gameType: 'Pattern Recognition',
        score: 100,
        accuracy: 1.0,
        mistakes: 0,
        responseTimeMs: 1200.0,
        difficulty: 1,
        hintCount: 0,
        startedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        completedAt: DateTime.now(),
      );

      // 2. Query local history without network
      final sessions = await repository.getRecentSessions(limit: 10);
      expect(sessions.length, 1);
      expect(sessions.first.gameType, 'Pattern Recognition');
      expect(sessions.first.syncStatus, 'pending');

      // 3. SyncQueue has pending item
      final pending = await repository.getPendingQueueItems();
      expect(pending.length, 1);
      expect(pending.first.status, 'pending');
    });
  });
}

