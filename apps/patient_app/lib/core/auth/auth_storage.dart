import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstract storage interface for authentication credentials and session metadata.
abstract class AuthStorage {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();

  Future<void> saveUserData(Map<String, dynamic> data);
  Future<Map<String, dynamic>?> getUserData();
  Future<void> deleteUserData();
  Future<void> savePreferredLanguage(String languageCode);
  Future<String?> getPreferredLanguage();
  Future<void> saveThemeMode(String mode);
  Future<String?> getThemeMode();

  Future<void> clear();
}

/// Secure platform storage implementing Android Keystore / EncryptedSharedPreferences,
/// iOS Keychain, and Web encrypted storage.
class SecureAuthStorage implements AuthStorage {
  static const String _keyToken = 'smriti_auth_token';
  static const String _keyUser = 'smriti_user_data';
  static const String _keyLang = 'smriti_preferred_language';
  static const String _keyTheme = 'smriti_theme_mode';

  final FlutterSecureStorage _storage;

  SecureAuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
            );

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  @override
  Future<void> deleteToken() async {
    await _storage.delete(key: _keyToken);
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> data) async {
    final encoded = jsonEncode(data);
    await _storage.write(key: _keyUser, value: encoded);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final raw = await _storage.read(key: _keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteUserData() async {
    await _storage.delete(key: _keyUser);
  }

  @override
  Future<void> savePreferredLanguage(String languageCode) async {
    await _storage.write(key: _keyLang, value: languageCode);
  }

  @override
  Future<String?> getPreferredLanguage() async {
    return await _storage.read(key: _keyLang);
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    await _storage.write(key: _keyTheme, value: mode);
  }

  @override
  Future<String?> getThemeMode() async {
    return await _storage.read(key: _keyTheme);
  }

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }
}

/// In-memory storage for unit tests and deterministic headless testing.
class InMemoryAuthStorage implements AuthStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> saveToken(String token) async {
    _data['token'] = token;
  }

  @override
  Future<String?> getToken() async {
    return _data['token'];
  }

  @override
  Future<void> deleteToken() async {
    _data.remove('token');
  }

  @override
  Future<void> saveUserData(Map<String, dynamic> data) async {
    _data['user'] = jsonEncode(data);
  }

  @override
  Future<Map<String, dynamic>?> getUserData() async {
    final raw = _data['user'];
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> deleteUserData() async {
    _data.remove('user');
  }

  @override
  Future<void> savePreferredLanguage(String languageCode) async {
    _data['lang'] = languageCode;
  }

  @override
  Future<String?> getPreferredLanguage() async {
    return _data['lang'];
  }

  @override
  Future<void> saveThemeMode(String mode) async {
    _data['theme_mode'] = mode;
  }

  @override
  Future<String?> getThemeMode() async {
    return _data['theme_mode'];
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

