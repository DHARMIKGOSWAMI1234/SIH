import 'package:flutter/material.dart';
import '../../data/local/repositories/smriti_repository.dart';
import '../../features/memory/services/memory_rescue_service.dart';
import '../../l10n/app_strings.dart';
import 'intent_service.dart';
import 'speech_recognition_service.dart';
import 'text_to_speech_service.dart';
import 'voice_models.dart';

/// Main orchestrator for SMRITI Voice Interaction ("Talk to Me").
/// Strictly adheres to deterministic retrieval, elderly-first pacing, and non-clinical safety.
class VoiceService extends ChangeNotifier {
  final SpeechRecognitionService _speechRecognition;
  final IntentService _intentService;
  final TextToSpeechService _textToSpeech;
  final SmritiRepository? repository;
  final MemoryRescueService? memoryRescue;

  VoiceState _state = VoiceState.idle;
  String? _transcript;
  VoiceResponse? _lastResponse;

  VoiceService({
    SpeechRecognitionService? asr,
    SpeechRecognitionService? speechRecognition,
    IntentService? intentService,
    TextToSpeechService? tts,
    TextToSpeechService? textToSpeech,
    this.repository,
    this.memoryRescue,
  })  : _speechRecognition = asr ?? speechRecognition ?? PlatformSpeechRecognitionService(),
        _intentService = intentService ?? IntentService(),
        _textToSpeech = tts ?? textToSpeech ?? PlatformTextToSpeechService();

  VoiceState get state => _state;
  String? get transcript => _transcript;
  VoiceResponse? get lastResponse => _lastResponse;
  bool get isListening => _state == VoiceState.listening;
  bool get isProcessing => _state == VoiceState.processing;
  bool get isSpeaking => _state == VoiceState.speaking;

  /// Process a simulated or recognized text transcript directly.
  Future<VoiceServiceResult> processUserTranscript(
    String transcript, {
    Locale locale = const Locale('en'),
    MemoryRescueService? memoryRescueOverride,
    SmritiRepository? repositoryOverride,
    Function(String gameType)? onLaunchGame,
  }) async {
    final rescue = memoryRescueOverride ?? memoryRescue;
    final repo = repositoryOverride ?? repository;
    final intent = _intentService.recognizeIntent(transcript);
    final response = await _handleIntent(
      intent: intent,
      locale: locale,
      memoryRescue: rescue,
      repository: repo,
      onLaunchGame: onLaunchGame,
    );
    return VoiceServiceResult(intent: intent, response: response);
  }

  /// Process a single voice interaction cycle.
  Future<VoiceResponse> processVoiceInteraction({
    required Locale locale,
    MemoryRescueService? memoryRescue,
    SmritiRepository? repository,
    Function(String gameType)? onLaunchGame,
  }) async {
    _state = VoiceState.listening;
    _transcript = null;
    _lastResponse = null;
    notifyListeners();

    try {
      final initialized = await _speechRecognition.initialize(locale);
      if (!initialized) {
        final resp = VoiceResponse(
          spokenText: AppStrings.get('voiceNotAvailable', locale: locale.languageCode),
          visualText: AppStrings.get('voiceNotAvailable', locale: locale.languageCode),
          isSuccess: false,
        );
        _lastResponse = resp;
        _state = VoiceState.idle;
        notifyListeners();
        return resp;
      }

      final recognizedText = await _speechRecognition.listen();
      _transcript = recognizedText;

      if (recognizedText == null || recognizedText.trim().isEmpty) {
        final resp = VoiceResponse(
          spokenText: AppStrings.get('voiceNoSpeechDetected', locale: locale.languageCode),
          visualText: AppStrings.get('voiceNoSpeechDetected', locale: locale.languageCode),
          isSuccess: false,
        );
        _lastResponse = resp;
        _state = VoiceState.idle;
        notifyListeners();
        return resp;
      }

      _state = VoiceState.processing;
      notifyListeners();

      final intent = _intentService.recognizeIntent(recognizedText);
      final response = await _handleIntent(
        intent: intent,
        locale: locale,
        memoryRescue: memoryRescue ?? this.memoryRescue,
        repository: repository ?? this.repository,
        onLaunchGame: onLaunchGame,
      );

      _lastResponse = response;
      _state = VoiceState.speaking;
      notifyListeners();

      await _textToSpeech.speak(response.spokenText, locale: locale);
      _state = VoiceState.idle;
      notifyListeners();
      return response;
    } catch (e) {
      final resp = VoiceResponse(
        spokenText: AppStrings.get('voiceNotAvailable', locale: locale.languageCode),
        visualText: AppStrings.get('voiceNotAvailable', locale: locale.languageCode),
        isSuccess: false,
      );
      _lastResponse = resp;
      _state = VoiceState.idle;
      notifyListeners();
      return resp;
    }
  }

  /// Cancels any active listening or speaking.
  Future<void> cancel() async {
    await _speechRecognition.stop();
    await _textToSpeech.stop();
    _state = VoiceState.idle;
    notifyListeners();
  }

  Future<VoiceResponse> _handleIntent({
    required VoiceIntent intent,
    required Locale locale,
    MemoryRescueService? memoryRescue,
    SmritiRepository? repository,
    Function(String gameType)? onLaunchGame,
  }) async {
    final lang = locale.languageCode;

    switch (intent.type) {
      case VoiceIntentType.medicalQuery:
        final msg = AppStrings.get('voiceMedicalGuardrail', locale: lang);
        return VoiceResponse(
          spokenText: msg,
          visualText: msg,
          actionTaken: 'medical_guardrail',
        );

      case VoiceIntentType.familyQuery:
        if (memoryRescue != null) {
          final rescueResult = await memoryRescue.query(intent.rawText);
          if (rescueResult != MemoryRescueService.fallbackMessage) {
            return VoiceResponse(
              spokenText: rescueResult,
              visualText: rescueResult,
              actionTaken: 'memory_retrieved',
            );
          }
        }
        final notFound = AppStrings.get('memoryRescueFallback', locale: lang);
        return VoiceResponse(
          spokenText: notFound,
          visualText: notFound,
          actionTaken: 'memory_not_found',
        );

      case VoiceIntentType.reminderQuery:
        if (repository != null) {
          final reminders = await repository.getReminders();
          final active = reminders.where((r) => r.enabled).toList();
          if (active.isNotEmpty) {
            final first = active.first;
            final timeStr = first.scheduledTime.isNotEmpty ? 'at ${first.scheduledTime}' : '';
            final text = 'Your next reminder is: ${first.title} $timeStr.';
            return VoiceResponse(
              spokenText: text,
              visualText: text,
              actionTaken: 'reminder_retrieved',
            );
          }
        }
        final text = AppStrings.get('remindersEmpty', locale: lang);
        return VoiceResponse(
          spokenText: text,
          visualText: text,
          actionTaken: 'no_reminders',
        );

      case VoiceIntentType.routineQuery:
        if (repository != null) {
          final routines = await repository.getRoutines();
          if (routines.isNotEmpty) {
            final first = routines.first;
            final text = 'Your daily routine is: ${first.title}.';
            return VoiceResponse(
              spokenText: text,
              visualText: text,
              actionTaken: 'routine_retrieved',
            );
          }
        }
        final text = AppStrings.get('routinesEmpty', locale: lang);
        return VoiceResponse(
          spokenText: text,
          visualText: text,
          actionTaken: 'no_routines',
        );

      case VoiceIntentType.gameLaunch:
        final gameType = intent.parameters['gameType'] as String? ?? 'any';
        onLaunchGame?.call(gameType);
        final gameName = gameType == 'memory_match'
            ? 'Memory Match'
            : gameType == 'pattern_recognition'
                ? 'Pattern Recognition'
                : 'Daily Routine Recall';
        final text = 'Starting $gameName. Have fun!';
        return VoiceResponse(
          spokenText: text,
          visualText: text,
          actionTaken: 'launch_game',
        );

      case VoiceIntentType.greeting:
        final text = AppStrings.get('voiceGreetingResponse', locale: lang);
        return VoiceResponse(
          spokenText: text,
          visualText: text,
          actionTaken: 'greeting',
        );

      case VoiceIntentType.unknown:
        final text = AppStrings.get('voiceUnknownIntent', locale: lang);
        return VoiceResponse(
          spokenText: text,
          visualText: text,
          actionTaken: 'unknown_intent',
        );
    }
  }
}
