import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Available self-reported mood ratings.
///
/// Strictly non-clinical, self-reported daily reflection.
enum MoodType {
  good,
  okay,
  notGreat,
  sad,
}

extension MoodTypeExtension on MoodType {
  String get code {
    switch (this) {
      case MoodType.good:
        return 'good';
      case MoodType.okay:
        return 'okay';
      case MoodType.notGreat:
        return 'not_great';
      case MoodType.sad:
        return 'sad';
    }
  }

  String get emoji {
    switch (this) {
      case MoodType.good:
        return '😊';
      case MoodType.okay:
        return '🙂';
      case MoodType.notGreat:
        return '😐';
      case MoodType.sad:
        return '😔';
    }
  }

  String get label {
    switch (this) {
      case MoodType.good:
        return 'Good';
      case MoodType.okay:
        return 'Okay';
      case MoodType.notGreat:
        return 'Not great';
      case MoodType.sad:
        return 'Sad';
    }
  }

  static MoodType fromCode(String code) {
    switch (code) {
      case 'good':
        return MoodType.good;
      case 'okay':
        return MoodType.okay;
      case 'not_great':
        return MoodType.notGreat;
      case 'sad':
        return MoodType.sad;
      default:
        return MoodType.good;
    }
  }
}

/// Model representing a daily self-reported check-in.
///
/// State: FULLY WORKING (locally persisted).
class MoodCheckIn {
  final String id;
  final MoodType mood;
  final DateTime timestamp;
  final String? note;

  const MoodCheckIn({
    required this.id,
    required this.mood,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'mood': mood.code,
        'timestamp': timestamp.toIso8601String(),
        'note': note,
      };

  factory MoodCheckIn.fromJson(Map<String, dynamic> json) {
    return MoodCheckIn(
      id: json['id'] as String? ?? 'checkin_${DateTime.now().millisecondsSinceEpoch}',
      mood: MoodTypeExtension.fromCode(json['mood'] as String? ?? 'good'),
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
      note: json['note'] as String?,
    );
  }
}

/// Local storage service for self-reported daily mood check-ins.
class MoodCheckInStorage {
  static const String _keyMoodList = 'smriti_daily_mood_checkins';
  final FlutterSecureStorage? _storage;
  static List<MoodCheckIn>? _memoryCache;

  MoodCheckInStorage({FlutterSecureStorage? storage, bool useInMemory = false})
      : _storage = useInMemory
            ? null
            : (storage ??
                const FlutterSecureStorage(
                  aOptions: AndroidOptions(encryptedSharedPreferences: true),
                ));

  Future<void> saveCheckIn(MoodCheckIn checkIn) async {
    final list = await getCheckIns();
    // Prepend new check-in
    list.insert(0, checkIn);
    // Keep last 30 check-ins locally
    if (list.length > 30) list.removeRange(30, list.length);
    _memoryCache = list;

    if (_storage != null) {
      try {
        final jsonStr = jsonEncode(list.map((c) => c.toJson()).toList());
        await _storage.write(key: _keyMoodList, value: jsonStr);
      } catch (_) {
        // In-memory fallback retains data for current session if platform storage is restricted
      }
    }
  }

  Future<List<MoodCheckIn>> getCheckIns() async {
    if (_memoryCache != null) return List.from(_memoryCache!);

    if (_storage != null) {
      try {
        final raw = await _storage.read(key: _keyMoodList);
        if (raw != null && raw.isNotEmpty) {
          final decoded = jsonDecode(raw) as List<dynamic>;
          final list = decoded
              .map((item) => MoodCheckIn.fromJson(item as Map<String, dynamic>))
              .toList();
          _memoryCache = list;
          return list;
        }
      } catch (_) {
        // Fallback
      }
    }

    _memoryCache = [];
    return [];
  }

  Future<MoodCheckIn?> getTodayCheckIn() async {
    final list = await getCheckIns();
    if (list.isEmpty) return null;
    final now = DateTime.now();
    for (final item in list) {
      if (item.timestamp.year == now.year &&
          item.timestamp.month == now.month &&
          item.timestamp.day == now.day) {
        return item;
      }
    }
    return null;
  }
}
