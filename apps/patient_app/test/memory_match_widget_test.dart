import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/features/games/memory_match/models/memory_match_state.dart';
import 'package:patient_app/features/games/memory_match/screens/memory_match_intro_screen.dart';
import 'package:patient_app/features/games/memory_match/screens/memory_match_game_screen.dart';
import 'package:patient_app/features/games/memory_match/screens/memory_match_result_screen.dart';
import 'package:patient_app/features/games/memory_match/widgets/memory_card_widget.dart';

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

  testWidgets('MemoryMatchIntroScreen renders instructions and difficulty levels', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(const MemoryMatchIntroScreen()));

    // Memory Match appears in AppBar and the header card
    expect(find.text('Memory Match'), findsNWidgets(2));
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Choose Activity Level'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Challenging'), findsOneWidget);
    expect(find.text('Start Game'), findsOneWidget);
  });

  testWidgets('MemoryMatchGameScreen renders 6 cards on Easy and handles card taps', (tester) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(createTestWidget(
      const MemoryMatchGameScreen(difficulty: MemoryMatchDifficulty.easy),
    ));

    // Verify header progress
    expect(find.text('Pairs: 0 / 3'), findsOneWidget);
    expect(find.text('Flips: 0'), findsOneWidget);

    // Verify exactly 6 card widgets exist
    final cards = find.byType(MemoryCardWidget);
    expect(cards, findsNWidgets(6));

    // Tap first card
    await tester.tap(cards.first);
    await tester.pump(const Duration(milliseconds: 350));

    // Verify feedback updated
    expect(find.text('Now find the matching picture.'), findsOneWidget);

    // Tap hint button
    final hintBtn = find.byIcon(Icons.lightbulb_outline_rounded);
    expect(hintBtn, findsOneWidget);
    await tester.tap(hintBtn);
    await tester.pump(const Duration(milliseconds: 100));

    // Expect hint feedback
    expect(find.text('Notice the highlighted cards!'), findsOneWidget);
  });

  testWidgets('MemoryMatchResultScreen displays metrics, adaptive suggestion, and saves session', (tester) async {
    tester.view.physicalSize = const Size(1000, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final now = DateTime.now();
    final metrics = MemoryMatchMetrics(
      difficulty: MemoryMatchDifficulty.easy,
      totalPairs: 3,
      matchedPairs: 3,
      totalAttempts: 4,
      mistakes: 1,
      hintCount: 0,
      accuracy: 0.75,
      score: 240,
      startedAt: now.subtract(const Duration(seconds: 40)),
      completedAt: now,
    );

    await tester.pumpWidget(createTestWidget(
      MemoryMatchResultScreen(metrics: metrics),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Great Work!'), findsOneWidget);
    expect(find.text('3 of 3'), findsOneWidget);
    expect(find.text('75%'), findsOneWidget);
    expect(find.text('Next Activity Suggestion'), findsOneWidget);
    expect(find.text('Play Again'), findsOneWidget);
    expect(find.text('Back to Games'), findsOneWidget);

    // Verify record was inserted into Drift SQLite
    final sessions = await repository.getRecentSessions();
    expect(sessions.length, 1);
    expect(sessions.first.gameType, 'memory_match');
    expect(sessions.first.score, 240);
  });
}
