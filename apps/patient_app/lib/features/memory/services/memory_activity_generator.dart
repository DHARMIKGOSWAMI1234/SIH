import 'dart:math';
import '../../../data/local/database/app_database.dart';
import '../models/memory_categories.dart';
import 'cultural_pack_service.dart';

enum MemoryActivityType {
  whoIsThis,
  whatIsThisPlace,
  doYouRecognizeThis,
  rememberThisPerson,
  memoryStory,
  familiarObject;

  String get label {
    switch (this) {
      case MemoryActivityType.whoIsThis:
        return 'Who is this?';
      case MemoryActivityType.whatIsThisPlace:
        return 'What is this place?';
      case MemoryActivityType.doYouRecognizeThis:
        return 'Do you recognize this?';
      case MemoryActivityType.rememberThisPerson:
        return 'Remember this person';
      case MemoryActivityType.memoryStory:
        return 'Memory Story';
      case MemoryActivityType.familiarObject:
        return 'Familiar Object';
    }
  }
}

class MemoryActivityQuestion {
  final String id;
  final MemoryActivityType type;
  final String questionText;
  final String promptTitle;
  final String promptSubtitle;
  final String? imagePath;
  final MemoryCategory category;
  final String correctAnswer;
  final List<String> options;
  final String hintText;
  final String? storyContent;

  const MemoryActivityQuestion({
    required this.id,
    required this.type,
    required this.questionText,
    required this.promptTitle,
    required this.promptSubtitle,
    this.imagePath,
    required this.category,
    required this.correctAnswer,
    required this.options,
    required this.hintText,
    this.storyContent,
  });
}

/// Generates personalized, data-driven memory recall and reminiscence activities.
///
/// Strictly non-clinical, zero fake personal data. Uses caregiver-approved
/// memories and verified NER cultural starter items.
class MemoryActivityGenerator {
  static final Random _random = Random();

  static const List<String> _commonRelationships = [
    'Grandson',
    'Granddaughter',
    'Daughter',
    'Son',
    'Friend',
    'Spouse',
    'Neighbor',
    'Sister',
    'Brother',
  ];

  /// Generates a set of activity questions based on available memories and cultural pack.
  static List<MemoryActivityQuestion> generateActivities({
    required List<Memory> personalMemories,
    int targetCount = 4,
  }) {
    final List<MemoryActivityQuestion> questions = [];

    // 1. Generate from Personal Memories with relationships or person names
    for (final mem in personalMemories) {
      if (questions.length >= targetCount) break;

      if (mem.personName != null && mem.personName!.isNotEmpty) {
        final correct = mem.relationship?.isNotEmpty == true
            ? mem.relationship!
            : mem.personName!;

        // Pick 2 distractors from other relationships
        final distractors = _commonRelationships
            .where((r) => r.toLowerCase() != correct.toLowerCase())
            .toList()
          ..shuffle(_random);

        final options = [correct, distractors[0], distractors[1]]..shuffle(_random);

        questions.add(
          MemoryActivityQuestion(
            id: 'act_${mem.localId}',
            type: MemoryActivityType.whoIsThis,
            questionText: 'Who is this familiar person?',
            promptTitle: mem.personName ?? mem.title,
            promptSubtitle: mem.description,
            imagePath: mem.imagePath ?? mem.mediaUri,
            category: MemoryCategory.fromId(mem.category),
            correctAnswer: correct,
            options: options,
            hintText: 'Think of your family: ${mem.title}',
            storyContent: mem.description,
          ),
        );
      } else if (mem.location != null && mem.location!.isNotEmpty) {
        final correct = mem.location!;
        final distractors = ['Tea Garden', 'Family Home', 'Riverside Park', 'Market']
            .where((l) => l.toLowerCase() != correct.toLowerCase())
            .toList()
          ..shuffle(_random);

        final options = [correct, distractors[0], distractors[1]]..shuffle(_random);

        questions.add(
          MemoryActivityQuestion(
            id: 'act_${mem.localId}',
            type: MemoryActivityType.whatIsThisPlace,
            questionText: 'What is this familiar place?',
            promptTitle: mem.title,
            promptSubtitle: mem.description,
            imagePath: mem.imagePath ?? mem.mediaUri,
            category: MemoryCategory.fromId(mem.category),
            correctAnswer: correct,
            options: options,
            hintText: 'This was a memorable visit: ${mem.location}',
            storyContent: mem.description,
          ),
        );
      }
    }

    // 2. Supplement with verified NER Cultural Pack items if personal memory count < targetCount
    if (questions.length < targetCount) {
      final culturalItems = CulturalPackService.getAllItems().toList()..shuffle(_random);
      for (final item in culturalItems) {
        if (questions.length >= targetCount) break;

        final correct = item.title;
        // Distractors from other cultural items
        final otherTitles = culturalItems
            .where((c) => c.id != item.id)
            .map((c) => c.title)
            .toList()
          ..shuffle(_random);

        final options = [correct, otherTitles[0], otherTitles[1]]..shuffle(_random);

        questions.add(
          MemoryActivityQuestion(
            id: 'cultural_${item.id}',
            type: item.category == 'places'
                ? MemoryActivityType.whatIsThisPlace
                : MemoryActivityType.doYouRecognizeThis,
            questionText: item.category == 'places'
                ? 'What is this beautiful place in ${item.region}?'
                : 'Do you recognize this tradition from ${item.region}?',
            promptTitle: item.title,
            promptSubtitle: item.description,
            category: MemoryCategory.fromId(item.category),
            correctAnswer: correct,
            options: options,
            hintText: 'A cherished part of ${item.region}: ${item.title}',
            storyContent: item.description,
          ),
        );
      }
    }

    return questions;
  }
}
