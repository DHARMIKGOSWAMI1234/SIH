import 'voice_models.dart';

/// Deterministic intent recognition service.
/// Evaluates spoken transcripts and maps them to structured intents.
/// Strictly enforces non-clinical boundaries.
class IntentService {
  /// Banned clinical diagnosis terms that immediately trigger the medical safety guardrail.
  static const List<String> _medicalKeywords = [
    'dementia',
    'alzheimer',
    'diagnos',
    'cure',
    'stage',
    'impairment',
    'disease',
    'am i sick',
    'prescribe',
    'medicine dose',
    'blood pressure',
    'doctor advice',
    'donepezil',
    'treatment',
    'getting worse',
  ];

  /// Static helper for tests and convenience.
  static VoiceIntent parse(String transcript) =>
      IntentService().recognizeIntent(transcript);

  /// Evaluates a raw transcript and returns a structured [VoiceIntent].
  VoiceIntent recognizeIntent(String transcript) {
    final clean = transcript.trim().toLowerCase();
    if (clean.isEmpty) {
      return const VoiceIntent(
        type: VoiceIntentType.unknown,
        rawText: '',
      );
    }

    // 1. Strict Medical Boundary Check
    for (final word in _medicalKeywords) {
      if (clean.contains(word)) {
        return VoiceIntent(
          type: VoiceIntentType.medicalQuery,
          rawText: transcript,
          parameters: {'keyword': word},
        );
      }
    }

    // 2. Family Member Name Queries
    // "Who is Ananya?", "Tell me about Rahul", "What is my grandson's name?"
    final whoIsMatch = RegExp(r'who is ([a-zA-Z\u0900-\u097F\u0980-\u09FF]+)', caseSensitive: false).firstMatch(transcript);
    if (whoIsMatch != null) {
      final name = whoIsMatch.group(1)?.replaceAll(RegExp(r'[\?\.\!]'), '').trim() ?? '';
      return VoiceIntent(
        type: VoiceIntentType.familyQuery,
        rawText: transcript,
        parameters: {'entity': name, 'relation': 'person'},
      );
    }

    final tellMeMatch = RegExp(r'tell me about ([a-zA-Z\u0900-\u097F\u0980-\u09FF]+)', caseSensitive: false).firstMatch(transcript);
    if (tellMeMatch != null) {
      final name = tellMeMatch.group(1)?.replaceAll(RegExp(r'[\?\.\!]'), '').trim() ?? '';
      return VoiceIntent(
        type: VoiceIntentType.familyQuery,
        rawText: transcript,
        parameters: {'entity': name, 'relation': 'person'},
      );
    }

    if (clean.contains('grandson') ||
        clean.contains('granddaughter') ||
        clean.contains('daughter') ||
        clean.contains('son') ||
        clean.contains('wife') ||
        clean.contains('husband') ||
        clean.contains('sister') ||
        clean.contains('brother') ||
        clean.contains('mother') ||
        clean.contains('father') ||
        clean.contains('पोता') ||
        clean.contains('बेटी') ||
        clean.contains('बेटा') ||
        clean.contains('নাতি') ||
        clean.contains('জীয়াৰী') ||
        clean.contains('ল’ৰা')) {
      String relation = 'family';
      if (clean.contains('grandson') || clean.contains('पोता') || clean.contains('নাতি')) {
        relation = 'grandson';
      } else if (clean.contains('daughter') || clean.contains('बेटी') || clean.contains('জীয়াৰী')) {
        relation = 'daughter';
      } else if (clean.contains('son') || clean.contains('बेटा') || clean.contains('ল’ৰা')) {
        relation = 'son';
      } else if (clean.contains('wife') || clean.contains('पत्नी')) {
        relation = 'wife';
      } else if (clean.contains('husband') || clean.contains('पति')) {
        relation = 'husband';
      }

      return VoiceIntent(
        type: VoiceIntentType.familyQuery,
        rawText: transcript,
        parameters: {'relation': relation, 'entity': relation},
      );
    }

    // 3. Game Launch Commands
    // "Let's play memory match", "Start pattern game", "Play routine recall"
    if (clean.contains('memory match') || clean.contains('match game') || clean.contains('कार्ड खेल')) {
      return VoiceIntent(
        type: VoiceIntentType.gameLaunch,
        rawText: transcript,
        parameters: {'gameType': 'memory_match', 'entity': 'memory_match'},
      );
    }
    if (clean.contains('pattern') || clean.contains('recognition') || clean.contains('पैटर्न') || clean.contains('ক্ৰম')) {
      return VoiceIntent(
        type: VoiceIntentType.gameLaunch,
        rawText: transcript,
        parameters: {'gameType': 'pattern_recognition', 'entity': 'pattern_recognition'},
      );
    }
    if (clean.contains('routine recall') || clean.contains('daily routine steps') || clean.contains('routine game')) {
      return VoiceIntent(
        type: VoiceIntentType.gameLaunch,
        rawText: transcript,
        parameters: {'gameType': 'routine_recall', 'entity': 'routine_recall'},
      );
    }
    if (clean.contains('start a game') || clean.contains('play game') || clean.contains('खेल शुरू करें')) {
      return VoiceIntent(
        type: VoiceIntentType.gameLaunch,
        rawText: transcript,
        parameters: {'gameType': 'any', 'entity': 'any'},
      );
    }

    // 4. Routine Queries
    // "What should I do today?", "Read my routine", "What is my routine", "Show my routine"
    if (clean.contains('do today') ||
        clean.contains('routine') ||
        clean.contains('दिनचर्या') ||
        clean.contains('নিয়ম')) {
      return VoiceIntent(
        type: VoiceIntentType.routineQuery,
        rawText: transcript,
      );
    }

    // 5. Reminder Queries
    // "What is my next reminder?", "When is my appointment?", "What medicine do I need to take?"
    if (clean.contains('reminder') ||
        clean.contains('appointment') ||
        clean.contains('next reminder') ||
        clean.contains('medicine') ||
        clean.contains('रिमाइंडर') ||
        clean.contains('सোঁৱৰণি')) {
      return VoiceIntent(
        type: VoiceIntentType.reminderQuery,
        rawText: transcript,
      );
    }

    // 6. Greetings
    if (clean.contains('hello') ||
        clean.contains('hi') ||
        clean.contains('good morning') ||
        clean.contains('good afternoon') ||
        clean.contains('good evening') ||
        clean.contains('नमस्ते') ||
        clean.contains('নমস্কাৰ')) {
      return VoiceIntent(
        type: VoiceIntentType.greeting,
        rawText: transcript,
      );
    }

    // 7. Unknown Intent
    return VoiceIntent(
      type: VoiceIntentType.unknown,
      rawText: transcript,
    );
  }
}
