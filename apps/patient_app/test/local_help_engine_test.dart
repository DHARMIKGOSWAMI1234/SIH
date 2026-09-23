import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/help/models/help_context.dart';
import 'package:patient_app/features/help/models/help_request.dart';
import 'package:patient_app/features/help/models/help_screen_id.dart';
import 'package:patient_app/features/help/services/local_help_engine.dart';

void main() {
  group('LocalHelpEngine Deterministic Offline Guidance Tests', () {
    const engine = LocalHelpEngine();

    test('4. LocalHelpEngine HOME response provides accurate overview and navigation', () async {
      final homeContext = HelpContext.fromScreenId(HelpScreenId.home);
      final response = await engine.getHelp(
        homeContext,
        HelpRequest.action(HelpActionType.howDoIPlay),
      );

      expect(response.title, contains('BANDHU'));
      expect(response.message, contains('cognitive care companion'));
      expect(response.suggestedSteps.length, greaterThanOrEqualTo(2));
      expect(response.isOffline, isTrue);
    });

    test('5. LocalHelpEngine MEMORY_MATCH response provides generic guidance without fake hints', () async {
      final memoryContext = HelpContext.fromScreenId(HelpScreenId.memoryMatch);

      // Play instruction
      final playResponse = await engine.getHelp(
        memoryContext,
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(playResponse.title, contains('Memory Match'));
      expect(playResponse.message, contains('matching twin'));

      // Hint test - CRITICAL: verify NO fake card positions
      final hintResponse = await engine.getHelp(
        memoryContext,
        HelpRequest.action(HelpActionType.hint),
      );
      expect(hintResponse.title, contains('Gentle Hint'));
      expect(hintResponse.message, contains('Try remembering where you saw the matching card'));
      expect(hintResponse.message.toLowerCase(), isNot(contains('top-left')));
      expect(hintResponse.message.toLowerCase(), isNot(contains('bottom-right')));
      expect(hintResponse.message.toLowerCase(), isNot(contains('card 1')));
      expect(hintResponse.message.toLowerCase(), isNot(contains('first card')));

      // Stuck guidance
      final stuckResponse = await engine.getHelp(
        memoryContext,
        HelpRequest.action(HelpActionType.stuck),
      );
      expect(stuckResponse.suggestedSteps.isNotEmpty, isTrue);
    });

    test('6. LocalHelpEngine PATTERN_RECOGNITION response explains visual rhythms', () async {
      final patternContext = HelpContext.fromScreenId(HelpScreenId.patternRecognition);

      final response = await engine.getHelp(
        patternContext,
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(response.title, contains('Pattern'));
      expect(response.message, contains('rhythm'));

      final hintResponse = await engine.getHelp(
        patternContext,
        HelpRequest.action(HelpActionType.hint),
      );
      expect(hintResponse.message, contains('rhythm'));
    });

    test('7. LocalHelpEngine CAREGIVER_PAIRING response explains 4-digit code and QR', () async {
      final pairingContext = HelpContext.fromScreenId(HelpScreenId.caregiverPairing);

      final response = await engine.getHelp(
        pairingContext,
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(response.title, contains('Pairing'));
      expect(response.message, contains('family or caregiver'));
      expect(response.suggestedSteps.any((s) => s.contains('4-digit code')), isTrue);
      expect(response.suggestedSteps.any((s) => s.contains('Scan QR')), isTrue);

      // Stuck / Troubleshooting
      final stuckResponse = await engine.getHelp(
        pairingContext,
        HelpRequest.action(HelpActionType.stuck),
      );
      expect(stuckResponse.title, contains('Troubleshooting'));
      expect(stuckResponse.suggestedSteps.any((s) => s.contains('Wi-Fi')), isTrue);
    });

    test('ROUTINE RECALL returns chronological sequencing guidance', () async {
      final routineContext = HelpContext.fromScreenId(HelpScreenId.routine);
      final response = await engine.getHelp(
        routineContext,
        HelpRequest.action(HelpActionType.howDoIPlay),
      );

      expect(response.title, contains('Routine Recall'));
      expect(response.message, contains('chronological order'));
    });

    test('GAMES catalog response explains available games', () async {
      final gamesContext = HelpContext.fromScreenId(HelpScreenId.games);
      final response = await engine.getHelp(
        gamesContext,
        HelpRequest.action(HelpActionType.howDoIPlay),
      );

      expect(response.title, contains('Brain Exercise'));
      expect(response.message, contains('Memory Match'));
      expect(response.message, contains('Pattern Recognition'));
      expect(response.message, contains('Routine Recall'));
    });

    test('REMINDERS, PROGRESS, PROFILE, SETTINGS, and UNKNOWN return valid responses', () async {
      final remResponse = await engine.getHelp(
        HelpContext.fromScreenId(HelpScreenId.reminders),
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(remResponse.title, contains('Reminders'));

      final progResponse = await engine.getHelp(
        HelpContext.fromScreenId(HelpScreenId.progress),
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(progResponse.title, contains('Progress'));

      final profResponse = await engine.getHelp(
        HelpContext.fromScreenId(HelpScreenId.profile),
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(profResponse.title, contains('Profile'));

      final setResponse = await engine.getHelp(
        HelpContext.fromScreenId(HelpScreenId.settings),
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(setResponse.title, contains('Settings'));

      final unkResponse = await engine.getHelp(
        HelpContext.unknown(),
        HelpRequest.action(HelpActionType.howDoIPlay),
      );
      expect(unkResponse.title, contains('BANDHU Help'));
    });

    test('10. Offline responses require zero network and never fail without connectivity', () async {
      for (final screenId in HelpScreenId.values) {
        final context = HelpContext.fromScreenId(screenId);
        final response = await engine.getHelp(
          context,
          HelpRequest.action(HelpActionType.howDoIPlay),
        );
        expect(response.isOffline, isTrue);
        expect(response.title.isNotEmpty, isTrue);
        expect(response.message.isNotEmpty, isTrue);
        expect(response.disclaimer, equals('Offline Local Guidance'));
      }
    });

    test('Custom keyword queries route appropriately without external API', () async {
      final homeContext = HelpContext.fromScreenId(HelpScreenId.home);

      final pairQuery = await engine.getHelp(
        homeContext,
        HelpRequest.query('How do I pair with my caregiver?'),
      );
      expect(pairQuery.title, contains('Pairing'));

      final stuckQuery = await engine.getHelp(
        homeContext,
        HelpRequest.query('I feel confused and lost'),
      );
      expect(stuckQuery.title, contains('Finding Your Way'));
    });
  });
}
