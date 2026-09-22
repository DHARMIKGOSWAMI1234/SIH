/// Data models for the SMRITI Voice Interaction pipeline.
library;

enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

enum VoiceIntentType {
  familyQuery,
  reminderQuery,
  routineQuery,
  gameLaunch,
  greeting,
  medicalQuery,
  unknown;

  static const VoiceIntentType queryFamily = VoiceIntentType.familyQuery;
  static const VoiceIntentType queryReminders = VoiceIntentType.reminderQuery;
  static const VoiceIntentType queryRoutines = VoiceIntentType.routineQuery;
  static const VoiceIntentType launchGame = VoiceIntentType.gameLaunch;
  static const VoiceIntentType medicalBoundary = VoiceIntentType.medicalQuery;
}

class VoiceIntent {
  final VoiceIntentType type;
  final String rawText;
  final double confidence;
  final Map<String, dynamic> parameters;

  const VoiceIntent({
    required this.type,
    required this.rawText,
    this.confidence = 1.0,
    this.parameters = const {},
  });

  String? get extractedEntity =>
      parameters['entity'] as String? ??
      parameters['relation'] as String? ??
      parameters['gameType'] as String?;
}

class VoiceResponse {
  final String spokenText;
  final String visualText;
  final bool isSuccess;
  final String? actionTaken;

  const VoiceResponse({
    required this.spokenText,
    required this.visualText,
    this.isSuccess = true,
    this.actionTaken,
  });
}

class VoiceServiceResult {
  final VoiceIntent intent;
  final VoiceResponse response;

  const VoiceServiceResult({
    required this.intent,
    required this.response,
  });

  String get spokenText => response.spokenText;
  String get visualText => response.visualText;
  bool get isSuccess => response.isSuccess;
  String? get actionTaken => response.actionTaken;
}

/// Capability record for each supported language.
/// Strictly distinguishes architecturally supported from verified capabilities.
class LanguageCapability {
  final String languageCode;
  final String languageName;
  final String nativeName;
  final bool localizationSupported;
  final bool translationReviewed;
  final bool ttsSupported;
  final bool ttsVerifiedOnDevice;
  final bool asrSupported;
  final bool asrVerifiedOnDevice;
  final bool offlineTtsVerified;
  final bool offlineAsrVerified;

  const LanguageCapability({
    required this.languageCode,
    required this.languageName,
    required this.nativeName,
    required this.localizationSupported,
    required this.translationReviewed,
    required this.ttsSupported,
    required this.ttsVerifiedOnDevice,
    required this.asrSupported,
    required this.asrVerifiedOnDevice,
    required this.offlineTtsVerified,
    required this.offlineAsrVerified,
  });

  String get englishName => languageName;
}

