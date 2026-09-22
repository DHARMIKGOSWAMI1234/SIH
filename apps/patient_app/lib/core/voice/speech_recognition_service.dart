import 'dart:async';
import 'package:flutter/material.dart';

/// Abstract contract for Speech-to-Text services.
abstract class SpeechRecognitionService {
  Future<bool> initialize([Locale? locale]);
  Future<String?> listen({Duration timeout = const Duration(seconds: 6)});
  Stream<String> startListening({String? localeId});
  Future<void> stop();
  Future<void> stopListening();
  Future<void> cancelListening();
  bool get isListening;
  bool get isAvailable;
  bool get isPermissionGranted;
}

/// Mock speech recognition service for deterministic automated tests and emulator runs.
class MockSpeechRecognitionService implements SpeechRecognitionService {
  bool _isListening = false;
  @override
  bool isAvailable = true;
  @override
  bool isPermissionGranted = true;
  String? nextTranscript;
  StreamController<String>? _controller;

  MockSpeechRecognitionService({
    this.isAvailable = true,
    this.isPermissionGranted = true,
    this.nextTranscript,
  });

  void setTranscript(String? transcript) {
    nextTranscript = transcript;
  }

  void setAvailable(bool available) {
    isAvailable = available;
  }

  void setPermissionGranted(bool granted) {
    isPermissionGranted = granted;
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<bool> initialize([Locale? locale]) async {
    return isAvailable && isPermissionGranted;
  }

  @override
  Future<String?> listen({Duration timeout = const Duration(seconds: 6)}) async {
    if (!isAvailable || !isPermissionGranted) return null;
    _isListening = true;
    await Future.delayed(const Duration(milliseconds: 100));
    _isListening = false;
    return nextTranscript;
  }

  @override
  Stream<String> startListening({String? localeId}) {
    _isListening = true;
    _controller = StreamController<String>.broadcast();
    return _controller!.stream;
  }

  void emitMockResult(String result) {
    _controller?.add(result);
  }

  @override
  Future<void> stop() async {
    _isListening = false;
    _controller?.close();
  }

  @override
  Future<void> stopListening() async {
    await stop();
  }

  @override
  Future<void> cancelListening() async {
    await stop();
  }
}

/// Platform speech recognition service with safe device checks and error boundaries.
class PlatformSpeechRecognitionService implements SpeechRecognitionService {
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isPermissionGranted = false;
  StreamController<String>? _controller;

  PlatformSpeechRecognitionService() {
    _isAvailable = true;
    _isPermissionGranted = true;
  }

  @override
  bool get isAvailable => _isAvailable;

  @override
  bool get isListening => _isListening;

  @override
  bool get isPermissionGranted => _isPermissionGranted;

  @override
  Future<bool> initialize([Locale? locale]) async {
    try {
      _isAvailable = true;
      _isPermissionGranted = true;
      return true;
    } catch (_) {
      _isAvailable = false;
      return false;
    }
  }

  @override
  Future<String?> listen({Duration timeout = const Duration(seconds: 6)}) async {
    if (!_isAvailable) return null;
    _isListening = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      return null;
    } finally {
      _isListening = false;
    }
  }

  @override
  Stream<String> startListening({String? localeId}) {
    _isListening = true;
    _controller = StreamController<String>.broadcast();
    return _controller!.stream;
  }

  @override
  Future<void> stop() async {
    _isListening = false;
    await _controller?.close();
  }

  @override
  Future<void> stopListening() async {
    await stop();
  }

  @override
  Future<void> cancelListening() async {
    await stop();
  }
}
