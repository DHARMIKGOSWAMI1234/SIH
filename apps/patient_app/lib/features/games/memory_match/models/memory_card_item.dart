import 'package:flutter/material.dart';

/// Cultural and familiar item for Memory Match cards.
class MemoryMatchItemDefinition {
  final String key;
  final String label;
  final IconData icon;
  final String category;
  final String? regionalContext;
  final String accessibilityDescription;

  const MemoryMatchItemDefinition({
    required this.key,
    required this.label,
    required this.icon,
    required this.category,
    this.regionalContext,
    required this.accessibilityDescription,
  });
}

/// Catalog of culturally familiar and safe everyday items for Memory Match.
class MemoryMatchCatalog {
  static const List<MemoryMatchItemDefinition> allItems = [
    MemoryMatchItemDefinition(
      key: 'tea_cup',
      label: 'Morning Tea',
      icon: Icons.coffee_rounded,
      category: 'Daily Routine',
      regionalContext: 'Assam & NER morning tradition',
      accessibilityDescription: 'Warm cup of morning Assam tea',
    ),
    MemoryMatchItemDefinition(
      key: 'flower',
      label: 'Garden Flower',
      icon: Icons.local_florist_rounded,
      category: 'Nature',
      regionalContext: 'Local flora and orchids',
      accessibilityDescription: 'Bright garden blossom flower',
    ),
    MemoryMatchItemDefinition(
      key: 'home',
      label: 'Family Home',
      icon: Icons.home_rounded,
      category: 'Daily Life',
      regionalContext: 'Peaceful home and hearth',
      accessibilityDescription: 'Warm family house with doorway',
    ),
    MemoryMatchItemDefinition(
      key: 'sun',
      label: 'Warm Sun',
      icon: Icons.wb_sunny_rounded,
      category: 'Nature',
      regionalContext: 'Morning sunrise',
      accessibilityDescription: 'Golden morning sunshine',
    ),
    MemoryMatchItemDefinition(
      key: 'apple',
      label: 'Sweet Fruit',
      icon: Icons.apple_rounded,
      category: 'Food',
      regionalContext: 'Fresh orchard produce',
      accessibilityDescription: 'Fresh red orchard fruit',
    ),
    MemoryMatchItemDefinition(
      key: 'drum',
      label: 'Festival Dhol',
      icon: Icons.music_note_rounded,
      category: 'Tradition',
      regionalContext: 'Bihu and folk melodies',
      accessibilityDescription: 'Traditional folk festival drum and melody',
    ),
    MemoryMatchItemDefinition(
      key: 'tree',
      label: 'Green Bamboo',
      icon: Icons.park_rounded,
      category: 'Nature',
      regionalContext: 'Lush North Eastern greenery',
      accessibilityDescription: 'Tall lush bamboo and evergreen tree',
    ),
    MemoryMatchItemDefinition(
      key: 'water',
      label: 'River Water',
      icon: Icons.water_drop_rounded,
      category: 'Nature',
      regionalContext: 'Brahmaputra and hill streams',
      accessibilityDescription: 'Pure refreshing flowing water drop',
    ),
  ];
}

/// Runtime instance of a card in the Memory Match grid.
class MemoryCardTile {
  final String instanceId;
  final MemoryMatchItemDefinition item;
  bool isFaceUp;
  bool isMatched;
  bool isHighlighted; // Used for supportive hints

  MemoryCardTile({
    required this.instanceId,
    required this.item,
    this.isFaceUp = false,
    this.isMatched = false,
    this.isHighlighted = false,
  });

  String get semanticLabel {
    if (isMatched) {
      return '${item.label}, already matched';
    } else if (isFaceUp) {
      return '${item.label}, revealed';
    } else {
      return 'Hidden card';
    }
  }
}
