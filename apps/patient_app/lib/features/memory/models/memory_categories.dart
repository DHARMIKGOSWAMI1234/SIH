import 'package:flutter/material.dart';

/// Controlled, semantic category system for SMRITI Personal Memory Bank.
/// 
/// Supported categories:
/// - family, friends, places, childhood, food, festivals,
///   traditions, importantEvents, dailyLife, objects, music, other.
enum MemoryCategory {
  family,
  friends,
  places,
  childhood,
  food,
  festivals,
  traditions,
  importantEvents,
  dailyLife,
  objects,
  music,
  other;

  String get id {
    switch (this) {
      case MemoryCategory.family:
        return 'family';
      case MemoryCategory.friends:
        return 'friends';
      case MemoryCategory.places:
        return 'places';
      case MemoryCategory.childhood:
        return 'childhood';
      case MemoryCategory.food:
        return 'food';
      case MemoryCategory.festivals:
        return 'festivals';
      case MemoryCategory.traditions:
        return 'traditions';
      case MemoryCategory.importantEvents:
        return 'important_events';
      case MemoryCategory.dailyLife:
        return 'daily_life';
      case MemoryCategory.objects:
        return 'objects';
      case MemoryCategory.music:
        return 'music';
      case MemoryCategory.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case MemoryCategory.family:
        return 'Family';
      case MemoryCategory.friends:
        return 'Friends';
      case MemoryCategory.places:
        return 'Places';
      case MemoryCategory.childhood:
        return 'Childhood';
      case MemoryCategory.food:
        return 'Food & Drinks';
      case MemoryCategory.festivals:
        return 'Festivals';
      case MemoryCategory.traditions:
        return 'Traditions';
      case MemoryCategory.importantEvents:
        return 'Important Events';
      case MemoryCategory.dailyLife:
        return 'Daily Life';
      case MemoryCategory.objects:
        return 'Objects';
      case MemoryCategory.music:
        return 'Music';
      case MemoryCategory.other:
        return 'Other';
    }
  }

  String get localizationKey {
    switch (this) {
      case MemoryCategory.family:
        return 'categoryFamily';
      case MemoryCategory.friends:
        return 'categoryFriends';
      case MemoryCategory.places:
        return 'categoryPlaces';
      case MemoryCategory.childhood:
        return 'categoryChildhood';
      case MemoryCategory.food:
        return 'categoryFood';
      case MemoryCategory.festivals:
        return 'categoryFestivals';
      case MemoryCategory.traditions:
        return 'categoryTraditions';
      case MemoryCategory.importantEvents:
        return 'categoryImportantEvents';
      case MemoryCategory.dailyLife:
        return 'categoryDailyLife';
      case MemoryCategory.objects:
        return 'categoryObjects';
      case MemoryCategory.music:
        return 'categoryMusic';
      case MemoryCategory.other:
        return 'categoryOther';
    }
  }

  IconData get icon {
    switch (this) {
      case MemoryCategory.family:
        return Icons.people_rounded;
      case MemoryCategory.friends:
        return Icons.group_rounded;
      case MemoryCategory.places:
        return Icons.landscape_rounded;
      case MemoryCategory.childhood:
        return Icons.child_care_rounded;
      case MemoryCategory.food:
        return Icons.restaurant_rounded;
      case MemoryCategory.festivals:
        return Icons.celebration_rounded;
      case MemoryCategory.traditions:
        return Icons.auto_stories_rounded;
      case MemoryCategory.importantEvents:
        return Icons.event_available_rounded;
      case MemoryCategory.dailyLife:
        return Icons.sunny;
      case MemoryCategory.objects:
        return Icons.category_rounded;
      case MemoryCategory.music:
        return Icons.music_note_rounded;
      case MemoryCategory.other:
        return Icons.bookmark_rounded;
    }
  }

  Color get color {
    switch (this) {
      case MemoryCategory.family:
        return const Color(0xFF2563EB); // Royal Blue
      case MemoryCategory.friends:
        return const Color(0xFF0284C7); // Sky Blue
      case MemoryCategory.places:
        return const Color(0xFF16A34A); // Forest Green
      case MemoryCategory.childhood:
        return const Color(0xFFEA580C); // Warm Orange
      case MemoryCategory.food:
        return const Color(0xFFD97706); // Amber
      case MemoryCategory.festivals:
        return const Color(0xFF9333EA); // Purple
      case MemoryCategory.traditions:
        return const Color(0xFFB45309); // Ochre
      case MemoryCategory.importantEvents:
        return const Color(0xFFDC2626); // Crimson
      case MemoryCategory.dailyLife:
        return const Color(0xFF0D9488); // Teal
      case MemoryCategory.objects:
        return const Color(0xFF4B5563); // Slate
      case MemoryCategory.music:
        return const Color(0xFFC026D3); // Magenta
      case MemoryCategory.other:
        return const Color(0xFF64748B); // Slate Muted
    }
  }

  static MemoryCategory fromId(String? id) {
    if (id == null) return MemoryCategory.other;
    return MemoryCategory.values.firstWhere(
      (c) => c.id == id || c.name == id,
      orElse: () => MemoryCategory.other,
    );
  }
}
