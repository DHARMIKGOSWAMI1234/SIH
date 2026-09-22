import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart';

/// Central repository managing local-first SQLite persistence for SMRITI.
class SmritiRepository {
  final AppDatabase db;
  final Uuid _uuid = const Uuid();
  String? activePatientId;

  SmritiRepository(this.db);

  void setActivePatientId(String? patientId) {
    activePatientId = patientId;
  }

  // --- Game Sessions ---
  Future<List<GameSession>> getRecentSessions({int limit = 10}) {
    return (db.select(db.gameSessions)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(limit))
        .get();
  }

  Future<void> recordGameSession({
    required String gameType,
    required int score,
    required double accuracy,
    required int mistakes,
    required double responseTimeMs,
    required int difficulty,
    required int hintCount,
    required DateTime startedAt,
    required DateTime completedAt,
  }) async {
    final localId = _uuid.v4();
    await db.into(db.gameSessions).insert(
          GameSessionsCompanion.insert(
            localId: localId,
            gameType: gameType,
            score: score,
            accuracy: accuracy,
            mistakes: mistakes,
            responseTimeMs: responseTimeMs,
            difficulty: difficulty,
            hintCount: hintCount,
            startedAt: startedAt,
            completedAt: completedAt,
            syncStatus: const Value('pending'),
          ),
        );

    // Queue for sync
    await queueSync(
      entityType: 'GameSessions',
      entityId: localId,
      operation: 'INSERT',
    );
  }

  // --- Reminders ---
  Future<List<Reminder>> getReminders() {
    return db.select(db.reminders).get();
  }

  Future<void> insertReminder({
    required String title,
    required String reminderType,
    required String scheduledTime,
  }) async {
    final localId = _uuid.v4();
    await db.into(db.reminders).insert(
          RemindersCompanion.insert(
            localId: localId,
            title: title,
            reminderType: reminderType,
            scheduledTime: scheduledTime,
            enabled: const Value(true),
            syncStatus: const Value('pending'),
          ),
        );
    await queueSync(
      entityType: 'Reminders',
      entityId: localId,
      operation: 'INSERT',
    );
  }

  Future<void> recordReminderEvent({
    required String reminderId,
    required String eventType,
  }) async {
    final localId = _uuid.v4();
    await db.into(db.reminderEvents).insert(
          ReminderEventsCompanion.insert(
            localId: localId,
            reminderId: reminderId,
            eventType: eventType,
            occurredAt: DateTime.now(),
            syncStatus: const Value('pending'),
          ),
        );
    await queueSync(
      entityType: 'ReminderEvents',
      entityId: localId,
      operation: 'INSERT',
    );
  }

  // --- Routines ---
  Future<List<Routine>> getRoutines() {
    return db.select(db.routines).get();
  }

  Future<void> insertRoutine({
    required String title,
    required String stepsJson,
    required String preferredTime,
  }) async {
    final localId = _uuid.v4();
    await db.into(db.routines).insert(
          RoutinesCompanion.insert(
            localId: localId,
            title: title,
            stepsJson: stepsJson,
            preferredTime: preferredTime,
            enabled: const Value(true),
            syncStatus: const Value('pending'),
          ),
        );
    await queueSync(
      entityType: 'Routines',
      entityId: localId,
      operation: 'INSERT',
    );
  }

  // --- Memories ---
  Future<List<Memory>> getMemories({
    String? category,
    bool? isFavorite,
    bool includeArchived = false,
  }) async {
    final query = db.select(db.memories);
    if (!includeArchived) {
      query.where((t) => t.isArchived.equals(false));
    }
    if (category != null && category.isNotEmpty && category != 'all') {
      query.where((t) => t.category.equals(category));
    }
    if (isFavorite != null) {
      query.where((t) => t.isFavorite.equals(isFavorite));
    }
    query.orderBy([(t) => OrderingTerm.desc(t.createdAt)]);
    final all = await query.get();

    if (activePatientId != null && activePatientId!.isNotEmpty) {
      final ownerTag = 'owner:$activePatientId';
      return all.where((m) {
        if (m.source == 'cultural') return true;
        return m.tags != null && m.tags!.contains(ownerTag);
      }).toList();
    }

    return all;
  }

  Future<Memory?> getMemoryById(String localId) async {
    final results = await (db.select(db.memories)
          ..where((t) => t.localId.equals(localId)))
        .get();
    if (results.isEmpty) return null;
    final m = results.first;

    if (activePatientId != null && activePatientId!.isNotEmpty) {
      if (m.source == 'cultural') return m;
      final ownerTag = 'owner:$activePatientId';
      if (m.tags == null || !m.tags!.contains(ownerTag)) {
        return null;
      }
    }
    return m;
  }

  Future<String> insertMemory({
    required String title,
    required String description,
    String category = 'other',
    String? relationship,
    String? personName,
    String? location,
    DateTime? eventDate,
    String? imagePath,
    String? audioPath,
    String? mediaUri,
    String language = 'en',
    String? region,
    String? tags,
    String source = 'personal',
    bool isFavorite = false,
  }) async {
    final localId = _uuid.v4();
    final now = DateTime.now();

    String? effectiveTags = tags;
    if (activePatientId != null && activePatientId!.isNotEmpty) {
      final ownerTag = 'owner:$activePatientId';
      if (effectiveTags == null || effectiveTags.isEmpty) {
        effectiveTags = ownerTag;
      } else if (!effectiveTags.contains(ownerTag)) {
        effectiveTags = '$effectiveTags,$ownerTag';
      }
    }

    await db.into(db.memories).insert(
          MemoriesCompanion.insert(
            localId: localId,
            title: title,
            description: description,
            mediaUri: Value(mediaUri ?? imagePath),
            category: Value(category),
            relationship: Value(relationship),
            personName: Value(personName),
            location: Value(location),
            eventDate: Value(eventDate),
            imagePath: Value(imagePath ?? mediaUri),
            audioPath: Value(audioPath),
            language: Value(language),
            region: Value(region),
            tags: Value(effectiveTags),
            source: Value(source),
            createdAt: Value(now),
            updatedAt: Value(now),
            isFavorite: Value(isFavorite),
            isArchived: const Value(false),
            syncStatus: const Value('pending'),
            retryCount: const Value(0),
          ),
        );

    // Queue for sync
    await queueSync(
      entityType: 'Memories',
      entityId: localId,
      operation: 'INSERT',
    );

    return localId;
  }

  Future<void> updateMemory({
    required String localId,
    required String title,
    required String description,
    String? category,
    String? relationship,
    String? personName,
    String? location,
    DateTime? eventDate,
    String? imagePath,
    String? audioPath,
    String? mediaUri,
    String? language,
    String? region,
    String? tags,
    bool? isFavorite,
    bool? isArchived,
  }) async {
    final now = DateTime.now();
    await (db.update(db.memories)..where((t) => t.localId.equals(localId))).write(
      MemoriesCompanion(
        title: Value(title),
        description: Value(description),
        category: category != null ? Value(category) : const Value.absent(),
        relationship: relationship != null ? Value(relationship) : const Value.absent(),
        personName: personName != null ? Value(personName) : const Value.absent(),
        location: location != null ? Value(location) : const Value.absent(),
        eventDate: eventDate != null ? Value(eventDate) : const Value.absent(),
        imagePath: imagePath != null ? Value(imagePath) : const Value.absent(),
        audioPath: audioPath != null ? Value(audioPath) : const Value.absent(),
        mediaUri: (mediaUri ?? imagePath) != null ? Value(mediaUri ?? imagePath) : const Value.absent(),
        language: language != null ? Value(language) : const Value.absent(),
        region: region != null ? Value(region) : const Value.absent(),
        tags: tags != null ? Value(tags) : const Value.absent(),
        isFavorite: isFavorite != null ? Value(isFavorite) : const Value.absent(),
        isArchived: isArchived != null ? Value(isArchived) : const Value.absent(),
        updatedAt: Value(now),
        syncStatus: const Value('pending'),
      ),
    );

    await queueSync(
      entityType: 'Memories',
      entityId: localId,
      operation: 'UPDATE',
    );
  }

  Future<void> toggleFavorite(String localId, bool isFavorite) async {
    await (db.update(db.memories)..where((t) => t.localId.equals(localId))).write(
      MemoriesCompanion(
        isFavorite: Value(isFavorite),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );

    await queueSync(
      entityType: 'Memories',
      entityId: localId,
      operation: 'UPDATE',
    );
  }

  Future<void> archiveMemory(String localId, bool isArchived) async {
    await (db.update(db.memories)..where((t) => t.localId.equals(localId))).write(
      MemoriesCompanion(
        isArchived: Value(isArchived),
        updatedAt: Value(DateTime.now()),
        syncStatus: const Value('pending'),
      ),
    );

    await queueSync(
      entityType: 'Memories',
      entityId: localId,
      operation: 'UPDATE',
    );
  }

  Future<void> deleteMemory(String localId) async {
    await (db.delete(db.memories)..where((t) => t.localId.equals(localId))).go();

    await queueSync(
      entityType: 'Memories',
      entityId: localId,
      operation: 'DELETE',
    );
  }

  Future<List<Memory>> searchMemories(String query) async {
    final clean = query.trim().toLowerCase();
    final all = await getMemories();
    if (clean.isEmpty) return all;
    return all.where((m) {
      if (m.isArchived) return false;
      return m.title.toLowerCase().contains(clean) ||
          m.description.toLowerCase().contains(clean) ||
          (m.personName?.toLowerCase().contains(clean) ?? false) ||
          (m.relationship?.toLowerCase().contains(clean) ?? false) ||
          (m.location?.toLowerCase().contains(clean) ?? false) ||
          m.category.toLowerCase().contains(clean);
    }).toList();
  }

  // --- Sync Queue ---
  Future<void> queueSync({
    required String entityType,
    required String entityId,
    required String operation,
  }) async {
    final localId = _uuid.v4();
    await db.into(db.syncQueue).insert(
          SyncQueueCompanion.insert(
            localId: localId,
            entityType: entityType,
            entityId: entityId,
            operation: operation,
            status: const Value('pending'),
            retryCount: const Value(0),
          ),
        );
  }

  Future<int> getPendingSyncCount() async {
    final count = await (db.select(db.syncQueue)
          ..where((t) => t.status.equals('pending')))
        .get();
    return count.length;
  }

  Future<List<SyncQueueData>> getPendingQueueItems({int limit = 50}) {
    return (db.select(db.syncQueue)
          ..where((t) => t.status.isIn(['pending', 'failed']))
          ..orderBy([(t) => OrderingTerm.asc(t.retryCount)])
          ..limit(limit))
        .get();
  }

  Future<Map<String, dynamic>?> getEntityPayload(String entityType, String entityId) async {
    switch (entityType) {
      case 'Memories':
        final mem = await getMemoryById(entityId);
        if (mem == null) return null;
        return {
          'title': mem.title,
          'description': mem.description,
          'category': mem.category,
          'relationship': mem.relationship,
          'personName': mem.personName,
          'location': mem.location,
          'eventDate': mem.eventDate?.toIso8601String(),
          'imagePath': mem.imagePath,
          'audioPath': mem.audioPath,
          'mediaUri': mem.mediaUri,
          'language': mem.language,
          'region': mem.region,
          'tags': mem.tags,
          'source': mem.source,
          'isFavorite': mem.isFavorite,
          'isArchived': mem.isArchived,
        };
      case 'GameSessions':
        final gs = await (db.select(db.gameSessions)..where((t) => t.localId.equals(entityId))).getSingleOrNull();
        if (gs == null) return null;
        return {
          'gameType': gs.gameType,
          'score': gs.score,
          'accuracy': gs.accuracy,
          'mistakes': gs.mistakes,
          'responseTimeMs': gs.responseTimeMs,
          'difficulty': gs.difficulty,
          'hintCount': gs.hintCount,
          'startedAt': gs.startedAt.toIso8601String(),
          'completedAt': gs.completedAt.toIso8601String(),
        };
      case 'Reminders':
        final r = await (db.select(db.reminders)..where((t) => t.localId.equals(entityId))).getSingleOrNull();
        if (r == null) return null;
        return {
          'title': r.title,
          'reminderType': r.reminderType,
          'scheduledTime': r.scheduledTime,
          'enabled': r.enabled,
        };
      case 'ReminderEvents':
        final re = await (db.select(db.reminderEvents)..where((t) => t.localId.equals(entityId))).getSingleOrNull();
        if (re == null) return null;
        return {
          'reminderId': re.reminderId,
          'eventType': re.eventType,
          'occurredAt': re.occurredAt.toIso8601String(),
        };
      case 'Routines':
        final rot = await (db.select(db.routines)..where((t) => t.localId.equals(entityId))).getSingleOrNull();
        if (rot == null) return null;
        return {
          'title': rot.title,
          'stepsJson': rot.stepsJson,
          'preferredTime': rot.preferredTime,
          'enabled': rot.enabled,
        };
      default:
        return null;
    }
  }

  Future<void> markSyncSuccess({
    required String queueLocalId,
    required String entityType,
    required String entityId,
    String? serverId,
  }) async {
    await (db.update(db.syncQueue)..where((t) => t.localId.equals(queueLocalId))).write(
      SyncQueueCompanion(
        status: const Value('synced'),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );

    final now = DateTime.now();
    switch (entityType) {
      case 'Memories':
        await (db.update(db.memories)..where((t) => t.localId.equals(entityId))).write(
          MemoriesCompanion(
            serverId: serverId != null ? Value(serverId) : const Value.absent(),
            syncStatus: const Value('synced'),
            lastSyncAttempt: Value(now),
          ),
        );
        break;
      case 'GameSessions':
        await (db.update(db.gameSessions)..where((t) => t.localId.equals(entityId))).write(
          GameSessionsCompanion(
            serverId: serverId != null ? Value(serverId) : const Value.absent(),
            syncStatus: const Value('synced'),
          ),
        );
        break;
      case 'Reminders':
        await (db.update(db.reminders)..where((t) => t.localId.equals(entityId))).write(
          RemindersCompanion(
            serverId: serverId != null ? Value(serverId) : const Value.absent(),
            syncStatus: const Value('synced'),
          ),
        );
        break;
      case 'ReminderEvents':
        await (db.update(db.reminderEvents)..where((t) => t.localId.equals(entityId))).write(
          const ReminderEventsCompanion(
            syncStatus: Value('synced'),
          ),
        );
        break;
      case 'Routines':
        await (db.update(db.routines)..where((t) => t.localId.equals(entityId))).write(
          RoutinesCompanion(
            serverId: serverId != null ? Value(serverId) : const Value.absent(),
            syncStatus: const Value('synced'),
          ),
        );
        break;
    }
  }

  Future<void> markSyncConflict({
    required String queueLocalId,
    required String entityType,
    required String entityId,
  }) async {
    await (db.update(db.syncQueue)..where((t) => t.localId.equals(queueLocalId))).write(
      SyncQueueCompanion(
        status: const Value('conflict'),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> markSyncFailed({
    required String queueLocalId,
    required int retryCount,
  }) async {
    await (db.update(db.syncQueue)..where((t) => t.localId.equals(queueLocalId))).write(
      SyncQueueCompanion(
        status: const Value('failed'),
        retryCount: Value(retryCount),
        lastAttemptAt: Value(DateTime.now()),
      ),
    );
  }
}
