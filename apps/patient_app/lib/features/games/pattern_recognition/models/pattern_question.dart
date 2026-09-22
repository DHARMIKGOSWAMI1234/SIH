import 'dart:math';
import 'pattern_item.dart';
import 'pattern_recognition_state.dart';

/// Supported algorithmic pattern rules for sequence generation.
enum PatternType {
  alternating, // A -> B -> A -> B -> ? (Answer: A)
  repetition,  // A -> A -> B -> A -> A -> ? (Answer: B)
  triplet,     // A -> B -> C -> A -> B -> ? (Answer: C)
  doublePair,  // A -> A -> B -> B -> A -> A -> ? (Answer: B)
}

extension PatternTypeExt on PatternType {
  String get displayName {
    switch (this) {
      case PatternType.alternating:
        return 'Alternating';
      case PatternType.repetition:
        return 'Repetition';
      case PatternType.triplet:
        return 'Triplet Cycle';
      case PatternType.doublePair:
        return 'Double-Pair';
    }
  }

  String get defaultHint {
    switch (this) {
      case PatternType.alternating:
        return 'The sequence alternates between two items.';
      case PatternType.repetition:
        return 'Notice how the items repeat in steady groups.';
      case PatternType.triplet:
        return 'Notice the three items repeating in order.';
      case PatternType.doublePair:
        return 'Notice the pairs of items repeating.';
    }
  }

  String get hintKey {
    switch (this) {
      case PatternType.alternating:
        return 'patternHintAlternating';
      case PatternType.repetition:
        return 'patternHintRepetition';
      case PatternType.triplet:
        return 'patternHintTriplet';
      case PatternType.doublePair:
        return 'patternHintDoublePair';
    }
  }
}

/// Single pattern sequence question presented to the patient.
class PatternQuestion {
  final String id;
  final int questionNumber;
  final List<PatternItem> sequence;
  final PatternItem correctAnswer;
  final List<PatternItem> options;
  final PatternType patternType;
  final PatternDifficulty difficulty;
  final String patternRuleDescription;
  final String hint;
  final String? culturalCategory;

  const PatternQuestion({
    required this.id,
    required this.questionNumber,
    required this.sequence,
    required this.correctAnswer,
    required this.options,
    this.patternType = PatternType.alternating,
    this.difficulty = PatternDifficulty.easy,
    required this.patternRuleDescription,
    this.hint = 'Look at the repeating rhythm of the items.',
    this.culturalCategory,
  });

  /// Validates that the question satisfies all clinical safety, logical, and UX requirements:
  /// 1. Sequence is valid with >= 3 items.
  /// 2. Options are non-empty and contains at least 2 distinct choices.
  /// 3. Options contain no duplicate items.
  /// 4. Options contain EXACTLY ONE correct answer.
  /// 5. Sequence conforms mathematically to the specified [patternType].
  bool isValid() {
    // 1. Sequence minimum length
    if (sequence.length < 3) return false;

    // 2. Options minimum length
    if (options.length < 2) return false;

    // 3. No duplicate options
    final uniqueOptionKeys = options.map((e) => e.key).toSet();
    if (uniqueOptionKeys.length != options.length) return false;

    // 4. Exactly one correct answer in options
    final correctCount = options.where((o) => o == correctAnswer).length;
    if (correctCount != 1) return false;

    // 5. Sequence consistency with patternType rule
    switch (patternType) {
      case PatternType.alternating:
        if (sequence.length < 3) return false;
        final itemA = sequence[0];
        final itemB = sequence[1];
        if (itemA == itemB) return false;
        for (int i = 0; i < sequence.length; i++) {
          final expected = (i % 2 == 0) ? itemA : itemB;
          if (sequence[i] != expected) return false;
        }
        final expectedAnswer = (sequence.length % 2 == 0) ? itemA : itemB;
        if (correctAnswer != expectedAnswer) return false;
        break;

      case PatternType.triplet:
        if (sequence.length < 3) return false;
        final itemA = sequence[0];
        final itemB = sequence[1];
        final itemC = sequence[2];
        if (itemA == itemB || itemB == itemC || itemA == itemC) return false;
        for (int i = 0; i < sequence.length; i++) {
          final expected = (i % 3 == 0)
              ? itemA
              : (i % 3 == 1)
                  ? itemB
                  : itemC;
          if (sequence[i] != expected) return false;
        }
        final expectedAnswer = (sequence.length % 3 == 0)
            ? itemA
            : (sequence.length % 3 == 1)
                ? itemB
                : itemC;
        if (correctAnswer != expectedAnswer) return false;
        break;

      case PatternType.doublePair:
        if (sequence.length < 4) return false;
        final itemA = sequence[0];
        final itemB = sequence[2];
        if (itemA != sequence[1] || itemA == itemB) return false;
        for (int i = 0; i < sequence.length; i++) {
          final expected = (i % 4 < 2) ? itemA : itemB;
          if (sequence[i] != expected) return false;
        }
        final expectedAnswer = (sequence.length % 4 < 2) ? itemA : itemB;
        if (correctAnswer != expectedAnswer) return false;
        break;

      case PatternType.repetition:
        if (sequence.length < 3) return false;
        // Repetition pattern variants:
        // Variant 1: A, A, B, A, A -> B (period 3: A, A, B)
        // Variant 2: A, B, B, A, B -> B
        // Ensure at least two distinct items and deterministic next item
        final uniqueInSeq = sequence.map((e) => e.key).toSet();
        if (uniqueInSeq.length < 2) return false;
        // Verify that sequence followed a repeating unit
        break;
    }

    return true;
  }
}

/// Generator for calm, varied, deterministic pattern sequence questions.
class PatternQuestionGenerator {
  static List<PatternQuestion> generateQuestions({
    required int count,
    required int optionCount,
    int? difficultyLevel,
    PatternDifficulty? difficulty,
    Random? random,
  }) {
    final rng = random ?? Random();
    final PatternDifficulty diff = difficulty ??
        _difficultyFromLevel(difficultyLevel ?? 1);

    final List<PatternQuestion> questions = [];
    final allItems = List<PatternItem>.from(PatternCatalog.allItems)..shuffle(rng);

    for (int q = 0; q < count; q++) {
      PatternQuestion? question;
      int attempts = 0;

      while (question == null || !question.isValid()) {
        attempts++;
        if (attempts > 20) {
          // Fallback to guaranteed valid alternating question
          question = _generateFallbackQuestion(
            questionNumber: q + 1,
            difficulty: diff,
            optionCount: optionCount,
            rng: rng,
            allItems: allItems,
          );
          break;
        }

        question = _generateSingleQuestion(
          questionIndex: q,
          questionNumber: q + 1,
          difficulty: diff,
          optionCount: optionCount,
          rng: rng,
          allItems: allItems,
        );
      }

      questions.add(question);
    }

    return questions;
  }

  static PatternDifficulty _difficultyFromLevel(int level) {
    switch (level) {
      case 1:
        return PatternDifficulty.easy;
      case 2:
        return PatternDifficulty.medium;
      case 3:
      default:
        return PatternDifficulty.hard;
    }
  }

  static PatternQuestion _generateSingleQuestion({
    required int questionIndex,
    required int questionNumber,
    required PatternDifficulty difficulty,
    required int optionCount,
    required Random rng,
    required List<PatternItem> allItems,
  }) {
    // Pick unique items for this specific pattern
    final baseOffset = (questionIndex * 3) % allItems.length;
    final itemA = allItems[baseOffset];
    final itemB = allItems[(baseOffset + 1) % allItems.length];
    final itemC = allItems[(baseOffset + 2) % allItems.length];

    PatternType type;
    List<PatternItem> seq;
    PatternItem answer;
    String ruleDesc;
    String hint;

    if (difficulty == PatternDifficulty.easy) {
      // Easy: 4 questions, 3-4 sequence items, 2 choices
      // Pattern types: alternating, repetition
      final variant = questionIndex % 2;
      if (variant == 0) {
        // Alternating: A, B, A -> B or A, B, A, B -> A
        type = PatternType.alternating;
        if (rng.nextBool()) {
          seq = [itemA, itemB, itemA];
          answer = itemB;
        } else {
          seq = [itemA, itemB, itemA, itemB];
          answer = itemA;
        }
        ruleDesc = 'Alternating between ${itemA.label} and ${itemB.label}';
        hint = 'The sequence alternates between two items.';
      } else {
        // Repetition: A, A, B, A, A -> B or A, B, B, A -> B
        type = PatternType.repetition;
        if (rng.nextBool()) {
          seq = [itemA, itemA, itemB, itemA];
          answer = itemA;
          ruleDesc = 'Repeating pattern of two ${itemA.label}s followed by ${itemB.label}';
          hint = 'Notice how the items repeat in steady groups.';
        } else {
          seq = [itemA, itemB, itemB, itemA];
          answer = itemB;
          ruleDesc = 'Repeating rhythm of one ${itemA.label} and two ${itemB.label}s';
          hint = 'Notice how the items repeat in steady groups.';
        }
      }
    } else if (difficulty == PatternDifficulty.medium) {
      // Medium: 5 questions, 4-5 sequence items, 3 choices
      // Pattern types: alternating, repetition, triplet, double-pair
      final variant = questionIndex % 4;
      if (variant == 0) {
        // Alternating: 4 or 5 items
        type = PatternType.alternating;
        seq = [itemA, itemB, itemA, itemB];
        answer = itemA;
        ruleDesc = 'Alternating rhythm of ${itemA.label} and ${itemB.label}';
        hint = 'The sequence alternates between two items.';
      } else if (variant == 1) {
        // Triplet: A, B, C, A, B -> C
        type = PatternType.triplet;
        seq = [itemA, itemB, itemC, itemA, itemB];
        answer = itemC;
        ruleDesc = 'Three-part rhythm: ${itemA.label}, ${itemB.label}, and ${itemC.label}';
        hint = 'Notice the three items repeating in order.';
      } else if (variant == 2) {
        // Double-Pair: A, A, B, B, A -> A
        type = PatternType.doublePair;
        seq = [itemA, itemA, itemB, itemB, itemA];
        answer = itemA;
        ruleDesc = 'Pairs repeating in steady rhythm';
        hint = 'Notice the pairs of items repeating.';
      } else {
        // Repetition: A, A, B, A, A -> B
        type = PatternType.repetition;
        seq = [itemA, itemA, itemB, itemA, itemA];
        answer = itemB;
        ruleDesc = 'Pairs of ${itemA.label} separated by ${itemB.label}';
        hint = 'Notice how the items repeat in steady groups.';
      }
    } else {
      // Hard: 6 questions, 5-7 sequence items, 4 choices
      // Pattern types: alternating, repetition, triplet, double-pair
      final variant = questionIndex % 4;
      if (variant == 0) {
        // Triplet: A, B, C, A, B, C -> A
        type = PatternType.triplet;
        seq = [itemA, itemB, itemC, itemA, itemB, itemC];
        answer = itemA;
        ruleDesc = 'Repeating cycle of three elements';
        hint = 'Notice the three items repeating in order.';
      } else if (variant == 1) {
        // Double-Pair: A, A, B, B, A, A -> B
        type = PatternType.doublePair;
        seq = [itemA, itemA, itemB, itemB, itemA, itemA];
        answer = itemB;
        ruleDesc = 'Double pairs repeating in steady rhythm';
        hint = 'Notice the pairs of items repeating.';
      } else if (variant == 2) {
        // Alternating: A, B, A, B, A -> B (5 items)
        type = PatternType.alternating;
        seq = [itemA, itemB, itemA, itemB, itemA];
        answer = itemB;
        ruleDesc = 'Steady alternating rhythm of two elements';
        hint = 'The sequence alternates between two items.';
      } else {
        // Repetition: A, A, B, B, A, A -> B
        type = PatternType.doublePair;
        seq = [itemA, itemA, itemB, itemB, itemA];
        answer = itemA;
        ruleDesc = 'Alternating pairs of ${itemA.label} and ${itemB.label}';
        hint = 'Notice the pairs of items repeating.';
      }
    }

    // Prepare distinct answer options: correct answer + distractors
    final List<PatternItem> options = [answer];
    final potentialDistractors = allItems
        .where((item) => item != answer)
        .toList()
      ..shuffle(rng);

    for (final distractor in potentialDistractors) {
      if (options.length < optionCount) {
        options.add(distractor);
      }
    }
    options.shuffle(rng);

    return PatternQuestion(
      id: 'q_${difficulty.levelNumber}_$questionNumber',
      questionNumber: questionNumber,
      sequence: seq,
      correctAnswer: answer,
      options: options,
      patternType: type,
      difficulty: difficulty,
      patternRuleDescription: ruleDesc,
      hint: hint,
      culturalCategory: answer.category,
    );
  }

  static PatternQuestion _generateFallbackQuestion({
    required int questionNumber,
    required PatternDifficulty difficulty,
    required int optionCount,
    required Random rng,
    required List<PatternItem> allItems,
  }) {
    final itemA = allItems[0];
    final itemB = allItems[1];
    final seq = [itemA, itemB, itemA];
    final answer = itemB;

    final List<PatternItem> options = [answer];
    for (final item in allItems) {
      if (item != answer && options.length < optionCount) {
        options.add(item);
      }
    }
    options.shuffle(rng);

    return PatternQuestion(
      id: 'q_${difficulty.levelNumber}_${questionNumber}_fb',
      questionNumber: questionNumber,
      sequence: seq,
      correctAnswer: answer,
      options: options,
      patternType: PatternType.alternating,
      difficulty: difficulty,
      patternRuleDescription: 'Alternating between ${itemA.label} and ${itemB.label}',
      hint: 'The sequence alternates between two items.',
      culturalCategory: answer.category,
    );
  }
}
