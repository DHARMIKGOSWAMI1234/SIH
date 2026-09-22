import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/features/games/daily_routine_recall/models/routine_recall_state.dart';
import 'package:patient_app/features/games/daily_routine_recall/screens/routine_recall_intro_screen.dart';
import 'package:patient_app/features/games/daily_routine_recall/screens/routine_recall_game_screen.dart';
import 'package:patient_app/features/games/daily_routine_recall/screens/routine_recall_result_screen.dart';
import 'package:patient_app/features/games/daily_routine_recall/widgets/routine_card_button.dart';
import 'package:patient_app/features/games/daily_routine_recall/widgets/routine_step_slot.dart';

void main() {
  late AppDatabase db;
  late SmritiRepository repository;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repository = SmritiRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget createTestWidget(Widget child) {
    return MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: db),
        Provider<SmritiRepository>.value(value: repository),
      ],
      child: MaterialApp(
        theme: SmritiTheme.lightTheme,
        home: child,
      ),
    );
  }

  testWidgets('RoutineRecallIntroScreen renders instructions and level options', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(const RoutineRecallIntroScreen()));

    expect(find.text('Daily Routine Recall'), findsWidgets);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Select Comfortable Level'), findsOneWidget);
    expect(find.text('Easy (Level 1)'), findsOneWidget);
    expect(find.text('Medium (Level 2)'), findsOneWidget);
    expect(find.text('Challenging (Level 3)'), findsOneWidget);
    expect(find.text('Start Routine Exercise'), findsOneWidget);
  });

  testWidgets('RoutineRecallGameScreen renders sequence slots, card pool, hint and check sequence', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      const RoutineRecallGameScreen(difficulty: RoutineRecallDifficulty.easy),
    ));

    expect(find.text('Question 1 of 3'), findsOneWidget);
    expect(find.text('Your Routine Order'), findsOneWidget);
    expect(find.text('Available Activities'), findsOneWidget);
    expect(find.byType(RoutineStepSlot), findsNWidgets(3));
    expect(find.byType(RoutineCardButton), findsWidgets);
    expect(find.text('Hints (0)'), findsOneWidget);
    expect(find.text('Check Sequence'), findsOneWidget);

    // Test Hint button tap
    await tester.tap(find.text('Hints (0)'));
    await tester.pumpAndSettle();

    expect(find.text('Hints (1)'), findsOneWidget);

    // Test selecting a card into sequence
    final firstCard = find.byType(RoutineCardButton).first;
    await tester.tap(firstCard);
    await tester.pumpAndSettle();

    // Verify slot now contains filled item with remove icon button
    expect(find.byIcon(Icons.remove_circle_outline_rounded), findsOneWidget);
    expect(find.text('Added'), findsOneWidget);

    // Test removing item from sequence slot
    await tester.tap(find.byIcon(Icons.remove_circle_outline_rounded).first);
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.remove_circle_outline_rounded), findsNothing);
  });

  testWidgets('RoutineRecallResultScreen displays metrics, adaptive suggestion, and saves session', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final metrics = RoutineRecallMetrics.calculate(
      difficulty: RoutineRecallDifficulty.easy,
      totalQuestions: 3,
      correctAnswers: 3,
      mistakes: 0,
      hintCount: 0,
      startedAt: now.subtract(const Duration(seconds: 40)),
      completedAt: now,
    );

    await tester.pumpWidget(createTestWidget(
      RoutineRecallResultScreen(metrics: metrics),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Great Work!'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
    expect(find.text('300'), findsOneWidget);
    expect(find.text('Next Activity Suggestion'), findsOneWidget);
    expect(find.text('Caregiver Activity Record'), findsOneWidget);
    expect(find.text('Back to Games'), findsOneWidget);

    // Verify session was persisted to Drift database
    final sessions = await repository.getRecentSessions();
    expect(sessions.length, 1);
    expect(sessions.first.gameType, 'routine_recall');
    expect(sessions.first.score, 300);
    expect(sessions.first.accuracy, 1.0);
  });
}
