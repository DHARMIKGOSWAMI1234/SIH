import '../../../data/local/repositories/smriti_repository.dart';

/// Structured, deterministic local memory retrieval service.
///
/// Strictly non-clinical, 100% offline, with zero external LLMs or hallucination.
/// Answers factual queries directly from local Memories, Reminders, and Routines.
/// Returns "I don't have that information yet." whenever a record is not found.
class MemoryRescueService {
  final SmritiRepository repository;

  const MemoryRescueService(this.repository);

  static const String fallbackMessage = "I don't have that information yet.";

  /// Answers a structured query using local SQLite records.
  Future<String> query(String queryText) async {
    final clean = queryText.trim().toLowerCase();
    if (clean.isEmpty) return fallbackMessage;

    // 1. Search Personal Memories
    final memories = await repository.getMemories(includeArchived: false);

    // Relationship query (e.g. "grandson", "daughter", "son", "friend", "wife", "husband")
    for (final mem in memories) {
      final rel = mem.relationship?.toLowerCase() ?? '';
      final name = mem.personName ?? '';
      if (rel.isNotEmpty && clean.contains(rel)) {
        if (name.isNotEmpty) {
          return '$name is your $rel.';
        }
        return 'Your $rel is mentioned in "${mem.title}".';
      }

      // Person name query (e.g. "Who is Rahul?", "Rahul")
      if (name.isNotEmpty && clean.contains(name.toLowerCase())) {
        if (rel.isNotEmpty) {
          return '$name is your $rel.';
        }
        return '$name is recorded in your memories under ${mem.category}.';
      }

      // Location query (e.g. "Where did we visit?", "Loktak")
      final loc = mem.location?.toLowerCase() ?? '';
      if (loc.isNotEmpty && clean.contains(loc)) {
        return '${mem.title} was at ${mem.location}.';
      }
    }

    // 2. Search Reminders
    final reminders = await repository.getReminders();
    for (final rem in reminders) {
      final remTitle = rem.title.toLowerCase();
      if (clean.contains(remTitle) ||
          clean.contains('reminder') ||
          clean.contains('medicine') ||
          clean.contains('appointment') ||
          clean.contains('water')) {
        if (rem.enabled) {
          return 'Your scheduled reminder for "${rem.title}" is at ${rem.scheduledTime}.';
        }
      }
    }

    // 3. Search Routines
    final routines = await repository.getRoutines();
    for (final rout in routines) {
      if (clean.contains(rout.title.toLowerCase()) || clean.contains('routine') || clean.contains('day')) {
        return 'Your daily routine "${rout.title}" is set for ${rout.preferredTime}.';
      }
    }

    // 4. Guaranteed deterministic fallback
    return fallbackMessage;
  }
}
