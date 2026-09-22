import 'package:flutter/material.dart';

/// Maps SMRITI application locales to Flutter framework Material-compatible locales.
/// 
/// SMRITI supports 9 regional languages:
/// - en: English
/// - hi: Hindi
/// - as: Assamese
/// - bn: Bengali
/// - mni: Meitei / Manipuri
/// - brx: Bodo
/// - lus: Mizo
/// - kha: Khasi
/// - grt: Garo
///
/// Flutter's built-in `GlobalMaterialLocalizations` provides translations for:
/// - en, hi, as, bn.
///
/// For regional North-East languages where Flutter does not supply built-in
/// Material translations (mni, brx, lus, kha, grt), this mapper safely provides
/// a fallback framework locale (en) so that `MaterialLocalizations` is ALWAYS
/// present in the widget tree, preventing the "No MaterialLocalizations found" crash.
///
/// CRITICAL: This mapping is ONLY for Flutter's internal MaterialLocalizations
/// (AppBar, BackButton, Dialog, Tooltip, etc.). It NEVER affects SMRITI application
/// text rendered through `AppStrings`, which always respects the user's selected language.
class FrameworkLocaleMapper {
  /// Locales that are guaranteed to have built-in Flutter MaterialLocalizations.
  static const List<Locale> supportedFrameworkLocales = [
    Locale('en'),
    Locale('hi'),
    Locale('as'),
    Locale('bn'),
  ];

  /// Set of language codes that Flutter GlobalMaterialLocalizations supports.
  static const Set<String> _supportedFrameworkCodes = {'en', 'hi', 'as', 'bn'};

  /// Maps a SMRITI locale code to a supported Flutter framework Locale.
  static Locale toFrameworkLocale(String smritiLocaleCode) {
    if (_supportedFrameworkCodes.contains(smritiLocaleCode)) {
      return Locale(smritiLocaleCode);
    }
    return const Locale('en');
  }

  /// Determines if Flutter's GlobalMaterialLocalizations natively supports the given code.
  static bool isFrameworkSupported(String smritiLocaleCode) {
    return _supportedFrameworkCodes.contains(smritiLocaleCode);
  }

  /// Safe locale resolution callback for MaterialApp.
  static Locale resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale != null) {
      for (final supported in supportedLocales) {
        if (supported.languageCode == locale.languageCode) {
          return supported;
        }
      }
    }
    return const Locale('en');
  }
}
