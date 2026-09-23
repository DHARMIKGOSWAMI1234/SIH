import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

class PairingValidationResult {
  final bool valid;
  final String pairingToken;
  final String caregiverId;
  final String caregiverName;
  final String relationship;
  final String permissions;
  final DateTime? expiresAt;
  final String? error;

  const PairingValidationResult({
    required this.valid,
    this.pairingToken = '',
    this.caregiverId = '',
    this.caregiverName = '',
    this.relationship = '',
    this.permissions = '',
    this.expiresAt,
    this.error,
  });

  factory PairingValidationResult.fromJson(Map<String, dynamic> json) {
    return PairingValidationResult(
      valid: json['valid'] as bool? ?? false,
      pairingToken: json['pairing_token'] as String? ?? '',
      caregiverId: json['caregiver_id'] as String? ?? '',
      caregiverName: json['caregiver_name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      permissions: json['permissions'] as String? ?? '',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
      error: json['error'] as String?,
    );
  }

  factory PairingValidationResult.failure(String message) {
    return PairingValidationResult(valid: false, error: message);
  }
}

class PairingConfirmationResult {
  final bool success;
  final String caregiverId;
  final String caregiverName;
  final String relationship;
  final String? error;

  const PairingConfirmationResult({
    required this.success,
    this.caregiverId = '',
    this.caregiverName = '',
    this.relationship = '',
    this.error,
  });

  factory PairingConfirmationResult.fromJson(Map<String, dynamic> json) {
    return PairingConfirmationResult(
      success: json['success'] as bool? ?? false,
      caregiverId: json['caregiver_id'] as String? ?? '',
      caregiverName: json['caregiver_name'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
      error: json['error'] as String?,
    );
  }

  factory PairingConfirmationResult.failure(String message) {
    return PairingConfirmationResult(success: false, error: message);
  }
}

class LinkedCaregiverInfo {
  final bool connected;
  final String? caregiverId;
  final String? caregiverName;
  final String? relationship;
  final String? linkedAt;

  const LinkedCaregiverInfo({
    required this.connected,
    this.caregiverId,
    this.caregiverName,
    this.relationship,
    this.linkedAt,
  });

  factory LinkedCaregiverInfo.fromJson(Map<String, dynamic> json) {
    return LinkedCaregiverInfo(
      connected: json['connected'] as bool? ?? false,
      caregiverId: json['caregiver_id'] as String?,
      caregiverName: json['caregiver_name'] as String?,
      relationship: json['relationship'] as String?,
      linkedAt: json['linked_at'] as String?,
    );
  }

  factory LinkedCaregiverInfo.empty() {
    return const LinkedCaregiverInfo(connected: false);
  }
}

class PatientPairingService {
  String _activeBaseUrl;
  final http.Client _client;

  PatientPairingService({
    String? baseUrl,
    http.Client? client,
  })  : _activeBaseUrl = baseUrl ?? ApiConfig.defaultBaseUrl,
        _client = client ?? http.Client();

  String get baseUrl => _activeBaseUrl;

  List<String> _getCandidates() {
    final list = <String>[];
    if (_activeBaseUrl.isNotEmpty) list.add(_activeBaseUrl);
    for (final c in ApiConfig.candidateBaseUrls) {
      if (!list.contains(c)) list.add(c);
    }
    if (!list.contains('http://localhost:8000')) list.add('http://localhost:8000');
    if (!list.contains('http://192.168.1.136:8000')) list.add('http://192.168.1.136:8000');
    if (!list.contains('http://10.0.2.2:8000')) list.add('http://10.0.2.2:8000');
    return list;
  }

  Future<http.Response> _postWithFallback(
    String path, {
    required Map<String, String> headers,
    required String body,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final candidates = _getCandidates();
    Object? lastError;

    for (final base in candidates) {
      try {
        final uri = Uri.parse('$base$path');
        final resp = await _client.post(uri, headers: headers, body: body).timeout(timeout);
        _activeBaseUrl = base;
        ApiConfig.runtimeBaseUrl = base;
        return resp;
      } catch (e) {
        lastError = e;
        continue;
      }
    }
    throw lastError ?? Exception('Unable to reach BANDHU backend on any candidate address');
  }

  Future<http.Response> _getWithFallback(
    String path, {
    required Map<String, String> headers,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final candidates = _getCandidates();
    Object? lastError;

    for (final base in candidates) {
      try {
        final uri = Uri.parse('$base$path');
        final resp = await _client.get(uri, headers: headers).timeout(timeout);
        _activeBaseUrl = base;
        ApiConfig.runtimeBaseUrl = base;
        return resp;
      } catch (e) {
        lastError = e;
        continue;
      }
    }
    throw lastError ?? Exception('Unable to reach BANDHU backend on any candidate address');
  }

  /// Parse QR payload or deep link URI into pairing parameters.
  /// Handles smriti://pair?token=...&code=... even if Android OS does not open it.
  static Map<String, String> parseQrPayload(String payload) {
    final trimmed = payload.trim();
    try {
      final uri = Uri.parse(trimmed);
      if (uri.queryParameters.isNotEmpty) {
        return uri.queryParameters;
      }
    } catch (_) {}

    // Fallback: Check if payload is raw 4-digit code
    if (trimmed.length == 4 && int.tryParse(trimmed) != null) {
      return {'code': trimmed};
    }
    // Fallback: Check if payload contains token=
    if (trimmed.contains('token=')) {
      final match = RegExp(r'token=([A-Za-z0-9_-]+)').firstMatch(trimmed);
      if (match != null) {
        return {'token': match.group(1)!};
      }
    }
    return {'token': trimmed};
  }

  /// Validate a pairing request with the backend before user confirmation.
  Future<PairingValidationResult> validatePairing({
    String? shortCode,
    String? pairingToken,
    String? qrPayload,
    String? authToken,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (shortCode != null && shortCode.trim().isNotEmpty) {
        body['short_code'] = shortCode.trim();
      }
      if (pairingToken != null && pairingToken.trim().isNotEmpty) {
        body['pairing_token'] = pairingToken.trim();
      }
      if (qrPayload != null && qrPayload.trim().isNotEmpty) {
        body['qr_payload'] = qrPayload.trim();
      }

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final resp = await _postWithFallback(
        '/api/v1/patient/pairing/validate',
        headers: headers,
        body: jsonEncode(body),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return PairingValidationResult.fromJson(data);
      } else {
        final data = jsonDecode(resp.body) as Map<String, dynamic>?;
        final detail = data?['detail'] as String? ?? 'Invalid code or connection expired';
        return PairingValidationResult.failure(detail);
      }
    } catch (e) {
      return PairingValidationResult.failure(
        'Backend connection error: Check that backend is running or Wi-Fi is connected. ($e)',
      );
    }
  }

  /// Confirm pairing and establish real link in patient_caregivers table.
  Future<PairingConfirmationResult> confirmPairing({
    required String pairingToken,
    required String patientId,
    String? authToken,
  }) async {
    try {
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final resp = await _postWithFallback(
        '/api/v1/patient/pairing/confirm',
        headers: headers,
        body: jsonEncode({
          'pairing_token': pairingToken,
          'patient_id': patientId,
        }),
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return PairingConfirmationResult.fromJson(data);
      } else {
        final data = jsonDecode(resp.body) as Map<String, dynamic>?;
        final detail = data?['detail'] as String? ?? 'Pairing confirmation failed';
        return PairingConfirmationResult.failure(detail);
      }
    } catch (e) {
      return PairingConfirmationResult.failure('Backend connection error: $e');
    }
  }

  /// Get active linked caregiver for this patient.
  Future<LinkedCaregiverInfo> getPatientCaregiver({
    required String patientId,
    String? authToken,
  }) async {
    try {
      final headers = <String, String>{};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final resp = await _getWithFallback(
        '/api/v1/patient/caregiver?patient_id=$patientId',
        headers: headers,
      );

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        return LinkedCaregiverInfo.fromJson(data);
      }
      return LinkedCaregiverInfo.empty();
    } catch (_) {
      return LinkedCaregiverInfo.empty();
    }
  }

  /// Disconnect caregiver.
  Future<bool> disconnectCaregiver({
    required String patientId,
    required String caregiverId,
    String? authToken,
  }) async {
    try {
      final headers = <String, String>{'Content-Type': 'application/json'};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final resp = await _postWithFallback(
        '/api/v1/patient/caregiver/disconnect',
        headers: headers,
        body: jsonEncode({
          'patient_id': patientId,
          'caregiver_id': caregiverId,
        }),
      );

      return resp.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
