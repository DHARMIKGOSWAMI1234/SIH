import '../../../data/local/database/app_database.dart';

/// Recommended activity item model.
class ActivityRecommendation {
  final String id;
  final String title;
  final String description;
  final String targetRoute;
  final String category;
  final double priorityScore;

  const ActivityRecommendation({
    required this.id,
    required this.title,
    required this.description,
    required this.targetRoute,
    required this.category,
    required this.priorityScore,
  });
}

/// Abstract contract for Personalization Engine.
///
/// State: FUTURE ARCHITECTURE / PLACEHOLDER
/// Defines the API boundary for future AI/ML edge personalization models.
abstract class PersonalizationEngine {
  /// Returns recommended cognitive or memory activities based on patient context.
  Future<List<ActivityRecommendation>> getRecommendations({
    required List<Memory> personalMemories,
    required int completedActivitiesToday,
    DateTime? currentTime,
  });

  /// Evaluates appropriate cognitive game difficulty (1, 2, or 3).
  int evaluateGameLevel({
    required int recentSuccessCount,
    required int recentAttempts,
  });
}

/// Rule-based deterministic heuristic implementation for Phase 2.
///
/// State: HEURISTIC SCAFFOLD (Non-AI)
/// Provides immediate adaptive behavior using clear deterministic rules
/// without external AI APIs or black-box clinical inferences.
class LocalHeuristicPersonalizationEngine implements PersonalizationEngine {
  @override
  Future<List<ActivityRecommendation>> getRecommendations({
    required List<Memory> personalMemories,
    required int completedActivitiesToday,
    DateTime? currentTime,
  }) async {
    final now = currentTime ?? DateTime.now();
    final hour = now.hour;
    final list = <ActivityRecommendation>[];

    // Rule 1: Morning routine recommendation
    if (hour >= 6 && hour < 12) {
      list.add(const ActivityRecommendation(
        id: 'rec_morning_routine',
        title: 'Morning Routine Review',
        description: 'Start the day with peaceful familiar tea and daily check-in',
        targetRoute: '/my_day',
        category: 'Routine',
        priorityScore: 0.95,
      ));
    }

    // Rule 2: If personal memories exist, recommend Reminiscence
    if (personalMemories.isNotEmpty) {
      list.add(const ActivityRecommendation(
        id: 'rec_reminiscence',
        title: 'Cherished Memories Reflection',
        description: 'Revisit a family milestone or festive celebration together',
        targetRoute: '/memory/reminiscence',
        category: 'Reminiscence',
        priorityScore: 0.85,
      ));
    } else {
      list.add(const ActivityRecommendation(
        id: 'rec_familiar_world',
        title: 'Explore Familiar World',
        description: 'Identify traditional items and cultural symbols from the North East',
        targetRoute: '/memory/familiar_world',
        category: 'Cultural',
        priorityScore: 0.80,
      ));
    }

    // Rule 3: Afternoon / Evening calming music
    if (hour >= 16) {
      list.add(const ActivityRecommendation(
        id: 'rec_music',
        title: 'Calming Courtyard Melodies',
        description: 'Listen to soothing flute and traditional acoustic tunes',
        targetRoute: '/memory/music',
        category: 'Music',
        priorityScore: 0.90,
      ));
    } else {
      list.add(const ActivityRecommendation(
        id: 'rec_memory_match',
        title: 'Gentle Memory Match',
        description: 'Comfortable cognitive exercise to match familiar pairs',
        targetRoute: '/games/memory_match',
        category: 'Cognitive',
        priorityScore: 0.75,
      ));
    }

    // Sort by priority
    list.sort((a, b) => b.priorityScore.compareTo(a.priorityScore));
    return list;
  }

  @override
  int evaluateGameLevel({
    required int recentSuccessCount,
    required int recentAttempts,
  }) {
    if (recentAttempts == 0) return 1;
    final rate = recentSuccessCount / recentAttempts;
    if (rate >= 0.85 && recentAttempts >= 3) return 3;
    if (rate >= 0.60) return 2;
    return 1;
  }
}
