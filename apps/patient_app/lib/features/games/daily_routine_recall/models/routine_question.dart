import 'dart:math';
import 'routine_item.dart';

/// Single chronological sequence question presented to the patient.
class RoutineQuestion {
  final String id;
  final int questionNumber;
  final String title;
  final String scenarioDescription;
  final List<RoutineItem> correctSequence;
  final List<RoutineItem> availableOptions;
  final List<RoutineItem> distractors;
  final int difficultyLevel;

  const RoutineQuestion({
    required this.id,
    required this.questionNumber,
    required this.title,
    required this.scenarioDescription,
    required this.correctSequence,
    required this.availableOptions,
    required this.distractors,
    required this.difficultyLevel,
  });

  int get stepCount => correctSequence.length;
}

/// Generator for culturally familiar and accessible daily routine recall questions.
class RoutineQuestionGenerator {
  static List<RoutineQuestion> generateQuestions({
    required int count,
    required int difficultyLevel, // 1: Easy, 2: Medium, 3: Hard
    Random? random,
  }) {
    final rng = random ?? Random();
    final List<RoutineQuestion> questions = [];

    // Catalog shortcuts
    const wake = RoutineCatalog.wakeUp;
    const brush = RoutineCatalog.brushTeeth;
    const tea = RoutineCatalog.morningTea;
    const bfast = RoutineCatalog.breakfast;
    const walk = RoutineCatalog.gardenWalk;
    const med = RoutineCatalog.scheduledMedicine;
    const lunch = RoutineCatalog.afternoonLunch;
    const rest = RoutineCatalog.afternoonRest;
    const eveTea = RoutineCatalog.eveningTea;
    const dinner = RoutineCatalog.eveningMeal;
    const sleep = RoutineCatalog.nightSleep;

    const midnightDist = RoutineCatalog.midnightSnack;
    const luggageDist = RoutineCatalog.luggagePacking;
    const airportDist = RoutineCatalog.airportBoarding;

    // Presets tailored per difficulty
    final List<_RoutineTemplate> templates;

    if (difficultyLevel == 1) {
      // Easy: 3 steps, 0 to 1 distractor
      templates = [
        const _RoutineTemplate(
          title: 'Morning Start',
          scenario: 'Arrange these morning activities in chronological order.',
          sequence: [wake, brush, tea],
          distractors: [],
        ),
        const _RoutineTemplate(
          title: 'Breakfast & Stroll',
          scenario: 'What order do these morning activities happen in?',
          sequence: [tea, bfast, walk],
          distractors: [midnightDist],
        ),
        const _RoutineTemplate(
          title: 'Evening Calm',
          scenario: 'Place these evening activities in order.',
          sequence: [eveTea, dinner, sleep],
          distractors: [],
        ),
        const _RoutineTemplate(
          title: 'Afternoon Relaxation',
          scenario: 'Arrange these midday steps in order.',
          sequence: [lunch, rest, eveTea],
          distractors: [luggageDist],
        ),
      ];
    } else if (difficultyLevel == 2) {
      // Medium: 4-5 steps, 1-2 distractors
      templates = [
        const _RoutineTemplate(
          title: 'Morning Journey',
          scenario: 'Put these 4 morning steps into the right daily sequence.',
          sequence: [wake, tea, bfast, walk],
          distractors: [midnightDist],
        ),
        const _RoutineTemplate(
          title: 'Daily Care & Lunch',
          scenario: 'Place these daily activities in chronological order.',
          sequence: [tea, bfast, med, lunch],
          distractors: [luggageDist],
        ),
        const _RoutineTemplate(
          title: 'Afternoon to Dinner',
          scenario: 'Follow the progression of the afternoon into evening.',
          sequence: [lunch, rest, eveTea, dinner],
          distractors: [airportDist],
        ),
        const _RoutineTemplate(
          title: 'Evening to Bedtime',
          scenario: 'Arrange these winding down steps in order.',
          sequence: [rest, eveTea, dinner, sleep],
          distractors: [midnightDist],
        ),
        const _RoutineTemplate(
          title: 'Midday Routine',
          scenario: 'Arrange these everyday steps from morning to afternoon.',
          sequence: [brush, tea, bfast, lunch],
          distractors: [luggageDist],
        ),
      ];
    } else {
      // Hard: 5-6 steps, 2 distractors
      templates = [
        const _RoutineTemplate(
          title: 'Full Morning Progression',
          scenario: 'Organize this comprehensive morning routine in order.',
          sequence: [wake, brush, tea, bfast, walk],
          distractors: [midnightDist, airportDist],
        ),
        const _RoutineTemplate(
          title: 'Morning to Midday Care',
          scenario: 'Arrange these 5 everyday steps in chronological order.',
          sequence: [brush, tea, bfast, med, lunch],
          distractors: [luggageDist, midnightDist],
        ),
        const _RoutineTemplate(
          title: 'Midday to Evening',
          scenario: 'Sequence these activities from midday to dinner.',
          sequence: [bfast, walk, lunch, rest, eveTea],
          distractors: [airportDist, luggageDist],
        ),
        const _RoutineTemplate(
          title: 'Afternoon to Night Sleep',
          scenario: 'Place these 5 activities from lunch to sleep in order.',
          sequence: [lunch, rest, eveTea, dinner, sleep],
          distractors: [midnightDist, airportDist],
        ),
        const _RoutineTemplate(
          title: 'Complete Day Snapshot',
          scenario: 'Connect key checkpoints of the day from sunrise to night.',
          sequence: [wake, tea, lunch, dinner, sleep],
          distractors: [luggageDist, midnightDist],
        ),
      ];
    }

    for (int i = 0; i < count; i++) {
      final template = templates[i % templates.length];

      // Prepare options: sequence items + distractors
      final options = List<RoutineItem>.from(template.sequence);
      options.addAll(template.distractors);
      options.shuffle(rng);

      questions.add(
        RoutineQuestion(
          id: 'routine_${difficultyLevel}_${i + 1}',
          questionNumber: i + 1,
          title: template.title,
          scenarioDescription: template.scenario,
          correctSequence: List<RoutineItem>.from(template.sequence),
          availableOptions: options,
          distractors: List<RoutineItem>.from(template.distractors),
          difficultyLevel: difficultyLevel,
        ),
      );
    }

    return questions;
  }
}

class _RoutineTemplate {
  final String title;
  final String scenario;
  final List<RoutineItem> sequence;
  final List<RoutineItem> distractors;

  const _RoutineTemplate({
    required this.title,
    required this.scenario,
    required this.sequence,
    required this.distractors,
  });
}
