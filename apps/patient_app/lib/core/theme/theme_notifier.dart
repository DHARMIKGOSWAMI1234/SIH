import 'package:flutter/material.dart';
import '../auth/auth_storage.dart';

/// Manages application-wide theme state (Light, Dark, System) and persists user preference.
class ThemeNotifier extends ChangeNotifier {
  final AuthStorage storage;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isInitialized = false;

  ThemeNotifier({required this.storage});

  AuthStorage get _storage => storage;

  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;

  /// Loads persisted theme preference on app bootstrap.
  Future<void> initialize() async {
    try {
      final savedMode = await _storage.getThemeMode();
      if (savedMode != null) {
        if (savedMode == 'light') {
          _themeMode = ThemeMode.light;
        } else if (savedMode == 'dark') {
          _themeMode = ThemeMode.dark;
        } else if (savedMode == 'system') {
          _themeMode = ThemeMode.system;
        }
      } else {
        // Default to dark mode matching the reference aesthetic
        _themeMode = ThemeMode.dark;
      }
    } catch (_) {
      _themeMode = ThemeMode.dark;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Updates theme mode immediately and writes to persistent local storage.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();

    try {
      await _storage.saveThemeMode(mode.name);
    } catch (e) {
      debugPrint('[ThemeNotifier] Error saving theme mode: $e');
    }
  }
}
