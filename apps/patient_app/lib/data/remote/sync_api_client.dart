/// Remote API client for synchronization with SMRITI FastAPI backend.
library;
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class RemoteSyncResult {
  final String operationId;
  final String status; // synced, already_processed, conflict, rejected
  final String? serverId;
  final DateTime? serverUpdatedAt;
  final String? message;
  final Map<String, dynamic>? conflictData;

  const RemoteSyncResult({
    required this.operationId,
    required this.status,
    this.serverId,
    this.serverUpdatedAt,
    this.message,
    this.conflictData,
  });

  factory RemoteSyncResult.fromJson(Map<String, dynamic> json) {
    return RemoteSyncResult(
      operationId: json['operation_id'] as String? ?? '',
      status: json['status'] as String? ?? 'rejected',
      serverId: json['server_id'] as String?,
      serverUpdatedAt: json['server_updated_at'] != null
          ? DateTime.tryParse(json['server_updated_at'].toString())
          : null,
      message: json['message'] as String?,
      conflictData: json['conflict_data'] as Map<String, dynamic>?,
    );
  }
}

class RemoteSyncBatchResponse {
  final List<RemoteSyncResult> results;
  final int processedCount;
  final DateTime? serverTime;
  final bool isSuccess;
  final String? error;

  const RemoteSyncBatchResponse({
    required this.results,
    required this.processedCount,
    this.serverTime,
    this.isSuccess = true,
    this.error,
  });
}

class SyncApiClient {
  final String baseUrl;
  final http.Client _client;
  String? _authToken;

  SyncApiClient({
    this.baseUrl = 'http://localhost:8000',
    http.Client? client,
  }) : _client = client ?? http.Client();

  void setAuthToken(String? token) {
    _authToken = token;
  }

  Future<RemoteSyncBatchResponse> sendBatchSync({
    required String patientId,
    required List<Map<String, dynamic>> items,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/sync');
    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (_authToken != null && _authToken!.isNotEmpty)
        'Authorization': 'Bearer $_authToken',
    };

    final body = jsonEncode({
      'patient_id': patientId,
      'items': items,
    });

    try {
      final response = await _client
          .post(uri, headers: headers, body: body)
          .timeout(timeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final rawResults = decoded['results'] as List<dynamic>? ?? [];
        final results = rawResults
            .map((r) => RemoteSyncResult.fromJson(r as Map<String, dynamic>))
            .toList();

        return RemoteSyncBatchResponse(
          results: results,
          processedCount: decoded['processed_count'] as int? ?? results.length,
          serverTime: decoded['server_time'] != null
              ? DateTime.tryParse(decoded['server_time'].toString())
              : null,
          isSuccess: true,
        );
      } else {
        return RemoteSyncBatchResponse(
          results: const [],
          processedCount: 0,
          isSuccess: false,
          error: 'HTTP ${response.statusCode}: ${response.body}',
        );
      }
    } on TimeoutException {
      return const RemoteSyncBatchResponse(
        results: [],
        processedCount: 0,
        isSuccess: false,
        error: 'Network request timed out',
      );
    } catch (e) {
      return RemoteSyncBatchResponse(
        results: const [],
        processedCount: 0,
        isSuccess: false,
        error: 'Connection error: $e',
      );
    }
  }

  void dispose() {
    _client.close();
  }
}
