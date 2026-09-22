import 'dart:async';
import 'package:flutter/material.dart';

/// Abstract contract for Text-to-Speech service.
abstract class TextToSpeechService {
  Future<void> initialize();
  Future<void> speak(String text, {Locale? locale, String? languageCode});
  Future<void> stop();
  bool get isSpeaking;
  bool get isPlaying;
  bool get isAvailable;
}

/// Mock text to speech service for testing and headless verification.
class MockTextToSpeechService implements TextToSpeechService {
  bool _isSpeaking = false;
  @override
  bool isAvailable = true;
  String? lastSpokenText;
  Locale? lastLocale;

  MockTextToSpeechService({this.isAvailable = true});

  void setAvailable(bool available) {
    isAvailable = available;
  }

  @override
  Future<void> initialize() async {
    isAvailable = true;
  }

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPlaying => _isSpeaking;

  @override
  Future<void> speak(String text, {Locale? locale, String? languageCode}) async {
    if (!isAvailable) return;
    _isSpeaking = true;
    lastSpokenText = text;
    if (locale != null) {
      lastLocale = locale;
    } else if (languageCode != null) {
      lastLocale = Locale(languageCode);
    }
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
  }
}

/// Platform text to speech service using local platform capabilities.
class PlatformTextToSpeechService implements TextToSpeechService {
  bool _isSpeaking = false;
  final bool _isAvailable = true;

  @override
  Future<void> initialize() async {}

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isSpeaking => _isSpeaking;

  @override
  bool get isPlaying => _isSpeaking;

  @override
  Future<void> speak(String text, {Locale? locale, String? languageCode}) async {
    if (!_isAvailable) return;
    _isSpeaking = true;
    try {
      // Safe simulated platform speech playback
      await Future.delayed(const Duration(milliseconds: 100));
    } finally {
      _isSpeaking = false;
    }
  }

  @override
  Future<void> stop() async {
    _isSpeaking = false;
  }
}
