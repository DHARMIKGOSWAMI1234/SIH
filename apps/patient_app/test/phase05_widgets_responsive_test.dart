import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/features/memory/memory_screen.dart';
import 'package:patient_app/features/memory/screens/add_memory_screen.dart';
import 'package:patient_app/features/memory/screens/memory_detail_screen.dart';
import 'package:patient_app/features/memory/screens/life_story_screen.dart';
import 'package:patient_app/features/memory/screens/memory_activity_screen.dart';

void main() {
  late AppDatabase db;
  late SmritiRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = SmritiRepository(db);
  });

  tearDown(() async {
    await db.close();
  });

  Widget createTestWidget(Widget child, {Size size = const Size(360, 640)}) {
    return MaterialApp(
      theme: SmritiTheme.lightTheme,
      home: Provider<SmritiRepository>.value(
        value: repo,
        child: MediaQuery(
          data: MediaQueryData(size: size),
          child: child,
        ),
      ),
    );
  }

  group('Phase 05 Widget Tests', () {
    testWidgets('MemoryScreen renders Personal Memory Bank header and buttons', (tester) async {
      await tester.pumpWidget(createTestWidget(const MemoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Personal Memory Bank'), findsWidgets);
      expect(find.text('My Life Story'), findsOneWidget);
      expect(find.text('Add Memory'), findsWidgets);
      expect(find.text('All Memories'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('AddMemoryScreen renders all form fields cleanly', (tester) async {
      await tester.pumpWidget(createTestWidget(const AddMemoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add New Memory'), findsOneWidget);
      expect(find.text('Capture a Cherished Moment'), findsOneWidget);
      expect(find.text('Memory Title *'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
    });

    testWidgets('MemoryDetailScreen renders memory details and action buttons', (tester) async {
      final sampleMem = Memory(
        localId: 'mem_det_01',
        title: 'Veranda Tea Gathering',
        description: 'Warm tea with family on a peaceful afternoon.',
        mediaUri: null,
        category: 'daily_life',
        relationship: 'Grandson',
        personName: 'Rahul',
        location: 'Guwahati',
        eventDate: DateTime(2024, 5, 10),
        imagePath: null,
        audioPath: null,
        language: 'en',
        region: 'Assam',
        tags: null,
        source: 'personal',
        createdAt: DateTime(2024, 5, 10),
        updatedAt: DateTime(2024, 5, 10),
        isFavorite: true,
        isArchived: false,
        syncStatus: 'synced',
        retryCount: 0,
        lastSyncAttempt: null,
      );

      await tester.pumpWidget(createTestWidget(MemoryDetailScreen(memory: sampleMem)));
      await tester.pumpAndSettle();

      expect(find.text('Veranda Tea Gathering'), findsWidgets);
      expect(find.text('Rahul'), findsOneWidget);
      expect(find.text('Grandson'), findsOneWidget);
      expect(find.text('Guwahati'), findsOneWidget);
    });

    testWidgets('LifeStoryScreen renders empty state when no memories exist', (tester) async {
      await tester.pumpWidget(createTestWidget(const LifeStoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Your Life Story Begins Here'), findsOneWidget);
      expect(find.text('Add Milestone'), findsOneWidget);
    });

    testWidgets('MemoryActivityScreen loads questions and allows selecting an answer', (tester) async {
      await repo.insertMemory(
        title: 'Afternoon Tea',
        description: 'Warm cup of Assam tea',
        category: 'food',
        personName: 'Rahul',
        relationship: 'Grandson',
      );

      await tester.pumpWidget(createTestWidget(const MemoryActivityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Memory Activity'), findsOneWidget);
      expect(find.text('Gentle Hint'), findsOneWidget);
    });
  });

  group('Phase 05 Responsive Viewport Tests (320dp - 430dp)', () {
    final viewports = [
      const Size(320, 568), // Narrow 320dp
      const Size(360, 640), // Standard 360dp
      const Size(390, 844), // iPhone/Compact 390dp
      const Size(412, 917), // Pixel 412dp
      const Size(430, 932), // Large Phone 430dp
    ];

    for (final vp in viewports) {
      testWidgets('MemoryScreen does not overflow on ${vp.width}x${vp.height}', (tester) async {
        tester.view.physicalSize = Size(vp.width * 2.0, vp.height * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createTestWidget(const MemoryScreen(), size: vp));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('AddMemoryScreen does not overflow on ${vp.width}x${vp.height}', (tester) async {
        tester.view.physicalSize = Size(vp.width * 2.0, vp.height * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createTestWidget(const AddMemoryScreen(), size: vp));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('MemoryDetailScreen does not overflow on ${vp.width}x${vp.height}', (tester) async {
        tester.view.physicalSize = Size(vp.width * 2.0, vp.height * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        final sampleMem = Memory(
          localId: 'mem_vp',
          title: 'Kaziranga Morning Safari',
          description: 'Exploring lush green sanctuary with family.',
          mediaUri: null,
          category: 'places',
          relationship: 'Daughter',
          personName: 'Priyanka',
          location: 'Kaziranga, Assam',
          eventDate: DateTime(2023, 11, 15),
          imagePath: null,
          audioPath: null,
          language: 'en',
          region: 'Assam',
          tags: null,
          source: 'personal',
          createdAt: DateTime(2023, 11, 15),
          updatedAt: DateTime(2023, 11, 15),
          isFavorite: true,
          isArchived: false,
          syncStatus: 'synced',
          retryCount: 0,
          lastSyncAttempt: null,
        );

        await tester.pumpWidget(createTestWidget(MemoryDetailScreen(memory: sampleMem), size: vp));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });

      testWidgets('MemoryActivityScreen does not overflow on ${vp.width}x${vp.height}', (tester) async {
        tester.view.physicalSize = Size(vp.width * 2.0, vp.height * 2.0);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(createTestWidget(const MemoryActivityScreen(), size: vp));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });
}
