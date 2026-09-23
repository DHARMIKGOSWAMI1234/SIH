/// Supported screen and feature identifiers for BANDHU Context-Aware Help.
enum HelpScreenId {
  home,
  games,
  memoryMatch,
  patternRecognition,
  routine,
  reminders,
  progress,
  profile,
  settings,
  caregiverPairing,
  personalMemory,
  lifeStory,
  familiarWorld,
  familyConnect,
  reminiscence,
  musicMemory,
  talkToMe,
  myDay,
  moodCheckIn,
  unknown;

  /// Map string representation to [HelpScreenId] with safe fallback to [unknown].
  static HelpScreenId fromString(String? key) {
    if (key == null) return HelpScreenId.unknown;
    final normalized = key.trim().toUpperCase().replaceAll('-', '_').replaceAll('/', '');
    switch (normalized) {
      case 'HOME':
        return HelpScreenId.home;
      case 'GAMES':
      case 'COGNITIVE_GAMES':
        return HelpScreenId.games;
      case 'MEMORY_MATCH':
      case 'MEMORYMATCH':
        return HelpScreenId.memoryMatch;
      case 'PATTERN_RECOGNITION':
      case 'PATTERNRECOGNITION':
      case 'PATTERN':
        return HelpScreenId.patternRecognition;
      case 'ROUTINE':
      case 'ROUTINE_RECALL':
      case 'DAILY_ROUTINE_RECALL':
        return HelpScreenId.routine;
      case 'REMINDERS':
        return HelpScreenId.reminders;
      case 'PROGRESS':
        return HelpScreenId.progress;
      case 'PROFILE':
        return HelpScreenId.profile;
      case 'SETTINGS':
        return HelpScreenId.settings;
      case 'CAREGIVER_PAIRING':
      case 'PAIRING':
      case 'CAREGIVER_CONNECTION':
        return HelpScreenId.caregiverPairing;
      case 'PERSONAL_MEMORY':
      case 'MEMORY':
      case 'MEMORY_BANK':
        return HelpScreenId.personalMemory;
      case 'LIFE_STORY':
      case 'MY_LIFE_STORY':
      case 'TIMELINE':
        return HelpScreenId.lifeStory;
      case 'FAMILIAR_WORLD':
      case 'CULTURAL_MEMORY':
        return HelpScreenId.familiarWorld;
      case 'FAMILY_CONNECT':
      case 'FAMILY_CONTRIBUTION':
        return HelpScreenId.familyConnect;
      case 'REMINISCENCE':
      case 'REMINISCENCE_MODE':
        return HelpScreenId.reminiscence;
      case 'MUSIC_MEMORY':
      case 'MUSIC':
        return HelpScreenId.musicMemory;
      case 'TALK_TO_ME':
      case 'COMPANION':
        return HelpScreenId.talkToMe;
      case 'MY_DAY':
      case 'DAILY_COMPANION':
        return HelpScreenId.myDay;
      case 'MOOD_CHECK_IN':
      case 'DAILY_CHECK_IN':
        return HelpScreenId.moodCheckIn;
      default:
        return HelpScreenId.unknown;
    }
  }

  /// String code conforming to the specification identifiers.
  String get code {
    switch (this) {
      case HelpScreenId.home:
        return 'HOME';
      case HelpScreenId.games:
        return 'GAMES';
      case HelpScreenId.memoryMatch:
        return 'MEMORY_MATCH';
      case HelpScreenId.patternRecognition:
        return 'PATTERN_RECOGNITION';
      case HelpScreenId.routine:
        return 'ROUTINE';
      case HelpScreenId.reminders:
        return 'REMINDERS';
      case HelpScreenId.progress:
        return 'PROGRESS';
      case HelpScreenId.profile:
        return 'PROFILE';
      case HelpScreenId.settings:
        return 'SETTINGS';
      case HelpScreenId.caregiverPairing:
        return 'CAREGIVER_PAIRING';
      case HelpScreenId.personalMemory:
        return 'PERSONAL_MEMORY';
      case HelpScreenId.lifeStory:
        return 'LIFE_STORY';
      case HelpScreenId.familiarWorld:
        return 'FAMILIAR_WORLD';
      case HelpScreenId.familyConnect:
        return 'FAMILY_CONNECT';
      case HelpScreenId.reminiscence:
        return 'REMINISCENCE';
      case HelpScreenId.musicMemory:
        return 'MUSIC_MEMORY';
      case HelpScreenId.talkToMe:
        return 'TALK_TO_ME';
      case HelpScreenId.myDay:
        return 'MY_DAY';
      case HelpScreenId.moodCheckIn:
        return 'MOOD_CHECK_IN';
      case HelpScreenId.unknown:
        return 'UNKNOWN';
    }
  }

  /// Localization key for user-facing screen name.
  String get localizationKey {
    switch (this) {
      case HelpScreenId.home:
        return 'helpScreenHome';
      case HelpScreenId.games:
        return 'helpScreenGames';
      case HelpScreenId.memoryMatch:
        return 'helpScreenMemoryMatch';
      case HelpScreenId.patternRecognition:
        return 'helpScreenPattern';
      case HelpScreenId.routine:
        return 'helpScreenRoutine';
      case HelpScreenId.reminders:
        return 'helpScreenReminders';
      case HelpScreenId.progress:
        return 'helpScreenProgress';
      case HelpScreenId.profile:
        return 'helpScreenProfile';
      case HelpScreenId.settings:
        return 'helpScreenSettings';
      case HelpScreenId.caregiverPairing:
        return 'helpScreenPairing';
      case HelpScreenId.personalMemory:
        return 'helpScreenPersonalMemory';
      case HelpScreenId.lifeStory:
        return 'helpScreenLifeStory';
      case HelpScreenId.familiarWorld:
        return 'helpScreenFamiliarWorld';
      case HelpScreenId.familyConnect:
        return 'helpScreenFamilyConnect';
      case HelpScreenId.reminiscence:
        return 'helpScreenReminiscence';
      case HelpScreenId.musicMemory:
        return 'helpScreenMusicMemory';
      case HelpScreenId.talkToMe:
        return 'helpScreenTalkToMe';
      case HelpScreenId.myDay:
        return 'helpScreenMyDay';
      case HelpScreenId.moodCheckIn:
        return 'helpScreenMoodCheckIn';
      case HelpScreenId.unknown:
        return 'helpScreenUnknown';
    }
  }

  /// Whether this screen represents an active cognitive game.
  bool get isGame {
    return this == HelpScreenId.memoryMatch ||
        this == HelpScreenId.patternRecognition ||
        this == HelpScreenId.routine ||
        this == HelpScreenId.familiarWorld;
  }
}
