import 'voice_models.dart';

/// Machine-readable language capability matrix for SMRITI (9 languages).
/// Strictly distinguishes architecturally supported features from verified features.
class VoiceCapabilityMatrix {
  static const List<LanguageCapability> matrix = [
    // 1. English
    LanguageCapability(
      languageCode: 'en',
      languageName: 'English',
      nativeName: 'English',
      localizationSupported: true,
      translationReviewed: true,
      ttsSupported: true,
      ttsVerifiedOnDevice: true,
      asrSupported: true,
      asrVerifiedOnDevice: true,
      offlineTtsVerified: true,
      offlineAsrVerified: false, // Requires on-device speech pack
    ),
    // 2. Hindi
    LanguageCapability(
      languageCode: 'hi',
      languageName: 'Hindi',
      nativeName: 'हिन्दी',
      localizationSupported: true,
      translationReviewed: true,
      ttsSupported: true,
      ttsVerifiedOnDevice: true,
      asrSupported: true,
      asrVerifiedOnDevice: true,
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
    // 3. Assamese
    LanguageCapability(
      languageCode: 'as',
      languageName: 'Assamese',
      nativeName: 'অসমীয়া',
      localizationSupported: true,
      translationReviewed: true,
      ttsSupported: true,
      ttsVerifiedOnDevice: false, // Architectural / pending device TTS pack
      asrSupported: true,
      asrVerifiedOnDevice: false, // Device dependent
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
    // 4. Bengali
    LanguageCapability(
      languageCode: 'bn',
      languageName: 'Bengali',
      nativeName: 'বাংলা',
      localizationSupported: true,
      translationReviewed: false, // Architectural / Translation review required
      ttsSupported: true,
      ttsVerifiedOnDevice: false,
      asrSupported: true,
      asrVerifiedOnDevice: false,
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
    // 5. Meitei / Manipuri
    LanguageCapability(
      languageCode: 'mni',
      languageName: 'Meitei / Manipuri',
      nativeName: 'মৈতৈলোন',
      localizationSupported: true,
      translationReviewed: false, // Architectural / Translation review required
      ttsSupported: false,
      ttsVerifiedOnDevice: false,
      asrSupported: false,
      asrVerifiedOnDevice: false,
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
    // 6. Bodo
    LanguageCapability(
      languageCode: 'brx',
      languageName: 'Bodo',
      nativeName: 'बर\'',
      localizationSupported: true,
      translationReviewed: false, // Architectural / Translation review required
      ttsSupported: false,
      ttsVerifiedOnDevice: false,
      asrSupported: false,
      asrVerifiedOnDevice: false,
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
    // 7. Mizo
    LanguageCapability(
      languageCode: 'lus',
      languageName: 'Mizo',
      nativeName: 'Mizo',
      localizationSupported: true,
      translationReviewed: false, // Architectural / Translation review required
      ttsSupported: false,
      ttsVerifiedOnDevice: false,
      asrSupported: false,
      asrVerifiedOnDevice: false,
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
    // 8. Khasi
    LanguageCapability(
      languageCode: 'kha',
      languageName: 'Khasi',
      nativeName: 'Khasi',
      localizationSupported: true,
      translationReviewed: false, // Architectural / Translation review required
      ttsSupported: false,
      ttsVerifiedOnDevice: false,
      asrSupported: false,
      asrVerifiedOnDevice: false,
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
    // 9. Garo
    LanguageCapability(
      languageCode: 'grt',
      languageName: 'Garo',
      nativeName: 'Garo',
      localizationSupported: true,
      translationReviewed: false, // Architectural / Translation review required
      ttsSupported: false,
      ttsVerifiedOnDevice: false,
      asrSupported: false,
      asrVerifiedOnDevice: false,
      offlineTtsVerified: false,
      offlineAsrVerified: false,
    ),
  ];

  /// Get capability details for a specific language code.
  static LanguageCapability getCapability(String languageCode) {
    return matrix.firstWhere(
      (c) => c.languageCode == languageCode,
      orElse: () => matrix.first,
    );
  }

  static List<LanguageCapability> get verifiedLanguages =>
      matrix.where((l) => l.translationReviewed).toList();

  static List<LanguageCapability> get reviewRequiredLanguages =>
      matrix.where((l) => !l.translationReviewed).toList();
}

