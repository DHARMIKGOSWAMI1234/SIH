import 'package:flutter/material.dart';
import '../../../data/local/database/app_database.dart';

/// Reusable domain model for BANDHU Personal Memory Bank.
///
/// Categories:
/// - family: Family Photos & Loved ones
/// - relatives: Relatives & Extended family
/// - places: Childhood Places & Meaningful locations
/// - food: Favourite Foods & Traditional recipes
/// - events: Important Events & Celebrations
/// - voice: Voice Memories & Spoken stories
/// - objects: Familiar Objects & Heirlooms
/// - other: Other personal recollections
class PersonalMemory {
  final String id;
  final String? patientId;
  final String title;
  final String description;
  final String category;
  final String? imagePath;
  final String? voicePath;
  final String? relationship;
  final String? location;
  final DateTime? date;
  final DateTime createdAt;
  final String createdBy; // 'patient', 'caregiver', 'family_connect'
  final bool isFavorite;

  const PersonalMemory({
    required this.id,
    this.patientId,
    required this.title,
    required this.description,
    this.category = 'family',
    this.imagePath,
    this.voicePath,
    this.relationship,
    this.location,
    this.date,
    required this.createdAt,
    this.createdBy = 'patient',
    this.isFavorite = false,
  });

  /// Check if memory was contributed by family or caregiver
  bool get isContributedByFamily => createdBy == 'family_connect' || createdBy == 'caregiver';

  /// Category display name
  String get categoryDisplayName {
    switch (category) {
      case 'family':
        return 'Family Photos';
      case 'relatives':
        return 'Relatives';
      case 'places':
        return 'Childhood Places';
      case 'food':
        return 'Favourite Foods';
      case 'events':
        return 'Important Events';
      case 'voice':
        return 'Voice Memories';
      case 'objects':
        return 'Familiar Objects';
      default:
        return 'Cherished Memory';
    }
  }

  /// Category icon
  IconData get categoryIcon {
    switch (category) {
      case 'family':
        return Icons.photo_camera_rounded;
      case 'relatives':
        return Icons.people_rounded;
      case 'places':
        return Icons.landscape_rounded;
      case 'food':
        return Icons.restaurant_rounded;
      case 'events':
        return Icons.celebration_rounded;
      case 'voice':
        return Icons.mic_rounded;
      case 'objects':
        return Icons.auto_stories_rounded;
      default:
        return Icons.favorite_rounded;
    }
  }

  /// Create a domain [PersonalMemory] from a Drift [Memory] database row
  factory PersonalMemory.fromDrift(Memory drift) {
    return PersonalMemory(
      id: drift.localId,
      title: drift.title,
      description: drift.description,
      category: drift.category,
      imagePath: drift.imagePath ?? drift.mediaUri,
      voicePath: drift.audioPath,
      relationship: drift.relationship,
      location: drift.location,
      date: drift.eventDate,
      createdAt: drift.createdAt,
      createdBy: drift.source,
      isFavorite: drift.isFavorite,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'title': title,
      'description': description,
      'category': category,
      'imagePath': imagePath,
      'voicePath': voicePath,
      'relationship': relationship,
      'location': location,
      'date': date?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'isFavorite': isFavorite,
    };
  }

  factory PersonalMemory.fromJson(Map<String, dynamic> json) {
    return PersonalMemory(
      id: json['id'] as String,
      patientId: json['patientId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: (json['category'] as String?) ?? 'family',
      imagePath: json['imagePath'] as String?,
      voicePath: json['voicePath'] as String?,
      relationship: json['relationship'] as String?,
      location: json['location'] as String?,
      date: json['date'] != null ? DateTime.tryParse(json['date'] as String) : null,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      createdBy: (json['createdBy'] as String?) ?? 'patient',
      isFavorite: (json['isFavorite'] as bool?) ?? false,
    );
  }
}
