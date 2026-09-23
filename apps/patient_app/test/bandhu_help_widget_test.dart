import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/features/help/models/help_context.dart';
import 'package:patient_app/features/help/models/help_screen_id.dart';
import 'package:patient_app/features/help/services/help_context_service.dart';
import 'package:patient_app/features/help/widgets/bandhu_help_button.dart';
import 'package:patient_app/features/help/widgets/bandhu_help_sheet.dart';

Widget _buildTestApp({
  required Widget child,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    theme: SmritiTheme.lightTheme,
    darkTheme: SmritiTheme.darkTheme,
    themeMode: themeMode,
    home: Scaffold(
      body: Center(child: child),
    ),
  );
}

void main() {
  setUp(() {
    HelpContextService.instance.updateFromScreenId(HelpScreenId.home);
  });

  group('BandhuHelpButton & BandhuHelpSheet Widget Tests', () {
    testWidgets('8. BandhuHelpButton meets minimum 56x56 touch target and semantics', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const BandhuHelpButton(),
        ),
      );

      final buttonFinder = find.byKey(const Key('bandhu_help_button'));
      expect(buttonFinder, findsOneWidget);

      final size = tester.getSize(buttonFinder);
      expect(size.width, greaterThanOrEqualTo(56.0));
      expect(size.height, greaterThanOrEqualTo(56.0));

      final semantics = tester.getSemantics(buttonFinder);
      expect(semantics.label, contains('BANDHU Help'));
    });

    testWidgets('8. Tapping BandhuHelpButton opens BandhuHelpSheet', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const BandhuHelpButton(screenId: HelpScreenId.home),
        ),
      );

      await tester.tap(find.byKey(const Key('bandhu_help_button')));
      await tester.pumpAndSettle();

      expect(find.byType(BandhuHelpSheet), findsOneWidget);
      expect(find.text('BANDHU Help'), findsWidgets);
    });

    testWidgets('9. Help panel displays current detected context (Memory Match)', (tester) async {
      final memoryContext = HelpContext.fromScreenId(HelpScreenId.memoryMatch);

      await tester.pumpWidget(
        MaterialApp(
          theme: SmritiTheme.darkTheme,
          home: Scaffold(
            body: BandhuHelpSheet(initialContext: memoryContext),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify detected screen badge displays Memory Match
      expect(find.text('Memory Match'), findsWidgets);
      expect(find.text('MEMORY_MATCH'), findsOneWidget);
      expect(find.text('How can I help?'), findsOneWidget);

      // Verify quick action chips are present
      expect(find.text('How do I play?'), findsOneWidget);
      expect(find.text('I’m stuck'), findsOneWidget);
      expect(find.text('Give me a hint'), findsOneWidget);
      expect(find.text('What do I do next?'), findsOneWidget);

      // Verify deterministic response is loaded
      expect(find.text('Offline Local Guidance'), findsOneWidget);
      expect(find.text('How to Play Memory Match'), findsOneWidget);
    });

    testWidgets('Tapping a quick action chip updates help response in panel', (tester) async {
      final memoryContext = HelpContext.fromScreenId(HelpScreenId.memoryMatch);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BandhuHelpSheet(initialContext: memoryContext),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap "Give me a hint"
      await tester.tap(find.text('Give me a hint'));
      await tester.pumpAndSettle();

      expect(find.text('Gentle Hint'), findsOneWidget);
      expect(find.textContaining('Try remembering where you saw the matching card'), findsOneWidget);
    });

    testWidgets('Works seamlessly in dark theme without contrast or rendering issues', (tester) async {
      final patternContext = HelpContext.fromScreenId(HelpScreenId.patternRecognition);

      await tester.pumpWidget(
        MaterialApp(
          theme: SmritiTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: BandhuHelpSheet(initialContext: patternContext),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pattern Recognition'), findsWidgets);
      expect(find.text('PATTERN_RECOGNITION'), findsOneWidget);
      expect(find.text('How Pattern Recognition Works'), findsOneWidget);
    });
  });
}
