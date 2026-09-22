import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/remote/sync_api_client.dart';
import 'package:patient_app/core/auth/auth_storage.dart';
import 'package:patient_app/core/auth/auth_service.dart';

void main() {
  late InMemoryAuthStorage storage;
  late AppDatabase db;
  late SmritiRepository repository;
  late SyncApiClient apiClient;
  late AuthService authService;

  setUp(() {
    storage = InMemoryAuthStorage();
    db = AppDatabase(NativeDatabase.memory());
    repository = SmritiRepository(db);
    apiClient = SyncApiClient();
    authService = AuthService(
      storage: storage,
      apiClient: apiClient,
      repository: repository,
    );
  });

  tearDown(() async {
    await db.close();
  });

  group('AuthStorage Tests', () {
    test('saves, retrieves, and clears tokens and user data', () async {
      await storage.saveToken('test-jwt-token-xyz');
      expect(await storage.getToken(), 'test-jwt-token-xyz');

      await storage.saveUserData({
        'userId': 'u-001',
        'email': 'test@example.com',
        'fullName': 'Test Patient',
        'role': 'PATIENT',
        'preferredLanguage': 'hi',
      });

      final user = await storage.getUserData();
      expect(user?['userId'], 'u-001');
      expect(user?['email'], 'test@example.com');

      await storage.clear();
      expect(await storage.getToken(), isNull);
      expect(await storage.getUserData(), isNull);
    });
  });

  group('AuthService Session & Lifecycle Tests', () {
    test('initial state is unauthenticated when storage is empty', () async {
      await authService.checkSession();
      expect(authService.status, AuthStatus.unauthenticated);
      expect(authService.isAuthenticated, isFalse);
      expect(authService.session, isNull);
    });

    test('offline session restoration succeeds when valid token exists', () async {
      await storage.saveToken('persisted-token-123');
      await storage.saveUserData({
        'userId': 'user-101',
        'patientId': 'patient-101',
        'email': 'offline_patient@example.com',
        'fullName': 'Offline Patient',
        'role': 'PATIENT',
        'preferredLanguage': 'as',
        'anonymousAlias': 'Aita',
      });

      await authService.checkSession();
      expect(authService.status, AuthStatus.authenticated);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.session?.email, 'offline_patient@example.com');
      expect(authService.session?.preferredLanguage, 'as');
      expect(authService.session?.anonymousAlias, 'Aita');
      expect(repository.activePatientId, 'patient-101');
    });

    test('logout clears session and storage without deleting local records', () async {
      // Setup authenticated state
      await storage.saveToken('token-to-clear');
      await storage.saveUserData({
        'userId': 'u-1',
        'patientId': 'p-1',
        'email': 'p1@example.com',
        'fullName': 'P1',
        'role': 'PATIENT',
      });
      await authService.checkSession();
      expect(authService.isAuthenticated, isTrue);

      // Create a local record
      final memId = await repository.insertMemory(
        title: 'Memory Created Before Logout',
        description: 'Should persist after logout',
      );

      // Perform logout
      await authService.logout();

      // Verify auth state is cleared
      expect(authService.status, AuthStatus.unauthenticated);
      expect(authService.session, isNull);
      expect(await storage.getToken(), isNull);
      expect(repository.activePatientId, isNull);

      // Verify local database record was NOT deleted!
      repository.setActivePatientId('p-1');
      final list = await repository.getMemories();
      expect(list.length, 1);
      expect(list.first.localId, memId);
    });

    test('handleTokenExpired clears token and sets informative message', () async {
      await storage.saveToken('expired-token');
      await storage.saveUserData({
        'userId': 'u-1',
        'email': 'p1@example.com',
        'fullName': 'P1',
        'role': 'PATIENT',
      });
      await authService.checkSession();

      await authService.handleTokenExpired();
      expect(authService.status, AuthStatus.unauthenticated);
      expect(authService.errorMessage, contains('Please sign in again'));
      expect(await storage.getToken(), isNull);
    });

    test('first-time registration requires backend and fails gracefully when offline', () async {
      // Offline/unreachable backend URL
      final offlineAuthService = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        baseUrl: 'http://127.0.0.1:9999', // Non-existent port
      );

      final success = await offlineAuthService.register(
        email: 'newuser@example.com',
        password: 'password123',
        fullName: 'New User',
      );

      expect(success, isFalse);
      expect(offlineAuthService.isAuthenticated, isFalse);
      expect(offlineAuthService.session, isNull);
      expect(offlineAuthService.errorMessage, 'Internet is required to create a new SMRITI account.');
    });

    test('SyncQueue and local records survive offline mode and session expiration', () async {
      // 1. Establish session
      await storage.saveToken('token-active');
      await storage.saveUserData({
        'userId': 'patient-abc',
        'patientId': 'patient-abc',
        'email': 'patient@example.com',
        'fullName': 'Patient ABC',
        'role': 'PATIENT',
      });
      await authService.checkSession();

      // 2. Insert a memory which also queues a sync operation
      final memId = await repository.insertMemory(
        title: 'Offline Garden Walk',
        description: 'Walked in the morning',
      );

      // Verify memory exists locally
      final memories = await repository.getMemories();
      expect(memories.any((m) => m.localId == memId), isTrue);

      // Verify SyncQueue has pending operation
      final pendingOps = await repository.getPendingQueueItems();
      expect(pendingOps.isNotEmpty, isTrue);
      expect(pendingOps.any((op) => op.entityType == 'Memories'), isTrue);

      // 3. Simulate session expiration
      await authService.handleTokenExpired();
      expect(authService.isAuthenticated, isFalse);

      // 4. Verify local memory and SyncQueue were NOT deleted!
      repository.setActivePatientId('patient-abc');
      final memoriesAfter = await repository.getMemories();
      expect(memoriesAfter.any((m) => m.localId == memId), isTrue);

      final pendingAfter = await repository.getPendingQueueItems();
      expect(pendingAfter.isNotEmpty, isTrue);
      expect(pendingAfter.any((op) => op.entityType == 'Memories'), isTrue);
    });

    test('registration surfaces 400/409 duplicate account error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({'detail': 'A user with this email already exists'}),
          400,
          headers: {'content-type': 'application/json'},
        );
      });

      final auth = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        httpClient: mockClient,
      );

      final ok = await auth.register(
        email: 'duplicate@example.com',
        password: 'password123',
        fullName: 'Duplicate User',
      );

      expect(ok, isFalse);
      expect(auth.errorMessage, 'A user with this email already exists');
    });

    test('registration surfaces 422 validation error', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'detail': [
              {'msg': 'String should have at least 6 characters', 'type': 'string_too_short'}
            ]
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      });

      final auth = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        httpClient: mockClient,
      );

      final ok = await auth.register(
        email: 'short@example.com',
        password: '123',
        fullName: 'Short Pass User',
      );

      expect(ok, isFalse);
      expect(auth.errorMessage, 'String should have at least 6 characters');
    });

    test('registration surfaces 500 server error', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final auth = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        httpClient: mockClient,
      );

      final ok = await auth.register(
        email: 'server_err@example.com',
        password: 'password123',
        fullName: 'Server Err User',
      );

      expect(ok, isFalse);
      expect(auth.errorMessage, 'Server error. Please try again later.');
    });

    test('registration succeeds and creates session on 201 Created', () async {
      final mockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'access_token': 'new-jwt-token',
            'token_type': 'bearer',
            'user_id': 'new-u-123',
            'role': 'PATIENT',
            'patient_id': 'new-p-123',
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final auth = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        httpClient: mockClient,
      );

      final ok = await auth.register(
        email: 'newpatient@example.com',
        password: 'password123',
        fullName: 'New Patient',
      );

      expect(ok, isTrue);
      expect(auth.isAuthenticated, isTrue);
      expect(auth.session?.userId, 'new-u-123');
      expect(auth.session?.patientId, 'new-p-123');
      expect(auth.session?.token, 'new-jwt-token');
    });
  });
}

