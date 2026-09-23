import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/help/services/stuck_detection_service.dart';

void main() {
  group('StuckDetectionService Tests', () {
    late StuckDetectionService service;

    setUp(() {
      service = StuckDetectionService(
        idleThreshold: const Duration(seconds: 20),
        mistakeThreshold: 2,
        cooldownDuration: const Duration(seconds: 45),
        initialGracePeriod: const Duration(seconds: 10),
      );
    });

    tearDown(() {
      service.dispose();
    });

    test('Initial state is inactive with prompt false', () {
      expect(service.isGameActive, isFalse);
      expect(service.shouldShowPrompt.value, isFalse);
      expect(service.isInCooldown, isFalse);
    });

    test('recordGameStarted activates service and sets prompt to false', () {
      service.recordGameStarted();
      expect(service.isGameActive, isTrue);
      expect(service.shouldShowPrompt.value, isFalse);
    });

    test('recordProgress resets mistakes and hides prompt', () {
      service.recordGameStarted();
      service.recordMistake();
      expect(service.shouldShowPrompt.value, isFalse);

      service.recordProgress();
      expect(service.shouldShowPrompt.value, isFalse);
      expect(service.lastProgressAt, isNotNull);
    });

    test('Dismiss triggers cooldown and hides prompt', () {
      service.recordGameStarted();
      service.dismiss();

      expect(service.shouldShowPrompt.value, isFalse);
      expect(service.isInCooldown, isTrue);
    });

    test('recordGameCompleted stops active monitoring and cancels prompt', () {
      service.recordGameStarted();
      expect(service.isGameActive, isTrue);

      service.recordGameCompleted();
      expect(service.isGameActive, isFalse);
      expect(service.shouldShowPrompt.value, isFalse);
    });

    test('recordUserAction updates internal action reference', () {
      service.recordGameStarted();
      service.recordUserAction();
      expect(service.isGameActive, isTrue);
    });
  });
}
