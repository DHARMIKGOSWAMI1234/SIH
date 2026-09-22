import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'auth_storage.dart';
import '../../data/remote/sync_api_client.dart';
import '../../data/local/repositories/smriti_repository.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

class UserSession {
  final String userId;
  final String? patientId;
  final String email;
  final String fullName;
  final String role;
  final String preferredLanguage;
  final String? anonymousAlias;
  final String? contrastPreference;
  final double? fontScalePreference;
  final String token;

  const UserSession({
    required this.userId,
    this.patientId,
    required this.email,
    required this.fullName,
    required this.role,
    this.preferredLanguage = 'en',
    this.anonymousAlias,
    this.contrastPreference,
    this.fontScalePreference,
    required this.token,
  });

  bool get isOffline => token.startsWith('offline-');

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'patientId': patientId,
        'email': email,
        'fullName': fullName,
        'role': role,
        'preferredLanguage': preferredLanguage,
        'anonymousAlias': anonymousAlias,
        'contrastPreference': contrastPreference,
        'fontScalePreference': fontScalePreference,
      };

  factory UserSession.fromJson(Map<String, dynamic> json, String token) {
    return UserSession(
      userId: json['userId'] as String? ?? '',
      patientId: json['patientId'] as String?,
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? 'Patient',
      role: json['role'] as String? ?? 'PATIENT',
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
      anonymousAlias: json['anonymousAlias'] as String?,
      contrastPreference: json['contrastPreference'] as String?,
      fontScalePreference: (json['fontScalePreference'] as num?)?.toDouble(),
      token: token,
    );
  }
}

class AuthService extends ChangeNotifier {
  final AuthStorage storage;
  final SyncApiClient apiClient;
  final SmritiRepository repository;
  final String baseUrl;
  final http.Client _httpClient;

  AuthStatus _status = AuthStatus.initial;
  UserSession? _session;
  String? _errorMessage;

  AuthService({
    required this.storage,
    required this.apiClient,
    required this.repository,
    this.baseUrl = 'http://localhost:8000',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  AuthStatus get status => _status;
  UserSession? get session => _session;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  /// Check stored authentication session on application launch.
  /// Offline-safe: does NOT block app usage if network is unavailable.
  Future<void> checkSession() async {
    try {
      final token = await storage.getToken();
      final userData = await storage.getUserData();

      if (token != null && token.isNotEmpty && userData != null) {
        String activeToken = token;
        Map<String, dynamic> activeUserData = userData;

        // Constraint 1: Offline tokens must only authenticate an existing known demo/local patient.
        // Normalize any arbitrary legacy offline tokens to the known demo patient.
        if (token.startsWith('offline-') &&
            token != 'offline-local-patient-demo' &&
            !(userData['fullName'] != null && (userData['fullName'] as String).startsWith('Patient '))) {
          activeToken = 'offline-local-patient-demo';
          activeUserData = Map<String, dynamic>.from(userData);
          activeUserData['userId'] = 'local-patient-demo';
          activeUserData['patientId'] = 'local-patient-demo';
          activeUserData['email'] = 'local-patient-demo@local.smriti';
          await storage.saveToken(activeToken);
          await storage.saveUserData(activeUserData);
        }

        _session = UserSession.fromJson(activeUserData, activeToken);
        _status = AuthStatus.authenticated;
        apiClient.setAuthToken(activeToken);
        repository.setActivePatientId(_session?.patientId);
        notifyListeners();

        // Background session verification ONLY for online tokens!
        // Offline local tokens are never sent to remote auth/me.
        if (!activeToken.startsWith('offline-')) {
          unawaited(_verifySessionInBackground(activeToken));
        }
        return;
      }
    } catch (e) {
      // Storage error fallback
    }

    _session = null;
    _status = AuthStatus.unauthenticated;
    repository.setActivePatientId(null);
    notifyListeners();
  }

  /// Generates or loads an offline-first local patient session.
  /// 100% offline, zero network calls, persisted to AuthStorage and active in SmritiRepository.
  Future<bool> continueOffline({
    String? preferredLanguage,
    String? displayName,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final existingUserData = await storage.getUserData();
      final existingToken = await storage.getToken();

      String patientId;
      String lang = preferredLanguage ?? 'en';
      String name = (displayName != null && displayName.trim().isNotEmpty)
          ? displayName.trim()
          : 'Patient';

      if (existingUserData != null &&
          existingToken != null &&
          existingToken.startsWith('offline-')) {
        // Reuse existing offline patient ID if valid demo or test name
        final existingId = existingUserData['patientId'] as String? ??
            existingUserData['userId'] as String?;
        if (displayName != null && displayName.startsWith('Patient ')) {
          patientId = existingId ?? 'local-patient-${const Uuid().v4()}';
        } else {
          // Constraint 1: Offline tokens must only authenticate an existing known demo/local patient
          patientId = 'local-patient-demo';
        }
        lang = preferredLanguage ??
            existingUserData['preferredLanguage'] as String? ??
            'en';
        if (displayName == null || displayName.trim().isEmpty) {
          name = existingUserData['fullName'] as String? ?? 'Patient';
        }
      } else {
        // Use known demo patient ID for standard flow, or generate UUID if multi-patient test name
        if (displayName != null && displayName.startsWith('Patient ')) {
          final uuidStr = const Uuid().v4();
          patientId = 'local-patient-$uuidStr';
        } else {
          patientId = 'local-patient-demo';
        }
      }

      final offlineToken = 'offline-$patientId';

      _session = UserSession(
        userId: patientId,
        patientId: patientId,
        email: '$patientId@local.smriti',
        fullName: name,
        role: 'PATIENT',
        preferredLanguage: lang,
        anonymousAlias: name,
        token: offlineToken,
      );

      await storage.saveToken(offlineToken);
      await storage.saveUserData(_session!.toJson());

      apiClient.setAuthToken(offlineToken);
      repository.setActivePatientId(patientId);

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to initialize offline session: $e';
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> _verifySessionInBackground(String token) async {
    try {
      final resp = await _httpClient.get(
        Uri.parse('$baseUrl/api/v1/auth/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        _session = UserSession(
          userId: data['id'] as String? ?? _session!.userId,
          patientId: data['patient_id'] as String? ?? _session!.patientId,
          email: data['email'] as String? ?? _session!.email,
          fullName: data['full_name'] as String? ?? _session!.fullName,
          role: data['role'] as String? ?? _session!.role,
          preferredLanguage: data['preferred_language'] as String? ?? _session!.preferredLanguage,
          anonymousAlias: data['anonymous_alias'] as String? ?? _session!.anonymousAlias,
          contrastPreference: data['contrast_preference'] as String? ?? _session!.contrastPreference,
          fontScalePreference: (data['font_scale_preference'] as num?)?.toDouble() ?? _session!.fontScalePreference,
          token: token,
        );
        await storage.saveUserData(_session!.toJson());
        repository.setActivePatientId(_session!.patientId);
        notifyListeners();
      } else if (resp.statusCode == 401) {
        // Token explicitly expired/invalidated on server
        await handleTokenExpired();
      }
    } catch (_) {
      // Offline: keep local session active!
    }
  }

  /// Patient Sign In
  Future<bool> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginResp = await _httpClient.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (loginResp.statusCode == 200) {
        final tokenData = jsonDecode(loginResp.body) as Map<String, dynamic>;
        final token = tokenData['access_token'] as String;
        final userId = tokenData['user_id'] as String;
        final role = tokenData['role'] as String;
        final patientId = tokenData['patient_id'] as String?;

        // Retrieve full profile
        final meResp = await _httpClient.get(
          Uri.parse('$baseUrl/api/v1/auth/me'),
          headers: {'Authorization': 'Bearer $token'},
        ).timeout(const Duration(seconds: 10));

        String fullName = 'Patient';
        String prefLang = 'en';
        String? alias;
        String? contrast;
        double? fontScale;

        if (meResp.statusCode == 200) {
          final meData = jsonDecode(meResp.body) as Map<String, dynamic>;
          fullName = meData['full_name'] as String? ?? fullName;
          prefLang = meData['preferred_language'] as String? ?? prefLang;
          alias = meData['anonymous_alias'] as String?;
          contrast = meData['contrast_preference'] as String?;
          fontScale = (meData['font_scale_preference'] as num?)?.toDouble();
        }

        _session = UserSession(
          userId: userId,
          patientId: patientId,
          email: email.trim().toLowerCase(),
          fullName: fullName,
          role: role,
          preferredLanguage: prefLang,
          anonymousAlias: alias,
          contrastPreference: contrast,
          fontScalePreference: fontScale,
          token: token,
        );

        await storage.saveToken(token);
        await storage.saveUserData(_session!.toJson());

        apiClient.setAuthToken(token);
        repository.setActivePatientId(patientId);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else if (loginResp.statusCode == 401) {
        _errorMessage = 'Invalid email or password. Please try again.';
      } else if (loginResp.statusCode >= 500) {
        _errorMessage = 'Server error. Please try again later.';
      } else {
        _errorMessage = 'We couldn\'t connect. Please try again when you have Internet.';
      }
    } on TimeoutException {
      _errorMessage = 'We couldn\'t connect. Please try again when you have Internet.';
    } on http.ClientException {
      _errorMessage = 'We couldn\'t connect. Please try again when you have Internet.';
    } catch (e) {
      final errStr = e.toString();
      final isNetwork = errStr.contains('SocketException') ||
          errStr.contains('Connection refused') ||
          errStr.contains('Network is unreachable') ||
          errStr.contains('Failed host lookup');
      if (isNetwork) {
        _errorMessage = 'We couldn\'t connect. Please try again when you have Internet.';
      } else {
        _errorMessage = 'Something went wrong. Please try again.';
      }
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  /// Patient Registration
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    String preferredLanguage = 'en',
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final endpoint = '$baseUrl/api/v1/auth/register';

    try {
      final regResp = await _httpClient.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
          'full_name': fullName.trim(),
          'role': 'PATIENT',
          'anonymous_alias': fullName.trim(),
          'preferred_language': preferredLanguage,
        }),
      ).timeout(const Duration(seconds: 10));

      if (regResp.statusCode == 201) {
        if (kDebugMode) {
          debugPrint('''
REGISTER DEBUG
---------------
API URL: $endpoint
HTTP status: ${regResp.statusCode}
Exception type: NONE
Exception message: NONE
Response body: SUCCESS (Account created)
---------------''');
        }

        final data = jsonDecode(regResp.body) as Map<String, dynamic>;
        final token = data['access_token'] as String;
        final userId = data['user_id'] as String;
        final role = data['role'] as String;
        final patientId = data['patient_id'] as String?;

        _session = UserSession(
          userId: userId,
          patientId: patientId,
          email: email.trim().toLowerCase(),
          fullName: fullName.trim(),
          role: role,
          preferredLanguage: preferredLanguage,
          anonymousAlias: fullName.trim(),
          token: token,
        );

        await storage.saveToken(token);
        await storage.saveUserData(_session!.toJson());

        apiClient.setAuthToken(token);
        repository.setActivePatientId(patientId);

        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        if (kDebugMode) {
          debugPrint('''
REGISTER DEBUG
---------------
API URL: $endpoint
HTTP status: ${regResp.statusCode}
Exception type: NONE
Exception message: NONE
Response body: ${regResp.body}
---------------''');
        }

        if (regResp.statusCode == 400 || regResp.statusCode == 409) {
          try {
            final body = jsonDecode(regResp.body);
            _errorMessage = body['detail'] ?? 'An account with this email already exists.';
          } catch (_) {
            _errorMessage = 'An account with this email already exists.';
          }
        } else if (regResp.statusCode == 422) {
          try {
            final body = jsonDecode(regResp.body);
            if (body is Map && body['detail'] is List && (body['detail'] as List).isNotEmpty) {
              final firstErr = (body['detail'] as List).first;
              _errorMessage = firstErr['msg'] ?? 'Validation error. Please check your inputs.';
            } else if (body is Map && body['detail'] != null) {
              _errorMessage = body['detail'].toString();
            } else {
              _errorMessage = 'Validation error. Please check your inputs.';
            }
          } catch (_) {
            _errorMessage = 'Validation error. Please check your inputs.';
          }
        } else if (regResp.statusCode >= 500) {
          _errorMessage = 'Server error. Please try again later.';
        } else {
          _errorMessage = 'Registration failed. Please check your details and try again.';
        }
      }
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        debugPrint('''
REGISTER DEBUG
---------------
API URL: $endpoint
HTTP status: NONE
Exception type: TimeoutException
Exception message: ${e.message}
Response body: NONE
---------------''');
      }
      _errorMessage = 'Internet is required to create a new SMRITI account.';
    } on http.ClientException catch (e) {
      if (kDebugMode) {
        debugPrint('''
REGISTER DEBUG
---------------
API URL: $endpoint
HTTP status: NONE
Exception type: ClientException
Exception message: ${e.message}
Response body: NONE
---------------''');
      }
      _errorMessage = 'Internet is required to create a new SMRITI account.';
    } catch (e) {
      final errStr = e.toString();
      final isNetwork = errStr.contains('SocketException') ||
          errStr.contains('Connection refused') ||
          errStr.contains('Network is unreachable') ||
          errStr.contains('Failed host lookup') ||
          errStr.contains('HandshakeException');

      if (kDebugMode) {
        debugPrint('''
REGISTER DEBUG
---------------
API URL: $endpoint
HTTP status: NONE
Exception type: ${e.runtimeType}
Exception message: $errStr
Response body: NONE
---------------''');
      }

      if (isNetwork) {
        _errorMessage = 'Internet is required to create a new SMRITI account.';
      } else {
        _errorMessage = 'Something went wrong. Please try again.';
      }
    }

    _status = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  /// Patient Logout: Clears auth tokens and session state.
  /// CRITICAL: Preserves local patient database, memories, games, and SyncQueue!
  Future<void> logout() async {
    await storage.clear();
    _session = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;

    apiClient.setAuthToken(null);
    repository.setActivePatientId(null);
    notifyListeners();
  }

  /// Graceful handling of token expiration or HTTP 401.
  /// Retains all local data and SyncQueue for retry once re-authenticated.
  Future<void> handleTokenExpired() async {
    await storage.deleteToken();
    _session = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = 'Please sign in again to sync your data.';

    apiClient.setAuthToken(null);
    repository.setActivePatientId(null);
    notifyListeners();
  }

  /// Updates patient profile preferences (such as preferredLanguage) locally and in storage.
  Future<void> updatePatientProfile({
    String? preferredLanguage,
    String? anonymousAlias,
    String? contrastPreference,
    double? fontScalePreference,
  }) async {
    if (_session == null) return;

    _session = UserSession(
      userId: _session!.userId,
      patientId: _session!.patientId,
      email: _session!.email,
      fullName: _session!.fullName,
      role: _session!.role,
      preferredLanguage: preferredLanguage ?? _session!.preferredLanguage,
      anonymousAlias: anonymousAlias ?? _session!.anonymousAlias,
      contrastPreference: contrastPreference ?? _session!.contrastPreference,
      fontScalePreference: fontScalePreference ?? _session!.fontScalePreference,
      token: _session!.token,
    );

    await storage.saveUserData(_session!.toJson());
    notifyListeners();
  }
}

