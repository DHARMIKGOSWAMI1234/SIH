import 'dart:async';
import 'package:flutter/foundation.dart';
import 'sync_manager.dart';

enum LocalSyncState {
  synced,
  pending,
  syncing,
  failed,
  offline,
}

class SyncStatusModel {
  final LocalSyncState state;
  final int pendingItemsCount;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const SyncStatusModel({
    required this.state,
    this.pendingItemsCount = 0,
    this.lastSyncedAt,
    this.errorMessage,
  });

  String get displayLabel {
    switch (state) {
      case LocalSyncState.synced:
        return 'All activities saved locally & up to date';
      case LocalSyncState.pending:
        return '$pendingItemsCount item(s) saved locally, pending sync';
      case LocalSyncState.syncing:
        return 'Syncing gently in background...';
      case LocalSyncState.failed:
        return 'Saved locally. Sync will retry automatically.';
      case LocalSyncState.offline:
        return 'Offline mode: all activities fully saved locally';
    }
  }
}

/// Offline-First Synchronization Service Abstraction.
///
/// Ensures all patient activities are saved locally first. Never blocks the UI
/// or forces active internet connectivity to perform actions.
class SyncService extends ChangeNotifier {
  final SyncManager? manager;

  SyncStatusModel _status = SyncStatusModel(
    state: LocalSyncState.synced,
    pendingItemsCount: 0,
    lastSyncedAt: DateTime.now(),
  );

  SyncService({this.manager});

  SyncStatusModel get status => _status;

  void updatePendingCount(int count) {
    _status = SyncStatusModel(
      state: count > 0 ? LocalSyncState.pending : LocalSyncState.synced,
      pendingItemsCount: count,
      lastSyncedAt: _status.lastSyncedAt,
    );
    notifyListeners();
  }

  Future<void> triggerSync() async {
    if (_status.pendingItemsCount == 0 && manager == null) return;

    _status = SyncStatusModel(
      state: LocalSyncState.syncing,
      pendingItemsCount: _status.pendingItemsCount,
      lastSyncedAt: _status.lastSyncedAt,
    );
    notifyListeners();

    final mgr = manager;
    if (mgr != null) {
      final report = await mgr.synchronize();
      final LocalSyncState finalState;
      if (report.state == SyncManagerState.offline) {
        finalState = LocalSyncState.offline;
      } else if (report.state == SyncManagerState.error) {
        finalState = LocalSyncState.failed;
      } else {
        finalState = LocalSyncState.synced;
      }

      _status = SyncStatusModel(
        state: finalState,
        pendingItemsCount: report.failedCount + report.conflictCount,
        lastSyncedAt: report.lastAttemptAt ?? DateTime.now(),
        errorMessage: report.lastMessage,
      );
    } else {
      // Graceful local queue flush simulation for offline/test environments
      await Future.delayed(const Duration(milliseconds: 300));
      _status = SyncStatusModel(
        state: LocalSyncState.synced,
        pendingItemsCount: 0,
        lastSyncedAt: DateTime.now(),
      );
    }
    notifyListeners();
  }
}
