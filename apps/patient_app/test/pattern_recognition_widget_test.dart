import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/core/auth/auth_storage.dart';
import 'package:patient_app/l10n/locale_notifier.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_recognition_state.dart';
import 'package:patient_app/features/games/pattern_recognition/screens/pattern_recognition_intro_screen.dart';
import 'package:patient_app/features/games/pattern_recognition/screens/pattern_recognition_game_screen.dart';
import 'package:patient_app/features/games/pattern_recognition/screens/pattern_recognition_result_screen.dart';
import 'package:patient_app/features/games/pattern_recognition/widgets/pattern_option_button.dart';
import 'package:patient_app/features/games/pattern_recognition/widgets/pattern_sequence_display.dart';

class FakeAuthStorage implements AuthStorage {
  String? _lang;
  @override
  Future<String?> getPreferredLanguage() async => _lang;
  @override
  Future<void> savePreferredLanguage(String languageCode) async => _lang = languageCode;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late SmritiRepository repository;
  late FakeAuthStorage authStorage;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SmritiRepository(db);
    authStorage = FakeAuthStorage();
  });

  tearDown(() async {
    await db.close();
  });

  Widget createTestWidget(Widget child, {String locale = 'en'}) {
    final localeNotifier = LocaleNotifier(
      authStorage: authStorage,
      initialLocale: locale,
    );

    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<SmritiRepository>.value(value: repository),
        ChangeNotifierProvider<LocaleNotifier>.value(value: localeNotifier),
      ],
      child: MaterialApp(
        theme: SmritiTheme.lightTheme,
        home: child,
      ),
    );
  }

  testWidgets('PatternRecognitionIntroScreen renders instructions and level options', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(const PatternRecognitionIntroScreen()));

    expect(find.text('Pattern Recognition'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Select Comfortable Level'), findsOneWidget);
    expect(find.text('Easy (Level 1)'), findsOneWidget);
    expect(find.text('Medium (Level 2)'), findsOneWidget);
    expect(find.text('Challenging (Level 3)'), findsOneWidget);
    expect(find.text('Start Pattern Exercise'), findsOneWidget);
  });

  testWidgets('PatternRecognitionIntroScreen renders cleanly in Hindi', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      const PatternRecognitionIntroScreen(),
      locale: 'hi',
    ));

    expect(find.text('पैटर्न पहचान'), findsOneWidget);
    expect(find.text('खेलने का तरीका'), findsOneWidget);
    expect(find.text('सुविधाजनक स्तर चुनें'), findsOneWidget);
    expect(find.text('पैटर्न अभ्यास शुरू करें'), findsOneWidget);
  });

  testWidgets('PatternRecognitionIntroScreen renders cleanly in Assamese', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      const PatternRecognitionIntroScreen(),
      locale: 'as',
    ));

    expect(find.text('ক্ৰম নিৰ্ণয়'), findsOneWidget);
    expect(find.text('কেনেকৈ খেলিব'), findsOneWidget);
    expect(find.text('সুবিধাজনক স্তৰ বাছক'), findsOneWidget);
    expect(find.text('ক্ৰম নিৰ্ণয় আৰম্ভ কৰক'), findsOneWidget);
  });

  testWidgets('PatternRecognitionGameScreen renders sequence, options, and hint action', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      const PatternRecognitionGameScreen(difficulty: PatternDifficulty.easy),
    ));

    expect(find.text('Question 1 of 4'), findsOneWidget);
    expect(find.byType(PatternSequenceDisplay), findsOneWidget);
    expect(find.text('What picture comes next?'), findsOneWidget);
    expect(find.byType(PatternOptionButton), findsNWidgets(2));
    expect(find.text('Hint (0)'), findsOneWidget);

    // Test Hint button tap
    await tester.tap(find.text('Hint (0)'));
    await tester.pumpAndSettle();

    expect(find.text('Hint (1)'), findsOneWidget);
    expect(find.text('Eliminated'), findsOneWidget);
  });

  testWidgets('PatternRecognitionGameScreen handles pause dialog flow', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      const PatternRecognitionGameScreen(difficulty: PatternDifficulty.easy),
    ));

    // Tap pause icon
    await tester.tap(find.byIcon(Icons.pause_circle_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Pause Exercise'), findsOneWidget);
    expect(find.text('Leave Exercise'), findsOneWidget);
    expect(find.text('Resume'), findsOneWidget);

    // Tap resume
    await tester.tap(find.text('Resume'));
    await tester.pumpAndSettle();

    expect(find.text('Pause Exercise'), findsNothing);
  });

  testWidgets('PatternRecognitionResultScreen displays metrics, adaptive suggestion, and saves session', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final metrics = PatternRecognitionMetrics.calculate(
      difficulty: PatternDifficulty.easy,
      totalQuestions: 4,
      correctAnswers: 4,
      mistakes: 0,
      hintCount: 0,
      startedAt: now.subtract(const Duration(seconds: 35)),
      completedAt: now,
    );

    await tester.pumpWidget(createTestWidget(
      PatternRecognitionResultScreen(metrics: metrics),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Great Work!'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('400'), findsOneWidget);
    expect(find.text('Next Activity Suggestion'), findsOneWidget);
    expect(find.text('Caregiver Activity Record'), findsOneWidget);
    expect(find.text('Back to Games'), findsOneWidget);

    // Verify session was persisted to Drift database
    final sessions = await repository.getRecentSessions();
    expect(sessions.length, 1);
    expect(sessions.first.gameType, 'pattern_recognition');
    expect(sessions.first.score, 400);
  });

  group('Responsive Viewport Tests (320dp - 430dp)', () {
    final viewports = <String, Size>{
      '320dp (Narrow)': const Size(320, 640),
      '360dp (Compact)': const Size(360, 800),
      '390dp (Standard)': const Size(390, 844),
      '412dp (Pixel)': const Size(412, 915),
      '430dp (Pro Max)': const Size(430, 932),
    };

    for (final entry in viewports.entries) {
      testWidgets('PatternRecognitionGameScreen renders cleanly at ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createTestWidget(
          const PatternRecognitionGameScreen(difficulty: PatternDifficulty.easy),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('PatternRecognitionResultScreen renders cleanly at ${entry.key}', (tester) async {
        tester.view.physicalSize = entry.value;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final now = DateTime.now();
        final metrics = PatternRecognitionMetrics.calculate(
          difficulty: PatternDifficulty.medium,
          totalQuestions: 5,
          correctAnswers: 4,
          mistakes: 1,
          hintCount: 1,
          startedAt: now.subtract(const Duration(seconds: 45)),
          completedAt: now,
        );

        await tester.pumpWidget(createTestWidget(
          PatternRecognitionResultScreen(metrics: metrics),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
