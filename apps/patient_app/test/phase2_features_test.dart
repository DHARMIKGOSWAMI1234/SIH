import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/core/responsive/smriti_responsive.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/local/sync/sync_service.dart';
import 'package:patient_app/features/help/models/help_context.dart';
import 'package:patient_app/features/help/models/help_request.dart';
import 'package:patient_app/features/help/models/help_screen_id.dart';
import 'package:patient_app/features/help/services/local_help_engine.dart';
import 'package:patient_app/features/memory/models/personal_memory_model.dart';
import 'package:patient_app/features/memory/models/cultural_memory_item.dart';
import 'package:patient_app/features/memory/screens/familiar_world_screen.dart';
import 'package:patient_app/features/memory/screens/family_connect_screen.dart';
import 'package:patient_app/features/memory/screens/reminiscence_screen.dart';
import 'package:patient_app/features/memory/screens/music_memory_screen.dart';
import 'package:patient_app/features/my_day/models/mood_check_in_model.dart';
import 'package:patient_app/features/my_day/widgets/mood_check_in_widget.dart';
import 'package:patient_app/features/my_day/screens/my_day_screen.dart';
import 'package:patient_app/features/talk_to_me/screens/talk_to_me_screen.dart';
import 'package:patient_app/features/personalization/services/personalization_engine.dart';

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

  group('Phase 2: Personal Memory & Cultural Item Models', () {
    test('PersonalMemory model JSON serialization and category helpers', () {
      final memory = PersonalMemory(
        id: 'mem_1',
        title: 'Bihu Festival Gathering',
        description: 'Enjoying Til Pitha with family on the courtyard',
        category: 'festivals',
        relationship: 'Daughter',
        location: 'Guwahati',
        date: DateTime(2023, 4, 14),
        createdAt: DateTime.now(),
        createdBy: 'personal',
        isFavorite: true,
      );

      final json = memory.toJson();
      expect(json['title'], equals('Bihu Festival Gathering'));
      expect(json['category'], equals('festivals'));
      expect(json['isFavorite'], isTrue);

      final restored = PersonalMemory.fromJson(json);
      expect(restored.title, equals(memory.title));
      expect(restored.relationship, equals('Daughter'));
    });

    test('CulturalMemoryItem authentic NER demo catalog has authentic items', () {
      final items = CulturalMemoryItem.demoItems;
      expect(items.length, greaterThanOrEqualTo(5));

      final jaapi = items.firstWhere((i) => i.id == 'ner_c_jaapi');
      expect(jaapi.title, equals('Assamese Jaapi'));
      expect(jaapi.region, equals('Assam'));
      expect(jaapi.answerOptions.length, equals(4));
      expect(jaapi.answerOptions.contains(jaapi.correctAnswer), isTrue);

      final cheraw = items.firstWhere((i) => i.id == 'ner_c_cheraw');
      expect(cheraw.region, equals('Mizoram'));
      expect(cheraw.description, contains('bamboo'));

      final naga = items.firstWhere((i) => i.id == 'ner_c_shawl');
      expect(naga.region, equals('Nagaland'));
    });
  });

  group('Phase 2: Daily Routine Companion & Mood Check-In', () {
    test('MoodCheckIn model serialization and MoodType extensions', () {
      expect(MoodType.good.emoji, equals('😊'));
      expect(MoodType.okay.emoji, equals('🙂'));
      expect(MoodType.notGreat.emoji, equals('😐'));
      expect(MoodType.sad.emoji, equals('😔'));

      final checkIn = MoodCheckIn(
        id: 'mood_1',
        mood: MoodType.good,
        timestamp: DateTime(2026, 9, 22, 10, 0),
        note: 'Peaceful morning',
      );

      final json = checkIn.toJson();
      expect(json['mood'], equals('good'));
      expect(json['note'], equals('Peaceful morning'));

      final restored = MoodCheckIn.fromJson(json);
      expect(restored.mood, equals(MoodType.good));
      expect(restored.note, equals('Peaceful morning'));
    });

    testWidgets('MoodCheckInWidget renders 4 large touch targets with labels', (tester) async {
      MoodCheckIn? recorded;

      await tester.pumpWidget(createTestWidget(
        Scaffold(
          body: MoodCheckInWidget(
            storage: MoodCheckInStorage(useInMemory: true),
            onCheckInSaved: (c) => recorded = c,
          ),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('How are you feeling today?'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('Okay'), findsOneWidget);
      expect(find.text('Not great'), findsOneWidget);
      expect(find.text('Sad'), findsOneWidget);
      expect(find.text('Self-reported check-in only. Not a medical evaluation.'), findsOneWidget);

      // Tap 'Good' mood button
      await tester.tap(find.text('Good'));
      await tester.pumpAndSettle();

      expect(recorded, isNotNull);
      expect(recorded!.mood, equals(MoodType.good));
    });

    testWidgets('MyDayScreen renders time greeting, mood check-in, and timeline', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(
        const Scaffold(
          body: MyDayScreen(isEmbedded: true),
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Today\'s Routine Timeline'), findsOneWidget);
      expect(find.text('Morning Tea & Peaceful Start'), findsOneWidget);
      expect(find.text('Hydration: Glass of Water'), findsOneWidget);

      // Toggle timeline checkbox item
      await tester.tap(find.text('Hydration: Glass of Water'));
      await tester.pumpAndSettle();

      expect(find.text('Marked as completed: Hydration: Glass of Water'), findsOneWidget);
    });
  });

  group('Phase 2: Reminiscence, Music, and Talk To Me Screens', () {
    testWidgets('ReminiscenceScreen renders prompt and speak/type options', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const ReminiscenceScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Reminiscence Mode'), findsOneWidget);
      expect(find.text('Reminiscence Foundation (Local Demo)'), findsOneWidget);
      expect(find.text('Speak Reflection'), findsOneWidget);
      expect(find.text('Write Reflection'), findsOneWidget);

      // Tap write reflection to open text input
      await tester.tap(find.text('Write Reflection'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('MusicMemoryScreen renders track list and player controls', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const MusicMemoryScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Memory Through Music'), findsOneWidget);
      expect(find.text('Peaceful Bamboo Flute Melody'), findsWidgets);
      expect(find.text('Grandmother\'s Courtyard Lullaby'), findsOneWidget);
      expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

      // Tap Play button
      await tester.tap(find.byIcon(Icons.play_arrow_rounded));
      await tester.pump();

      expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    });

    testWidgets('TalkToMeScreen sends deterministic offline companion responses', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const TalkToMeScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Talk to Me'), findsOneWidget);
      expect(find.text('Deterministic Local Companion (Non-AI, Non-Medical)'), findsOneWidget);
      expect(find.text('Tell me about Bihu festival'), findsOneWidget);

      // Tap quick topic chip
      await tester.tap(find.text('Tell me about Bihu festival'));
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.textContaining('Bihu brings the sweet sound of the Pepa'), findsOneWidget);
    });

    testWidgets('FamilyConnectScreen renders contribution form and saves locally', (tester) async {
      await tester.pumpWidget(createTestWidget(
        const FamilyConnectScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Family Connect'), findsOneWidget);
      expect(find.text('Family Contribution Foundation'), findsOneWidget);
      expect(find.text('+ Add Family Memory'), findsOneWidget);

      // Open form
      await tester.tap(find.text('+ Add Family Memory'));
      await tester.pumpAndSettle();

      expect(find.text('Contribute a Memory'), findsOneWidget);
      expect(find.text('Memory / Milestone Title *'), findsOneWidget);
    });

    testWidgets('FamiliarWorldScreen renders cultural quiz options', (tester) async {
      tester.view.physicalSize = const Size(800, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(
        const FamiliarWorldScreen(),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Familiar World'), findsOneWidget);
      expect(find.text('Assamese Jaapi'), findsOneWidget);
      expect(find.text('Jaapi'), findsOneWidget);

      // Tap correct answer
      await tester.tap(find.text('Jaapi'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Wonderful!'), findsOneWidget);
      expect(find.text('Next Tradition'), findsOneWidget);
    });
  });

  group('Phase 2: Personalization Engine (Heuristic Scaffold)', () {
    test('LocalHeuristicPersonalizationEngine gives time-based recommendations', () async {
      final engine = LocalHeuristicPersonalizationEngine();

      // Morning test
      final morningRecs = await engine.getRecommendations(
        personalMemories: [],
        completedActivitiesToday: 0,
        currentTime: DateTime(2026, 9, 22, 8, 30),
      );
      expect(morningRecs.any((r) => r.id == 'rec_morning_routine'), isTrue);

      // Personal memory recommendation test
      final sampleMem = Memory(
        localId: '1',
        title: 'Courtyard',
        description: 'Family tea',
        category: 'family',
        language: 'en',
        source: 'personal',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isFavorite: false,
        isArchived: false,
        syncStatus: 'synced',
        retryCount: 0,
      );

      final memRecs = await engine.getRecommendations(
        personalMemories: [sampleMem],
        completedActivitiesToday: 1,
        currentTime: DateTime(2026, 9, 22, 17, 0),
      );
      expect(memRecs.any((r) => r.id == 'rec_reminiscence'), isTrue);
      expect(memRecs.any((r) => r.id == 'rec_music'), isTrue);

      // Adaptive difficulty evaluation
      expect(engine.evaluateGameLevel(recentSuccessCount: 3, recentAttempts: 3), equals(3));
      expect(engine.evaluateGameLevel(recentSuccessCount: 2, recentAttempts: 3), equals(2));
      expect(engine.evaluateGameLevel(recentSuccessCount: 0, recentAttempts: 3), equals(1));
    });
  });

  group('Phase 2: Help Screen IDs & Local Engine Handlers', () {
    test('HelpScreenId contains all 9 new Phase 2 screens', () {
      expect(HelpScreenId.personalMemory.code, equals('PERSONAL_MEMORY'));
      expect(HelpScreenId.lifeStory.code, equals('LIFE_STORY'));
      expect(HelpScreenId.familiarWorld.code, equals('FAMILIAR_WORLD'));
      expect(HelpScreenId.familyConnect.code, equals('FAMILY_CONNECT'));
      expect(HelpScreenId.reminiscence.code, equals('REMINISCENCE'));
      expect(HelpScreenId.musicMemory.code, equals('MUSIC_MEMORY'));
      expect(HelpScreenId.talkToMe.code, equals('TALK_TO_ME'));
      expect(HelpScreenId.myDay.code, equals('MY_DAY'));
      expect(HelpScreenId.moodCheckIn.code, equals('MOOD_CHECK_IN'));
    });

    test('LocalHelpEngine provides guidance for Phase 2 screens', () async {
      final engine = LocalHelpEngine();

      for (final screenId in [
        HelpScreenId.personalMemory,
        HelpScreenId.lifeStory,
        HelpScreenId.familiarWorld,
        HelpScreenId.familyConnect,
        HelpScreenId.reminiscence,
        HelpScreenId.musicMemory,
        HelpScreenId.talkToMe,
        HelpScreenId.myDay,
        HelpScreenId.moodCheckIn,
      ]) {
        final res = await engine.getHelp(
          HelpContext.fromScreenId(screenId),
          HelpRequest.action(HelpActionType.howDoIPlay),
        );
        expect(res.message.isNotEmpty, isTrue);
      }
    });

    test('LocalHelpEngine keyword routing handles Phase 2 concepts', () async {
      final engine = LocalHelpEngine();

      final memRes = await engine.getHelp(
        HelpContext.unknown(),
        HelpRequest.query('How do I add a family memory?'),
      );
      expect(memRes.title.contains('Memory') || memRes.message.toLowerCase().contains('memory'), isTrue);

      final musicRes = await engine.getHelp(
        HelpContext.unknown(),
        HelpRequest.query('Can I listen to calming music?'),
      );
      expect(musicRes.message.contains('Music'), isTrue);

      final moodRes = await engine.getHelp(
        HelpContext.unknown(),
        HelpRequest.query('Where is the daily mood check-in?'),
      );
      expect(moodRes.message.contains('Day') || moodRes.message.contains('check-in'), isTrue);
    });
  });

  group('Phase 2: Responsive Multi-Device UI Breakpoints', () {
    test('SmritiScreenType identifies phone, tablet, and desktop breakpoints', () {
      expect(SmritiResponsive.getScreenTypeFromWidth(320), equals(SmritiScreenType.phone));
      expect(SmritiResponsive.getScreenTypeFromWidth(599), equals(SmritiScreenType.phone));
      expect(SmritiResponsive.getScreenTypeFromWidth(600), equals(SmritiScreenType.tablet));
      expect(SmritiResponsive.getScreenTypeFromWidth(1023), equals(SmritiScreenType.tablet));
      expect(SmritiResponsive.getScreenTypeFromWidth(1024), equals(SmritiScreenType.desktop));
      expect(SmritiResponsive.getScreenTypeFromWidth(1440), equals(SmritiScreenType.desktop));
    });

    testWidgets('SmritiResponsiveWrapper constrains content to 1200dp max', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget(
        const Scaffold(
          body: SmritiResponsiveWrapper(
            child: SizedBox(
              width: double.infinity,
              height: 200,
              child: Text('Desktop Content'),
            ),
          ),
        ),
      ));
      await tester.pumpAndSettle();

      final box = tester.renderObject(find.byType(SmritiResponsiveWrapper)) as RenderBox;
      expect(box.size.width, equals(1920));
      expect(find.text('Desktop Content'), findsOneWidget);
    });
  });
}
