import 'package:flutter/material.dart';
import '../../../../l10n/app_strings.dart';

/// Cultural and familiar visual element used in Pattern Recognition sequences.
class PatternItem {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final String accessibilityDescription;

  final String? labelKey;
  final String? category;

  const PatternItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.accessibilityDescription,
    this.labelKey,
    this.category,
  });

  /// Get localized display label with fallback to [label].
  String getLocalizedLabel([String locale = 'en']) {
    if (labelKey != null && labelKey!.isNotEmpty) {
      return AppStrings.get(labelKey!, locale: locale);
    }
    return label;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PatternItem && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}

/// Catalog of accessible, high-contrast, culturally familiar items for Pattern Recognition.
class PatternCatalog {
  static const PatternItem apple = PatternItem(
    key: 'apple',
    labelKey: 'patternItemApple',
    label: 'Red Apple',
    icon: Icons.apple_rounded,
    color: Color(0xFFDC2626), // Crisp red
    accessibilityDescription: 'Red harvest apple',
    category: 'fruit',
  );

  static const PatternItem flower = PatternItem(
    key: 'flower',
    labelKey: 'patternItemFlower',
    label: 'Garden Flower',
    icon: Icons.local_florist_rounded,
    color: Color(0xFFD97706), // Warm marigold orange
    accessibilityDescription: 'Bright orange garden flower',
    category: 'nature',
  );

  static const PatternItem teaCup = PatternItem(
    key: 'tea_cup',
    labelKey: 'patternItemTeaCup',
    label: 'Warm Tea',
    icon: Icons.coffee_rounded,
    color: Color(0xFF0D9488), // Calming teal
    accessibilityDescription: 'Warm cup of Assam tea',
    category: 'food',
  );

  static const PatternItem sun = PatternItem(
    key: 'sun',
    labelKey: 'patternItemSun',
    label: 'Bright Sun',
    icon: Icons.wb_sunny_rounded,
    color: Color(0xFFEAB308), // Sunny golden yellow
    accessibilityDescription: 'Golden morning sunshine',
    category: 'nature',
  );

  static const PatternItem leaf = PatternItem(
    key: 'leaf',
    labelKey: 'patternItemLeaf',
    label: 'Bamboo Leaf',
    icon: Icons.eco_rounded,
    color: Color(0xFF16A34A), // Fresh green
    accessibilityDescription: 'Fresh green bamboo leaf',
    category: 'nature',
  );

  static const PatternItem home = PatternItem(
    key: 'home',
    labelKey: 'patternItemHome',
    label: 'Family Home',
    icon: Icons.home_rounded,
    color: Color(0xFF2563EB), // Trust blue
    accessibilityDescription: 'Peaceful family home',
    category: 'household',
  );

  static const PatternItem drum = PatternItem(
    key: 'drum',
    labelKey: 'patternItemDrum',
    label: 'Festival Drum',
    icon: Icons.music_note_rounded,
    color: Color(0xFF7C3AED), // Festive violet
    accessibilityDescription: 'Rhythmic festival drum note',
    category: 'culture',
  );

  static const PatternItem boat = PatternItem(
    key: 'boat',
    labelKey: 'patternItemBoat',
    label: 'River Boat',
    icon: Icons.sailing_rounded,
    color: Color(0xFF0284C7), // River blue
    accessibilityDescription: 'River boat on gentle water',
    category: 'culture',
  );

  static const List<PatternItem> allItems = [
    apple,
    flower,
    teaCup,
    sun,
    leaf,
    home,
    drum,
    boat,
  ];

  static PatternItem getByKey(String key) {
    return allItems.firstWhere(
      (item) => item.key == key,
      orElse: () => apple,
    );
  }
}
