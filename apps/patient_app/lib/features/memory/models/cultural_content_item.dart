/// Represents a culturally familiar item from the North Eastern Region (NER).
///
/// Strictly non-clinical, ethically governed with transparent provenance,
/// source citation, and open licensing metadata.
class CulturalContentItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String region;
  final String language;
  final String? imagePath;
  final String? audioPath;
  final int difficulty;
  final List<String> tags;
  final String altText;
  final String source;
  final String license;
  final String? attribution;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CulturalContentItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.region,
    this.language = 'en',
    this.imagePath,
    this.audioPath,
    this.difficulty = 1,
    this.tags = const [],
    required this.altText,
    required this.source,
    required this.license,
    this.attribution,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'region': region,
      'language': language,
      'imagePath': imagePath,
      'audioPath': audioPath,
      'difficulty': difficulty,
      'tags': tags,
      'altText': altText,
      'source': source,
      'license': license,
      'attribution': attribution,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory CulturalContentItem.fromJson(Map<String, dynamic> json) {
    return CulturalContentItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      region: json['region'] as String,
      language: (json['language'] as String?) ?? 'en',
      imagePath: json['imagePath'] as String?,
      audioPath: json['audioPath'] as String?,
      difficulty: (json['difficulty'] as int?) ?? 1,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      altText: json['altText'] as String,
      source: json['source'] as String,
      license: json['license'] as String,
      attribution: json['attribution'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
