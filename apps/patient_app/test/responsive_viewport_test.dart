import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/core/widgets/smriti_app_shell.dart';
import 'package:patient_app/core/widgets/smriti_game_card.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/local/sync/sync_service.dart';
import 'package:patient_app/features/games/daily_routine_recall/models/routine_recall_state.dart';
import 'package:patient_app/features/games/daily_routine_recall/screens/routine_recall_game_screen.dart';
import 'package:patient_app/features/games/daily_routine_recall/screens/routine_recall_result_screen.dart';
import 'package:patient_app/features/games/games_screen.dart';
import 'package:patient_app/features/memory/memory_screen.dart';
import 'package:patient_app/features/reminders/reminders_screen.dart';
import 'package:patient_app/features/games/memory_match/models/memory_match_state.dart';
import 'package:patient_app/features/games/memory_match/screens/memory_match_game_screen.dart';
import 'package:patient_app/features/games/memory_match/screens/memory_match_result_screen.dart';
import 'package:patient_app/features/games/pattern_recognition/models/pattern_recognition_state.dart';
import 'package:patient_app/features/games/pattern_recognition/screens/pattern_recognition_game_screen.dart';
import 'package:patient_app/features/games/pattern_recognition/screens/pattern_recognition_result_screen.dart';
import 'package:patient_app/features/progress/progress_screen.dart';

void main() {
  late AppDatabase database;
  late SmritiRepository repository;
  late SyncService syncService;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = SmritiRepository(database);
    syncService = SyncService();
  });

  tearDown(() async {
    await database.close();
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<SmritiRepository>.value(value: repository),
        ChangeNotifierProvider<SyncService>.value(value: syncService),
      ],
      child: MaterialApp(
        theme: SmritiTheme.lightTheme,
        home: child,
      ),
    );
  }

  group('Narrow Viewport (320dp - 360dp) Overflow Tests', () {
    testWidgets('SmritiAppShell does not overflow on 320dp narrow phone', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const SmritiAppShell()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('SmritiGameCard does not overflow tags on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(
        Scaffold(
          body: SmritiGameCard(
            title: 'Daily Routine Recall',
            description: 'Arrange familiar daily activities in chronological order',
            icon: Icons.checklist_rounded,
            category: 'Chronological Steps',
            difficultyLevel: 1,
            onTap: () {},
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('RoutineRecallGameScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(
        const RoutineRecallGameScreen(difficulty: RoutineRecallDifficulty.easy),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('RoutineRecallResultScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final metrics = RoutineRecallMetrics.calculate(
        difficulty: RoutineRecallDifficulty.easy,
        totalQuestions: 3,
        correctAnswers: 3,
        mistakes: 0,
        hintCount: 1,
        startedAt: now.subtract(const Duration(seconds: 84)),
        completedAt: now,
      );

      await tester.pumpWidget(createTestWidget(
        RoutineRecallResultScreen(metrics: metrics),
      ));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('Help Dialog does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const SmritiAppShell()));
      await tester.pumpAndSettle();

      // Tap help icon button
      await tester.tap(find.byIcon(Icons.help_outline_rounded));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('How to Use SMRITI'), findsOneWidget);
    });

    testWidgets('GamesScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const GamesScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('MemoryScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const MemoryScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('RemindersScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const RemindersScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('ProgressScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const ProgressScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('MemoryMatchGameScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const MemoryMatchGameScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('MemoryMatchResultScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final metrics = MemoryMatchMetrics.calculate(
        difficulty: MemoryMatchDifficulty.easy,
        matchedPairs: 3,
        totalAttempts: 6,
        mistakes: 1,
        hintCount: 1,
        startedAt: now.subtract(const Duration(seconds: 45)),
        completedAt: now,
      );

      await tester.pumpWidget(createTestWidget(MemoryMatchResultScreen(metrics: metrics)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('PatternRecognitionGameScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(const PatternRecognitionGameScreen()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('PatternRecognitionResultScreen does not overflow on 320dp', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final now = DateTime.now();
      final metrics = PatternRecognitionMetrics.calculate(
        difficulty: PatternDifficulty.easy,
        totalQuestions: 3,
        correctAnswers: 3,
        mistakes: 0,
        hintCount: 1,
        startedAt: now.subtract(const Duration(seconds: 60)),
        completedAt: now,
      );

      await tester.pumpWidget(createTestWidget(PatternRecognitionResultScreen(metrics: metrics)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Standard Android & Mobile Viewports (360dp - 430dp) Tests', () {
    testWidgets('SmritiAppShell does not overflow on 390dp and 412dp', (tester) async {
      for (final width in [360.0, 390.0, 412.0, 430.0]) {
        tester.view.physicalSize = Size(width, 840);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget(const SmritiAppShell()));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Failed at width $width');
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('RoutineRecallGameScreen does not overflow on 360dp - 430dp', (tester) async {
      for (final width in [360.0, 390.0, 412.0, 430.0]) {
        tester.view.physicalSize = Size(width, 840);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget(
          const RoutineRecallGameScreen(difficulty: RoutineRecallDifficulty.easy),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Failed at width $width');
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });

    testWidgets('RoutineRecallResultScreen does not overflow on 360dp - 430dp', (tester) async {
      final now = DateTime.now();
      final metrics = RoutineRecallMetrics.calculate(
        difficulty: RoutineRecallDifficulty.easy,
        totalQuestions: 3,
        correctAnswers: 3,
        mistakes: 0,
        hintCount: 1,
        startedAt: now.subtract(const Duration(seconds: 84)),
        completedAt: now,
      );

      for (final width in [360.0, 390.0, 412.0, 430.0]) {
        tester.view.physicalSize = Size(width, 840);
        tester.view.devicePixelRatio = 1.0;

        await tester.pumpWidget(createTestWidget(
          RoutineRecallResultScreen(metrics: metrics),
        ));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'Failed at width $width');
      }
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
    });
  });
}
