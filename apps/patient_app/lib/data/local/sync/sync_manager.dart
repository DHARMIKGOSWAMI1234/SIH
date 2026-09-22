/// SyncManager coordinates the offline-first queue processing with the FastAPI backend.
///
/// Features:
/// - Local-first: Never blocks UI or patient activity execution.
/// - Operation-level idempotency: Uses SyncQueue.localId as operation_id.
/// - Bounded exponential backoff with jitter on network failures.
/// - Non-destructive conflict handling.
library;
import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../repositories/smriti_repository.dart';
import '../../remote/sync_api_client.dart';

enum SyncManagerState {
  idle,
  syncing,
  offline,
  error,
}

class SyncManagerReport {
  final SyncManagerState state;
  final int pendingCount;
  final int syncedCount;
  final int conflictCount;
  final int failedCount;
  final String? lastMessage;
  final DateTime? lastAttemptAt;

  const SyncManagerReport({
    required this.state,
    this.pendingCount = 0,
    this.syncedCount = 0,
    this.conflictCount = 0,
    this.failedCount = 0,
    this.lastMessage,
    this.lastAttemptAt,
  });
}

class SyncManager extends ChangeNotifier {
  final SmritiRepository repository;
  final SyncApiClient apiClient;

  SyncManagerState _state = SyncManagerState.idle;

  int _syncedCount = 0;
  int _conflictCount = 0;
  int _failedCount = 0;
  String? _lastMessage;
  DateTime? _lastAttemptAt;
  bool _isProcessing = false;

  final Random _random = Random();
  final int _maxRetries = 5;
  final Duration _baseDelay = const Duration(seconds: 2);
  final Duration _maxDelay = const Duration(seconds: 60);

  final String? _explicitPatientId;

  SyncManager({
    required this.repository,
    required this.apiClient,
    String? patientId,
  }) : _explicitPatientId = patientId;

  String get patientId =>
      _explicitPatientId ?? repository.activePatientId ?? 'demo-patient-01';

  SyncManagerReport get report => SyncManagerReport(

        state: _state,
        pendingCount: 0,
        syncedCount: _syncedCount,
        conflictCount: _conflictCount,
        failedCount: _failedCount,
        lastMessage: _lastMessage,
        lastAttemptAt: _lastAttemptAt,
      );

  SyncManagerState get state => _state;

  /// Trigger synchronization of all pending queue items.
  Future<SyncManagerReport> synchronize() async {
    if (_isProcessing) {
      return report;
    }

    _isProcessing = true;
    _state = SyncManagerState.syncing;
    _lastAttemptAt = DateTime.now();
    notifyListeners();

    try {
      final pendingItems = await repository.getPendingQueueItems(limit: 50);
      if (pendingItems.isEmpty) {
        _state = SyncManagerState.idle;
        _lastMessage = 'All activities synchronized';
        notifyListeners();
        _isProcessing = false;
        return report;
      }

      // Build batch payload
      final itemsPayload = <Map<String, dynamic>>[];
      final validQueueItems = [];

      for (final queueItem in pendingItems) {
        // Exceeded max retries: keep in failed state
        if (queueItem.retryCount >= _maxRetries) {
          continue;
        }

        final entityPayload = await repository.getEntityPayload(
          queueItem.entityType,
          queueItem.entityId,
        );

        // Even if entity payload is empty (e.g. deleted entity), we proceed with sync
        itemsPayload.add({
          'operation_id': queueItem.localId, // Unique operation UUID idempotency key
          'entity_type': queueItem.entityType,
          'operation': queueItem.operation,
          'local_id': queueItem.entityId,
          'payload': entityPayload ?? {},
          'client_updated_at': DateTime.now().toUtc().toIso8601String(),
        });
        validQueueItems.add(queueItem);
      }

      if (itemsPayload.isEmpty) {
        _state = SyncManagerState.idle;
        _lastMessage = 'No eligible items for sync';
        notifyListeners();
        _isProcessing = false;
        return report;
      }

      // Send to FastAPI backend
      final response = await apiClient.sendBatchSync(
        patientId: patientId,
        items: itemsPayload,
      );

      if (!response.isSuccess) {
        final isAuthError = response.error != null &&
            (response.error!.contains('401') || response.error!.toLowerCase().contains('unauthorized'));

        // Retain queue items safely
        for (final queueItem in validQueueItems) {
          final nextRetry = isAuthError ? queueItem.retryCount : queueItem.retryCount + 1;
          await repository.markSyncFailed(
            queueLocalId: queueItem.localId,
            retryCount: nextRetry,
          );
        }
        _failedCount += validQueueItems.length;
        _state = isAuthError ? SyncManagerState.error : SyncManagerState.offline;
        _lastMessage = isAuthError
            ? 'Authentication required to synchronize. Queue preserved.'
            : (response.error ?? 'Offline: synchronization deferred');
        notifyListeners();
        _isProcessing = false;
        return report;
      }

      // Process operation-level results
      for (final result in response.results) {
        final matchingItem = validQueueItems.firstWhere(
          (q) => q.localId == result.operationId,
          orElse: () => null,
        );
        if (matchingItem == null) continue;

        if (result.status == 'synced' || result.status == 'already_processed') {
          await repository.markSyncSuccess(
            queueLocalId: matchingItem.localId,
            entityType: matchingItem.entityType,
            entityId: matchingItem.entityId,
            serverId: result.serverId,
          );
          _syncedCount++;
        } else if (result.status == 'conflict') {
          await repository.markSyncConflict(
            queueLocalId: matchingItem.localId,
            entityType: matchingItem.entityType,
            entityId: matchingItem.entityId,
          );
          _conflictCount++;
        } else {
          final nextRetry = matchingItem.retryCount + 1;
          await repository.markSyncFailed(
            queueLocalId: matchingItem.localId,
            retryCount: nextRetry,
          );
          _failedCount++;
        }
      }

      _state = SyncManagerState.idle;
      _lastMessage = 'Sync completed: $_syncedCount synced, $_conflictCount conflicts';
      notifyListeners();
    } catch (e) {
      _state = SyncManagerState.error;
      _lastMessage = 'Sync error: $e';
      notifyListeners();
    } finally {
      _isProcessing = false;
    }

    return report;
  }

  /// Calculates backoff duration with random jitter.
  Duration calculateBackoff(int retryCount) {
    final expMs = _baseDelay.inMilliseconds * pow(2, retryCount).toInt();
    final clampedMs = min(expMs, _maxDelay.inMilliseconds);
    final jitterMs = _random.nextInt(500);
    return Duration(milliseconds: clampedMs + jitterMs);
  }
}
