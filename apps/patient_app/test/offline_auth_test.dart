import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/core/config/api_config.dart';
import 'package:patient_app/core/auth/auth_storage.dart';
import 'package:patient_app/core/auth/auth_service.dart';
import 'package:patient_app/core/widgets/smriti_app_shell.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/remote/sync_api_client.dart';
import 'package:patient_app/features/auth/login_screen.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_question.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_recognition_state.dart';
import 'package:patient_app/features/games/memory_match/models/memory_match_state.dart';
import 'package:patient_app/l10n/locale_notifier.dart';

void main() {
  late AppDatabase db;
  late SmritiRepository repository;
  late InMemoryAuthStorage storage;
  late SyncApiClient apiClient;
  late AuthService authService;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SmritiRepository(db);
    storage = InMemoryAuthStorage();
    apiClient = SyncApiClient();
    authService = AuthService(
      storage: storage,
      apiClient: apiClient,
      repository: repository,
      baseUrl: 'http://127.0.0.1:9999', // Dummy unreachable address
    );
  });

  tearDown(() async {
    ApiConfig.runtimeBaseUrl = null;
    await db.close();
  });

  group('A. Continue Offline Tests', () {
    test('creates local session, sets repository active patient, and makes zero network calls', () async {
      int httpCallCount = 0;
      final mockClient = MockClient((request) async {
        httpCallCount++;
        return http.Response('error', 500);
      });

      final offlineService = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        httpClient: mockClient,
      );

      final success = await offlineService.continueOffline(
        preferredLanguage: 'hi',
        displayName: 'Grandma Devi',
      );

      expect(success, isTrue);
      expect(offlineService.isAuthenticated, isTrue);
      expect(offlineService.session, isNotNull);
      expect(offlineService.session!.isOffline, isTrue);
      expect(offlineService.session!.patientId, startsWith('local-patient-'));
      expect(offlineService.session!.fullName, 'Grandma Devi');
      expect(offlineService.session!.role, 'PATIENT');
      expect(offlineService.session!.preferredLanguage, 'hi');
      expect(offlineService.session!.token, startsWith('offline-local-patient-'));

      // Verify repository active patient is set
      expect(repository.activePatientId, offlineService.session!.patientId);

      // Verify zero network calls were made
      expect(httpCallCount, 0, reason: 'continueOffline must never make network requests');

      // Verify stored in storage
      final storedToken = await storage.getToken();
      final storedUserData = await storage.getUserData();
      expect(storedToken, offlineService.session!.token);
      expect(storedUserData?['fullName'], 'Grandma Devi');
    });

    testWidgets('LoginScreen Continue Offline button taps and navigates directly to SmritiAppShell', (tester) async {
      final locNotifier = LocaleNotifier(authStorage: storage, authService: authService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: db),
            Provider<SmritiRepository>.value(value: repository),
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<LocaleNotifier>.value(value: locNotifier),
          ],
          child: MaterialApp(
            theme: SmritiTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify "Continue Offline" button is rendered with high contrast and touch target >= 64dp
      final offlineBtn = find.widgetWithText(ElevatedButton, 'Continue Offline');
      expect(offlineBtn, findsOneWidget);

      final size = tester.getSize(offlineBtn);
      expect(size.height, greaterThanOrEqualTo(64.0), reason: 'Touch target must be >= 64dp for elderly accessibility');

      // Ensure visible and tap "Continue Offline"
      await tester.ensureVisible(offlineBtn);
      await tester.pumpAndSettle();
      await tester.tap(offlineBtn);
      await tester.pumpAndSettle();

      // Verify navigated cleanly to SmritiAppShell
      expect(find.byType(SmritiAppShell), findsOneWidget);
      expect(find.byType(LoginScreen), findsNothing);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.session!.isOffline, isTrue);
    });

    testWidgets('LoginScreen Continue Offline renders in Hindi and Assamese without overflow', (tester) async {
      final locNotifier = LocaleNotifier(authStorage: storage, authService: authService);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppDatabase>.value(value: db),
            Provider<SmritiRepository>.value(value: repository),
            ChangeNotifierProvider<AuthService>.value(value: authService),
            ChangeNotifierProvider<LocaleNotifier>.value(value: locNotifier),
          ],
          child: MaterialApp(
            theme: SmritiTheme.lightTheme,
            home: const LoginScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to New Patient to access Language dropdown
      await tester.tap(find.text('New Patient'));
      await tester.pumpAndSettle();

      // Select Hindi
      final dropdown = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('हिन्दी').last);
      await tester.pumpAndSettle();

      expect(find.text('बिना इंटरनेट के शुरू करें'), findsOneWidget);
      expect(find.text('या'), findsOneWidget);

      // Select Assamese
      await tester.ensureVisible(dropdown);
      await tester.tap(dropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('অসমীয়া').last);
      await tester.pumpAndSettle();

      expect(find.text('ইণ্টাৰনেট অবিহনে আৰম্ভ কৰক'), findsOneWidget);
      expect(find.text('বা'), findsOneWidget);
    });
  });

  group('B. Offline Restart Tests', () {
    test('local offline session survives app restart without network', () async {
      // 1. First run: patient chooses offline mode
      await authService.continueOffline(preferredLanguage: 'as', displayName: 'Borah Koka');
      final originalPatientId = authService.session!.patientId;
      expect(originalPatientId, startsWith('local-patient-'));

      // 2. Simulate app kill and restart:
      // Create fresh AuthService instance with the same storage and repository, but dummy unreachable network
      int bgHttpCalls = 0;
      final restartMockClient = MockClient((request) async {
        bgHttpCalls++;
        throw Exception('No network should be called on offline session check');
      });

      final restartedAuthService = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        baseUrl: 'http://127.0.0.1:9999',
        httpClient: restartMockClient,
      );

      // 3. App startup calls checkSession()
      await restartedAuthService.checkSession();

      // 4. Verify session is restored immediately as authenticated
      expect(restartedAuthService.isAuthenticated, isTrue);
      expect(restartedAuthService.session, isNotNull);
      expect(restartedAuthService.session!.patientId, originalPatientId);
      expect(restartedAuthService.session!.fullName, 'Borah Koka');
      expect(restartedAuthService.session!.preferredLanguage, 'as');
      expect(restartedAuthService.session!.isOffline, isTrue);

      // Verify repository active patient is restored
      expect(repository.activePatientId, originalPatientId);

      // Verify zero background verification HTTP calls were made
      expect(bgHttpCalls, 0, reason: 'Offline session check must never call /auth/me in background');
    });
  });

  group('C & D. Online Login and Registration Tests', () {
    test('existing online login succeeds when valid server response is received', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          return http.Response(
            jsonEncode({
              'access_token': 'jwt-server-token-123',
              'user_id': 'user-server-456',
              'role': 'PATIENT',
              'patient_id': 'patient-server-789',
            }),
            200,
          );
        }
        if (request.url.path.endsWith('/me')) {
          return http.Response(
            jsonEncode({
              'id': 'user-server-456',
              'patient_id': 'patient-server-789',
              'email': 'online@smriti.care',
              'full_name': 'Online Patient',
              'role': 'PATIENT',
              'preferred_language': 'en',
            }),
            200,
          );
        }
        return http.Response('Not found', 404);
      });

      final onlineAuth = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        httpClient: mockClient,
      );

      final success = await onlineAuth.login('online@smriti.care', 'password123');
      expect(success, isTrue);
      expect(onlineAuth.isAuthenticated, isTrue);
      expect(onlineAuth.session!.token, 'jwt-server-token-123');
      expect(onlineAuth.session!.patientId, 'patient-server-789');
      expect(onlineAuth.session!.isOffline, isFalse);
      expect(repository.activePatientId, 'patient-server-789');
    });

    test('existing online registration succeeds and creates session on 201 Created', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/register')) {
          return http.Response(
            jsonEncode({
              'access_token': 'jwt-new-token-999',
              'user_id': 'user-new-001',
              'role': 'PATIENT',
              'patient_id': 'patient-new-001',
            }),
            201,
          );
        }
        return http.Response('Not found', 404);
      });

      final onlineAuth = AuthService(
        storage: storage,
        apiClient: apiClient,
        repository: repository,
        httpClient: mockClient,
      );

      final success = await onlineAuth.register(
        email: 'newpatient@smriti.care',
        password: 'securePassword123',
        fullName: 'New Registered Patient',
        preferredLanguage: 'hi',
      );

      expect(success, isTrue);
      expect(onlineAuth.isAuthenticated, isTrue);
      expect(onlineAuth.session!.token, 'jwt-new-token-999');
      expect(onlineAuth.session!.patientId, 'patient-new-001');
      expect(onlineAuth.session!.isOffline, isFalse);
    });
  });

  group('E. Multi-Patient Data Isolation for Offline Profiles', () {
    test('offline patient data stays associated with correct patient ID and is isolated', () async {
      // 1. Patient Alpha continues offline
      await authService.continueOffline(preferredLanguage: 'en', displayName: 'Patient Alpha');
      final alphaId = authService.session!.patientId!;

      // 2. Patient Alpha adds a memory
      final memAlpha = await repository.insertMemory(
        title: 'Alpha Harvest Festival',
        description: 'Bihu dance in courtyard',
        category: 'traditions',
      );
      expect(memAlpha, isNotEmpty);

      // Verify Alpha sees memory
      final alphaList = await repository.getMemories();
      expect(alphaList.length, 1);
      expect(alphaList.first.title, 'Alpha Harvest Festival');

      // 3. Patient Alpha logs out (clears session, leaves DB intact)
      await authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(repository.activePatientId, isNull);

      // 4. Patient Beta starts offline
      // Clear in-memory storage to simulate new device profile
      final betaStorage = InMemoryAuthStorage();
      final betaAuth = AuthService(
        storage: betaStorage,
        apiClient: apiClient,
        repository: repository,
      );

      await betaAuth.continueOffline(preferredLanguage: 'as', displayName: 'Patient Beta');
      final betaId = betaAuth.session!.patientId!;
      expect(betaId, isNot(alphaId));

      // 5. Patient Beta CANNOT see Patient Alpha's memory
      final betaList = await repository.getMemories();
      expect(betaList.isEmpty, isTrue, reason: 'Patient Beta must not see Patient Alpha personal data');

      final directQueryBeta = await repository.getMemoryById(memAlpha);
      expect(directQueryBeta, isNull, reason: 'Direct query must enforce owner isolation');

      // 6. Patient Beta adds their own memory
      await repository.insertMemory(
        title: 'Beta Mountain Trip',
        description: 'Trip to Shillong peak',
        category: 'places',
      );

      final betaList2 = await repository.getMemories();
      expect(betaList2.length, 1);
      expect(betaList2.first.title, 'Beta Mountain Trip');

      // 7. Switch back to Alpha
      repository.setActivePatientId(alphaId);
      final alphaRestored = await repository.getMemories();
      expect(alphaRestored.length, 1);
      expect(alphaRestored.first.title, 'Alpha Harvest Festival');
    });
  });

  group('F & G. Offline Gameplay Persistence (Pattern Recognition & Memory Match)', () {
    test('offline Pattern Recognition session is persisted to Drift and SyncQueue without network', () async {
      await authService.continueOffline(displayName: 'Game Player');

      // Generate pattern questions offline
      final questions = PatternQuestionGenerator.generateQuestions(
        difficulty: PatternDifficulty.easy,
        count: 4,
        optionCount: 2,
      );
      expect(questions.length, 4);
      expect(questions.every((q) => q.isValid()), isTrue);

      final now = DateTime.now();
      // Complete session
      final metrics = PatternRecognitionMetrics(
        difficulty: PatternDifficulty.easy,
        totalQuestions: 4,
        correctAnswers: 4,
        mistakes: 0,
        hintCount: 0,
        accuracy: 1.0,
        score: 400,
        startedAt: now.subtract(const Duration(seconds: 45)),
        completedAt: now,
        roundRecords: [],
      );

      await repository.recordGameSession(
        gameType: 'pattern_recognition',
        score: metrics.score,
        accuracy: metrics.accuracy,
        mistakes: metrics.mistakes,
        responseTimeMs: 2500.0,
        difficulty: 1,
        hintCount: metrics.hintCount,
        startedAt: metrics.startedAt,
        completedAt: metrics.completedAt,
      );

      // Verify persisted in Drift SQLite
      final sessions = await repository.getRecentSessions();
      expect(sessions.length, 1);
      expect(sessions.first.gameType, 'pattern_recognition');
      expect(sessions.first.score, 400);
      expect(sessions.first.syncStatus, 'pending');

      // Verify enqueued in SyncQueue
      final queueItems = await repository.getPendingQueueItems();
      expect(queueItems.length, 1);
      expect(queueItems.first.entityType, 'GameSessions');
      expect(queueItems.first.entityId, sessions.first.localId);
      expect(queueItems.first.status, 'pending');
    });

    test('offline Memory Match session is persisted to Drift and SyncQueue without network', () async {
      await authService.continueOffline(displayName: 'Card Matcher');

      final now = DateTime.now();
      final metrics = MemoryMatchMetrics(
        difficulty: MemoryMatchDifficulty.easy,
        totalPairs: 3,
        matchedPairs: 3,
        totalAttempts: 3,
        mistakes: 0,
        hintCount: 0,
        accuracy: 1.0,
        score: 300,
        startedAt: now.subtract(const Duration(seconds: 30)),
        completedAt: now,
      );

      await repository.recordGameSession(
        gameType: 'memory_match',
        score: metrics.score,
        accuracy: metrics.accuracy,
        mistakes: metrics.mistakes,
        responseTimeMs: metrics.responseTimeMs,
        difficulty: 1,
        hintCount: metrics.hintCount,
        startedAt: metrics.startedAt,
        completedAt: metrics.completedAt,
      );

      final sessions = await repository.getRecentSessions();
      expect(sessions.length, 1);
      expect(sessions.first.gameType, 'memory_match');
      expect(sessions.first.score, metrics.score);
      expect(sessions.first.syncStatus, 'pending');
    });
  });

  group('H. Physical Android USB & Emulator API Configuration Tests', () {
    test('ApiConfig defaultBaseUrl respects runtime override, emulator, and localhost adb reverse', () {
      // 1. Default without overrides
      expect(ApiConfig.defaultBaseUrl, isNotEmpty);

      // 2. Runtime override
      ApiConfig.runtimeBaseUrl = 'http://localhost:8000';
      expect(ApiConfig.defaultBaseUrl, 'http://localhost:8000');

      ApiConfig.runtimeBaseUrl = 'http://192.168.1.50:8000';
      expect(ApiConfig.defaultBaseUrl, 'http://192.168.1.50:8000');

      ApiConfig.runtimeBaseUrl = null; // reset
    });
  });
}
