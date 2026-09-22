import 'package:flutter/material.dart';
import '../core/auth/auth_service.dart';
import '../core/auth/auth_storage.dart';
import 'app_strings.dart';
import 'framework_locale_mapper.dart';

/// Reactive provider for the active application language.
/// Notifies listeners on change to rebuild all widgets dynamically without app restart.
class LocaleNotifier extends ChangeNotifier {
  final AuthStorage authStorage;
  final AuthService? authService;
  String _currentLocale = 'en';

  LocaleNotifier({
    required this.authStorage,
    this.authService,
    String initialLocale = 'en',
  }) : _currentLocale = initialLocale;

  /// The SMRITI application locale code (e.g. 'en', 'hi', 'as', 'bn', 'mni', 'brx', 'lus', 'kha', 'grt').
  String get currentLocale => _currentLocale;

  /// The SMRITI application locale object.
  Locale get smritiLocale => Locale(_currentLocale);

  /// Backwards-compatible alias for smritiLocale.
  Locale get locale => Locale(_currentLocale);

  /// The Flutter framework Material-compatible locale.
  /// Used exclusively by MaterialApp / Flutter framework widgets so that
  /// MaterialLocalizations is always guaranteed to be loaded and never crashes.
  Locale get frameworkLocale => FrameworkLocaleMapper.toFrameworkLocale(_currentLocale);

  /// Human-readable name of the current language.
  String get currentLanguageName {
    final item = AppStrings.supportedLanguages.firstWhere(
      (l) => l.code == _currentLocale,
      orElse: () => AppStrings.supportedLanguages.first,
    );
    return item.nativeName;
  }

  /// Whether current language has been human-verified for clinical elderly use.
  bool get isCurrentLanguageReviewed => AppStrings.isLanguageReviewed(_currentLocale);

  /// Changes the active language, persists locally, and attempts background sync.
  Future<void> setLocale(String newLocale) async {
    if (!AppStrings.supportedLanguages.any((l) => l.code == newLocale)) {
      return;
    }
    if (_currentLocale == newLocale) return;

    _currentLocale = newLocale;
    notifyListeners();

    // Persist to local storage
    try {
      await authStorage.savePreferredLanguage(newLocale);
    } catch (_) {
      // Storage error ignored
    }

    // Sync to backend profile if authenticated
    if (authService != null && authService!.isAuthenticated) {
      try {
        await authService!.updatePatientProfile(preferredLanguage: newLocale);
      } catch (_) {
        // Will sync on next online sync cycle
      }
    }
  }

  /// Initializes language preference from storage or session.
  Future<void> initialize() async {
    try {
      final stored = await authStorage.getPreferredLanguage();
      if (stored != null && AppStrings.supportedLanguages.any((l) => l.code == stored)) {
        _currentLocale = stored;
        notifyListeners();
      } else if (authService?.session?.preferredLanguage != null) {
        final sessionLang = authService!.session!.preferredLanguage;
        if (AppStrings.supportedLanguages.any((l) => l.code == sessionLang)) {
          _currentLocale = sessionLang;
          notifyListeners();
        }
      }
    } catch (_) {
      // Fallback to default
    }
  }
}
