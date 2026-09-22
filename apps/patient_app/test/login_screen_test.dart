import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/remote/sync_api_client.dart';
import 'package:patient_app/core/auth/auth_storage.dart';
import 'package:patient_app/core/auth/auth_service.dart';
import 'package:patient_app/features/auth/login_screen.dart';

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
    );
  });

  tearDown(() async {
    await db.close();
  });

  Widget buildTestWidget({Size size = const Size(390.0, 844.0)}) {
    return MediaQuery(
      data: MediaQueryData(size: size),
      child: MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          Provider<SmritiRepository>.value(value: repository),
          ChangeNotifierProvider<AuthService>.value(value: authService),
        ],
        child: MaterialApp(
          theme: SmritiTheme.lightTheme,
          home: const LoginScreen(),
        ),
      ),
    );
  }

  testWidgets('LoginScreen renders elderly-first UI with large touch targets', (tester) async {
    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('Patient Sign In'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);

    // Verify mode toggle buttons exist
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('New Patient'), findsOneWidget);

    // Verify inputs exist
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);

    // Verify primary action button with elderly-first touch target (>= 56dp)
    final submitButton = find.widgetWithText(ElevatedButton, 'Sign In to SMRITI');
    expect(submitButton, findsOneWidget);
    final size = tester.getSize(submitButton);
    expect(size.height, greaterThanOrEqualTo(56.0), reason: 'Submit button must meet elderly touch target >= 56dp');

    // Switch to Registration mode
    await tester.tap(find.text('New Patient'));
    await tester.pumpAndSettle();

    // Verify Registration fields appeared
    expect(find.text('Preferred Name / Alias'), findsOneWidget);
    expect(find.text('Preferred Language'), findsOneWidget);
    expect(find.text('Complete Registration'), findsOneWidget);
  });

  final testWidths = [320.0, 360.0, 390.0, 412.0, 430.0];

  for (final width in testWidths) {
    testWidgets('LoginScreen in Sign In mode renders with zero overflow at ${width.toInt()}dp', (tester) async {
      await tester.pumpWidget(buildTestWidget(size: Size(width, 800.0)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Sign In to SMRITI'), findsOneWidget);
    });

    testWidgets('LoginScreen in New Patient mode renders with zero overflow at ${width.toInt()}dp', (tester) async {
      await tester.pumpWidget(buildTestWidget(size: Size(width, 800.0)));
      await tester.pumpAndSettle();

      // Switch to New Patient mode
      await tester.tap(find.text('New Patient'));
      await tester.pumpAndSettle();

      // Verify no render overflow
      expect(tester.takeException(), isNull);
      expect(find.text('Complete Registration'), findsOneWidget);
    });
  }

  testWidgets('Language dropdown contains all 9 languages without *Review badge', (tester) async {
    tester.view.physicalSize = const Size(412.0, 900.0);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Switch to New Patient mode to see language dropdown
    await tester.tap(find.text('New Patient'));
    await tester.pumpAndSettle();

    // Verify *Review is not present anywhere on screen
    expect(find.text('*Review'), findsNothing);
    expect(find.textContaining('*Review'), findsNothing);

    // Scroll to dropdown and open
    final dropdownFinder = find.byType(DropdownButtonFormField<String>);
    await tester.ensureVisible(dropdownFinder);
    await tester.pumpAndSettle();
    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    // Verify all 9 languages are present
    expect(find.text('English'), findsWidgets);
    expect(find.text('हिन्दी'), findsOneWidget);
    expect(find.text('অসমীয়া'), findsOneWidget);
    expect(find.text('বাংলা'), findsOneWidget);
    expect(find.text('মৈতৈলোন'), findsOneWidget);
    expect(find.text('बर\''), findsOneWidget);
    expect(find.text('Mizo'), findsWidgets);
    expect(find.text('Khasi'), findsWidgets);
    expect(find.text('Garo'), findsWidgets);

    // Verify no *Review badge exists in dropdown items
    expect(find.text('*Review'), findsNothing);
    expect(find.textContaining('*Review'), findsNothing);
  });

  testWidgets('Client-side validations show distinct localized error messages', (tester) async {
    tester.view.physicalSize = const Size(412.0, 900.0);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(buildTestWidget());
    await tester.pumpAndSettle();

    // Switch to New Patient
    await tester.tap(find.text('New Patient'));
    await tester.pumpAndSettle();

    final submitFinder = find.text('Complete Registration');

    // 1. Submit with empty name
    await tester.ensureVisible(submitFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your name.'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(LoginScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // 2. Fill name, submit with empty email
    final nameField = find.byType(TextField).at(0);
    await tester.ensureVisible(nameField);
    await tester.enterText(nameField, 'Grandma Devi');
    await tester.ensureVisible(submitFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your email address.'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(LoginScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // 3. Fill invalid email, submit
    final emailField = find.byType(TextField).at(1);
    await tester.ensureVisible(emailField);
    await tester.enterText(emailField, 'invalid-email');
    await tester.ensureVisible(submitFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();
    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    ScaffoldMessenger.of(tester.element(find.byType(LoginScreen))).clearSnackBars();
    await tester.pumpAndSettle();

    // 4. Fill valid email, submit with empty/short password
    await tester.enterText(emailField, 'patient@example.com');
    final passwordField = find.byType(TextField).at(2);
    await tester.ensureVisible(passwordField);
    await tester.enterText(passwordField, '123');
    await tester.ensureVisible(submitFinder);
    await tester.pumpAndSettle();
    await tester.tap(submitFinder);
    await tester.pumpAndSettle();
    expect(find.text('Please enter your password (minimum 6 characters).'), findsOneWidget);
  });
}
