import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/games/models/game_model.dart';
import 'package:patient_app/features/help/models/help_context.dart';
import 'package:patient_app/features/help/models/help_screen_id.dart';
import 'package:patient_app/features/help/services/help_context_service.dart';

void main() {
  group('HelpContext Model & Screen Mapping Tests', () {
    test('1. HelpContext creation with explicit parameters', () {
      const context = HelpContext(
        screenId: HelpScreenId.memoryMatch,
        route: 'memory_match',
        feature: 'MEMORY_MATCH',
        language: 'en',
        isGame: true,
        gameType: CognitiveGameType.memoryMatch,
      );

      expect(context.screenId, equals(HelpScreenId.memoryMatch));
      expect(context.feature, equals('MEMORY_MATCH'));
      expect(context.route, equals('memory_match'));
      expect(context.isGame, isTrue);
      expect(context.gameType, equals(CognitiveGameType.memoryMatch));
      expect(context.language, equals('en'));

      final map = context.toMap();
      expect(map['screenId'], equals('MEMORY_MATCH'));
      expect(map['isGame'], isTrue);
      expect(map['gameType'], equals('memory_match'));
    });

    test('2. Route -> HelpContext mapping works for all standard screens', () {
      expect(HelpScreenId.fromString('HOME'), equals(HelpScreenId.home));
      expect(HelpScreenId.fromString('GAMES'), equals(HelpScreenId.games));
      expect(HelpScreenId.fromString('MEMORY_MATCH'), equals(HelpScreenId.memoryMatch));
      expect(HelpScreenId.fromString('PATTERN_RECOGNITION'), equals(HelpScreenId.patternRecognition));
      expect(HelpScreenId.fromString('ROUTINE'), equals(HelpScreenId.routine));
      expect(HelpScreenId.fromString('REMINDERS'), equals(HelpScreenId.reminders));
      expect(HelpScreenId.fromString('PROGRESS'), equals(HelpScreenId.progress));
      expect(HelpScreenId.fromString('PROFILE'), equals(HelpScreenId.profile));
      expect(HelpScreenId.fromString('SETTINGS'), equals(HelpScreenId.settings));
      expect(HelpScreenId.fromString('CAREGIVER_PAIRING'), equals(HelpScreenId.caregiverPairing));
      expect(HelpScreenId.fromString('PAIRING'), equals(HelpScreenId.caregiverPairing));
    });

    test('3. Unknown route fallback safely maps to UNKNOWN without errors', () {
      expect(HelpScreenId.fromString(null), equals(HelpScreenId.unknown));
      expect(HelpScreenId.fromString(''), equals(HelpScreenId.unknown));
      expect(HelpScreenId.fromString('some_random_nonexistent_route_12345'), equals(HelpScreenId.unknown));

      final unknownContext = HelpContext.unknown(route: 'unrecognized_page');
      expect(unknownContext.screenId, equals(HelpScreenId.unknown));
      expect(unknownContext.feature, equals('UNKNOWN'));
      expect(unknownContext.isGame, isFalse);
    });

    test('HelpScreenId game detection is accurate', () {
      expect(HelpScreenId.memoryMatch.isGame, isTrue);
      expect(HelpScreenId.patternRecognition.isGame, isTrue);
      expect(HelpScreenId.routine.isGame, isTrue);

      expect(HelpScreenId.home.isGame, isFalse);
      expect(HelpScreenId.games.isGame, isFalse);
      expect(HelpScreenId.reminders.isGame, isFalse);
      expect(HelpScreenId.settings.isGame, isFalse);
      expect(HelpScreenId.unknown.isGame, isFalse);
    });

    test('HelpContextService updates correctly from shell tabs', () {
      final service = HelpContextService();

      service.updateFromShellTab(0);
      expect(service.currentContext.screenId, equals(HelpScreenId.home));

      service.updateFromShellTab(1);
      expect(service.currentContext.screenId, equals(HelpScreenId.games));

      service.updateFromShellTab(3);
      expect(service.currentContext.screenId, equals(HelpScreenId.reminders));

      service.updateFromShellTab(4);
      expect(service.currentContext.screenId, equals(HelpScreenId.progress));

      service.updateFromShellTab(99);
      expect(service.currentContext.screenId, equals(HelpScreenId.unknown));
    });

    test('HelpContextService updateFromScreenId sets gameType automatically', () {
      final service = HelpContextService();

      service.updateFromScreenId(HelpScreenId.memoryMatch);
      expect(service.currentContext.screenId, equals(HelpScreenId.memoryMatch));
      expect(service.currentContext.isGame, isTrue);
      expect(service.currentContext.gameType, equals(CognitiveGameType.memoryMatch));

      service.updateFromScreenId(HelpScreenId.patternRecognition);
      expect(service.currentContext.screenId, equals(HelpScreenId.patternRecognition));
      expect(service.currentContext.isGame, isTrue);
      expect(service.currentContext.gameType, equals(CognitiveGameType.patternRecognition));

      service.updateFromScreenId(HelpScreenId.routine);
      expect(service.currentContext.screenId, equals(HelpScreenId.routine));
      expect(service.currentContext.isGame, isTrue);
      expect(service.currentContext.gameType, equals(CognitiveGameType.dailyRoutineRecall));
    });
  });
}
