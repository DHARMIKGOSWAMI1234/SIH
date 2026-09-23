import 'dart:async';
import 'package:flutter/foundation.dart';

/// Conservative, non-clinical hesitation and stuck detection service for BANDHU games.
///
/// PURPOSE:
/// Strictly detects opportunities for gentle gameplay assistance during active cognitive games.
///
/// SAFETY & ETHICS CONSTRAINTS:
/// - This is NOT a clinical, medical, or diagnostic model.
/// - Does NOT infer cognitive impairment, confusion, or decline.
/// - Uses supportive terminology: "possible hesitation", "help opportunity", "assistance available".
/// - Conservative triggers: requires active gameplay, 20+ seconds of inactivity without progress,
///   or repeated incorrect attempts.
/// - Includes an initial grace period and cooldown so users are never interrupted aggressively.
class StuckDetectionService {
  final Duration idleThreshold;
  final int mistakeThreshold;
  final Duration cooldownDuration;
  final Duration initialGracePeriod;

  final ValueNotifier<bool> shouldShowPrompt = ValueNotifier<bool>(false);

  bool _isGameActive = false;
  int _consecutiveMistakes = 0;
  DateTime? _gameStartedAt;
  DateTime? _lastActionAt;
  DateTime? _lastProgressAt;
  DateTime? _cooldownUntil;

  Timer? _tickerTimer;

  StuckDetectionService({
    this.idleThreshold = const Duration(seconds: 20),
    this.mistakeThreshold = 2,
    this.cooldownDuration = const Duration(seconds: 45),
    this.initialGracePeriod = const Duration(seconds: 10),
  });

  bool get isGameActive => _isGameActive;
  DateTime? get lastProgressAt => _lastProgressAt;
  bool get isInCooldown {
    if (_cooldownUntil == null) return false;
    return DateTime.now().isBefore(_cooldownUntil!);
  }

  /// Starts monitoring when a game session starts.
  void recordGameStarted() {
    final now = DateTime.now();
    _isGameActive = true;
    _consecutiveMistakes = 0;
    _gameStartedAt = now;
    _lastActionAt = now;
    _lastProgressAt = now;
    shouldShowPrompt.value = false;

    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), _onTick);
  }

  /// Records general user interaction (e.g. card tap, selection).
  /// Resets the idle timer.
  void recordUserAction() {
    _lastActionAt = DateTime.now();
  }

  /// Records a successful gameplay progression (e.g. matched a pair, correct sequence).
  /// Resets mistakes and hides prompt.
  void recordProgress() {
    final now = DateTime.now();
    _lastActionAt = now;
    _lastProgressAt = now;
    _consecutiveMistakes = 0;
    if (shouldShowPrompt.value) {
      shouldShowPrompt.value = false;
    }
  }

  /// Records an incorrect attempt (e.g. mismatched pair, wrong pattern choice).
  /// Checks whether consecutive mistakes meet the conservative threshold.
  void recordMistake() {
    if (!_isGameActive) return;
    _lastActionAt = DateTime.now();
    _consecutiveMistakes++;

    _evaluateTriggerCondition();
  }

  /// Called periodically by the internal ticker or external clock.
  void _onTick(Timer? timer) {
    if (!_isGameActive) return;
    _evaluateTriggerCondition();
  }

  /// Checks if conservative hesitation criteria are met.
  void _evaluateTriggerCondition() {
    if (!_isGameActive || shouldShowPrompt.value) return;

    final now = DateTime.now();

    // 1. Check initial grace period
    if (_gameStartedAt != null &&
        now.difference(_gameStartedAt!) < initialGracePeriod) {
      return;
    }

    // 2. Check active cooldown
    if (isInCooldown) {
      return;
    }

    // Condition A: Repeated consecutive mistakes without recent progress
    final bool hasRepeatedMistakes = _consecutiveMistakes >= mistakeThreshold;

    // Condition B: 20+ seconds elapsed without progress or action
    final actionReference = _lastActionAt ?? _gameStartedAt ?? now;
    final bool isIdle = now.difference(actionReference) >= idleThreshold;

    if (hasRepeatedMistakes || isIdle) {
      shouldShowPrompt.value = true;
    }
  }

  /// Called when the user dismisses the prompt ("Not now").
  /// Hides the prompt and initiates a cooldown period.
  void dismiss() {
    shouldShowPrompt.value = false;
    _consecutiveMistakes = 0;
    _lastActionAt = DateTime.now();
    _cooldownUntil = DateTime.now().add(cooldownDuration);
  }

  /// Called when the user accepts assistance ("Help me").
  /// Hides the prompt and initiates a cooldown period.
  void acceptHelp() {
    shouldShowPrompt.value = false;
    _consecutiveMistakes = 0;
    _lastActionAt = DateTime.now();
    _cooldownUntil = DateTime.now().add(cooldownDuration);
  }

  /// Stops monitoring when game is paused or completed.
  void recordGameCompleted() {
    _isGameActive = false;
    shouldShowPrompt.value = false;
    _tickerTimer?.cancel();
    _tickerTimer = null;
  }

  void dispose() {
    recordGameCompleted();
    shouldShowPrompt.dispose();
  }
}
