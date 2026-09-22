import 'package:flutter/foundation.dart';

/// Configuration for backend API connectivity across platforms and environments.
class ApiConfig {
  static const String _envBaseUrl = String.fromEnvironment('API_BASE_URL');
  static const bool _useUsbReverse = bool.fromEnvironment('USE_USB_REVERSE', defaultValue: false);
  static const String _environment = String.fromEnvironment('ENVIRONMENT', defaultValue: 'development');

  /// Runtime override for testing or dynamic discovery.
  static String? runtimeBaseUrl;

  /// Resolves the reachable backend URL for the active platform:
  /// - Runtime override (if set via [runtimeBaseUrl]) takes precedence.
  /// - Explicit `--dart-define=API_BASE_URL=http://localhost:8000` (or any URL).
  /// - Physical Android development with `adb reverse tcp:8000 tcp:8000` via `--dart-define=USE_USB_REVERSE=true`: http://localhost:8000
  /// - Android emulator connects to host loopback: http://10.0.2.2:8000
  /// - Web, Desktop, and iOS simulators: http://localhost:8000
  /// - Production fallback: https://api.smriti.care (if ENVIRONMENT=production)
  static String get defaultBaseUrl {
    if (runtimeBaseUrl != null && runtimeBaseUrl!.isNotEmpty) {
      return runtimeBaseUrl!;
    }
    if (_envBaseUrl.isNotEmpty) {
      return _envBaseUrl;
    }
    if (_environment == 'production') {
      return 'https://api.smriti.care';
    }
    if (kIsWeb) {
      return 'http://localhost:8000';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (_useUsbReverse) {
        return 'http://localhost:8000';
      }
      return 'http://10.0.2.2:8000';
    }
    return 'http://localhost:8000';
  }
}
