import 'package:flutter/material.dart';
import '../../../../l10n/app_strings.dart';

/// Broad time-of-day category for routine progression.
enum RoutineTimeCategory {
  morning,
  afternoon,
  evening,
  night,
  distractor,
}

/// Cultural, familiar everyday activity item for Daily Routine Recall.
///
/// Uses semantic visual identifiers ([iconIdentifier], [colorIdentifier])
/// to maintain a clean domain boundary decoupled from UI frameworks,
/// with [RoutineVisualResolver] providing UI-layer mapping.
class RoutineItem {
  final String key;
  final String labelKey;
  final String defaultLabel;
  final String iconIdentifier;
  final String colorIdentifier;
  final String category;
  final RoutineTimeCategory timeCategory;
  final int chronologicalOrder;
  final String accessibilityDescription;
  final bool isDistractor;

  const RoutineItem({
    required this.key,
    required this.labelKey,
    required this.defaultLabel,
    required this.iconIdentifier,
    required this.colorIdentifier,
    required this.category,
    required this.timeCategory,
    required this.chronologicalOrder,
    required this.accessibilityDescription,
    this.isDistractor = false,
  });

  /// Get localized display label with fallback to [defaultLabel].
  String getLocalizedLabel(String locale) {
    return AppStrings.get(labelKey, locale: locale);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoutineItem &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => key.hashCode;
}

/// UI-layer visual resolver translating semantic identifiers into Flutter primitives.
class RoutineVisualResolver {
  static IconData getIcon(String iconIdentifier) {
    switch (iconIdentifier) {
      case 'sun':
        return Icons.wb_sunny_rounded;
      case 'clean_hands':
        return Icons.clean_hands_rounded;
      case 'tea_cup':
        return Icons.coffee_rounded;
      case 'breakfast':
        return Icons.restaurant_rounded;
      case 'walk':
        return Icons.directions_walk_rounded;
      case 'medicine':
        return Icons.medication_rounded;
      case 'lunch':
        return Icons.lunch_dining_rounded;
      case 'rest':
        return Icons.hotel_rounded;
      case 'evening_tea':
        return Icons.groups_rounded;
      case 'dinner':
        return Icons.dinner_dining_rounded;
      case 'night_sleep':
        return Icons.nightlight_round;
      case 'snack':
        return Icons.fastfood_rounded;
      case 'luggage':
        return Icons.luggage_rounded;
      case 'airport':
        return Icons.flight_takeoff_rounded;
      default:
        return Icons.schedule_rounded;
    }
  }

  static Color getColor(String colorIdentifier) {
    switch (colorIdentifier) {
      case 'amber':
        return const Color(0xFFD97706); // Warm amber
      case 'teal':
        return const Color(0xFF0D9488); // Calming teal
      case 'sage':
        return const Color(0xFF3B7A57); // SMRITI Restorative Sage
      case 'blue':
        return const Color(0xFF2563EB); // Trust blue
      case 'emerald':
        return const Color(0xFF059669); // Forest green
      case 'rose':
        return const Color(0xFFE11D48); // Gentle rose
      case 'indigo':
        return const Color(0xFF4F46E5); // Indigo evening
      case 'violet':
        return const Color(0xFF7C3AED); // Peaceful violet
      case 'slate':
        return const Color(0xFF475569); // Neutral slate
      default:
        return const Color(0xFF1E293B); // Deep slate default
    }
  }
}

/// Catalog of culturally familiar and safe everyday activities for NER elderly users.
class RoutineCatalog {
  static const RoutineItem wakeUp = RoutineItem(
    key: 'wake_up',
    labelKey: 'itemWakeUp',
    defaultLabel: 'Wake Up',
    iconIdentifier: 'sun',
    colorIdentifier: 'amber',
    category: 'Morning',
    timeCategory: RoutineTimeCategory.morning,
    chronologicalOrder: 1,
    accessibilityDescription: 'Waking up in the morning as the sun rises',
  );

  static const RoutineItem brushTeeth = RoutineItem(
    key: 'brush_teeth',
    labelKey: 'itemBrushTeeth',
    defaultLabel: 'Wash & Freshen Up',
    iconIdentifier: 'clean_hands',
    colorIdentifier: 'teal',
    category: 'Morning',
    timeCategory: RoutineTimeCategory.morning,
    chronologicalOrder: 2,
    accessibilityDescription: 'Washing face and brushing teeth in the morning',
  );

  static const RoutineItem morningTea = RoutineItem(
    key: 'morning_tea',
    labelKey: 'itemMorningTea',
    defaultLabel: 'Morning Tea',
    iconIdentifier: 'tea_cup',
    colorIdentifier: 'amber',
    category: 'Morning',
    timeCategory: RoutineTimeCategory.morning,
    chronologicalOrder: 3,
    accessibilityDescription: 'Warm cup of morning Assam tea',
  );

  static const RoutineItem breakfast = RoutineItem(
    key: 'breakfast',
    labelKey: 'itemBreakfast',
    defaultLabel: 'Breakfast',
    iconIdentifier: 'breakfast',
    colorIdentifier: 'emerald',
    category: 'Morning',
    timeCategory: RoutineTimeCategory.morning,
    chronologicalOrder: 4,
    accessibilityDescription: 'Fresh morning breakfast',
  );

  static const RoutineItem gardenWalk = RoutineItem(
    key: 'garden_walk',
    labelKey: 'itemGardenWalk',
    defaultLabel: 'Morning Walk',
    iconIdentifier: 'walk',
    colorIdentifier: 'sage',
    category: 'Morning',
    timeCategory: RoutineTimeCategory.morning,
    chronologicalOrder: 5,
    accessibilityDescription: 'Gentle walk in the morning garden',
  );

  /// Clinical safety notice: Strictly generic user/caregiver-entered sequence item.
  /// Does NOT provide medication timing, dosage, prescription, treatment, or medical advice.
  static const RoutineItem scheduledMedicine = RoutineItem(
    key: 'scheduled_medicine',
    labelKey: 'itemScheduledMedicine',
    defaultLabel: 'Scheduled Medicine',
    iconIdentifier: 'medicine',
    colorIdentifier: 'blue',
    category: 'Routine',
    timeCategory: RoutineTimeCategory.morning,
    chronologicalOrder: 6,
    accessibilityDescription: 'Scheduled medicine routine recorded by caregiver',
  );

  static const RoutineItem afternoonLunch = RoutineItem(
    key: 'afternoon_lunch',
    labelKey: 'itemAfternoonLunch',
    defaultLabel: 'Afternoon Lunch',
    iconIdentifier: 'lunch',
    colorIdentifier: 'emerald',
    category: 'Afternoon',
    timeCategory: RoutineTimeCategory.afternoon,
    chronologicalOrder: 7,
    accessibilityDescription: 'Afternoon midday lunch meal',
  );

  static const RoutineItem afternoonRest = RoutineItem(
    key: 'afternoon_rest',
    labelKey: 'itemAfternoonRest',
    defaultLabel: 'Afternoon Rest',
    iconIdentifier: 'rest',
    colorIdentifier: 'teal',
    category: 'Afternoon',
    timeCategory: RoutineTimeCategory.afternoon,
    chronologicalOrder: 8,
    accessibilityDescription: 'Quiet afternoon rest or nap',
  );

  static const RoutineItem eveningTea = RoutineItem(
    key: 'evening_tea',
    labelKey: 'itemEveningTea',
    defaultLabel: 'Evening Tea & Chat',
    iconIdentifier: 'evening_tea',
    colorIdentifier: 'amber',
    category: 'Evening',
    timeCategory: RoutineTimeCategory.evening,
    chronologicalOrder: 9,
    accessibilityDescription: 'Evening cup of tea with family conversation',
  );

  static const RoutineItem eveningMeal = RoutineItem(
    key: 'evening_meal',
    labelKey: 'itemEveningMeal',
    defaultLabel: 'Dinner',
    iconIdentifier: 'dinner',
    colorIdentifier: 'indigo',
    category: 'Evening',
    timeCategory: RoutineTimeCategory.evening,
    chronologicalOrder: 10,
    accessibilityDescription: 'Evening dinner meal with family',
  );

  static const RoutineItem nightSleep = RoutineItem(
    key: 'night_sleep',
    labelKey: 'itemNightSleep',
    defaultLabel: 'Night Sleep',
    iconIdentifier: 'night_sleep',
    colorIdentifier: 'violet',
    category: 'Night',
    timeCategory: RoutineTimeCategory.night,
    chronologicalOrder: 11,
    accessibilityDescription: 'Peaceful night sleep in bed',
  );

  // Distractors (out of ordinary routine / out of place activities)
  static const RoutineItem midnightSnack = RoutineItem(
    key: 'midnight_snack',
    labelKey: 'itemMidnightSnack',
    defaultLabel: 'Midnight Feast',
    iconIdentifier: 'snack',
    colorIdentifier: 'rose',
    category: 'Other',
    timeCategory: RoutineTimeCategory.distractor,
    chronologicalOrder: 99,
    accessibilityDescription: 'Midnight heavy feast out of regular routine',
    isDistractor: true,
  );

  static const RoutineItem luggagePacking = RoutineItem(
    key: 'luggage_packing',
    labelKey: 'itemLuggagePacking',
    defaultLabel: 'Packing Heavy Bags',
    iconIdentifier: 'luggage',
    colorIdentifier: 'slate',
    category: 'Other',
    timeCategory: RoutineTimeCategory.distractor,
    chronologicalOrder: 98,
    accessibilityDescription: 'Packing heavy travel suitcases',
    isDistractor: true,
  );

  static const RoutineItem airportBoarding = RoutineItem(
    key: 'airport_boarding',
    labelKey: 'itemAirportBoarding',
    defaultLabel: 'Airport Boarding',
    iconIdentifier: 'airport',
    colorIdentifier: 'blue',
    category: 'Other',
    timeCategory: RoutineTimeCategory.distractor,
    chronologicalOrder: 97,
    accessibilityDescription: 'Boarding an airplane at the airport',
    isDistractor: true,
  );

  static const List<RoutineItem> standardDailyItems = [
    wakeUp,
    brushTeeth,
    morningTea,
    breakfast,
    gardenWalk,
    scheduledMedicine,
    afternoonLunch,
    afternoonRest,
    eveningTea,
    eveningMeal,
    nightSleep,
  ];

  static const List<RoutineItem> distractors = [
    midnightSnack,
    luggagePacking,
    airportBoarding,
  ];

  static RoutineItem getByKey(String key) {
    for (final item in standardDailyItems) {
      if (item.key == key) return item;
    }
    for (final dist in distractors) {
      if (dist.key == key) return dist;
    }
    return wakeUp;
  }
}
