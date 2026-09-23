import '../models/help_context.dart';
import '../models/help_request.dart';
import '../models/help_response.dart';
import '../models/help_screen_id.dart';
import 'help_engine.dart';

/// Deterministic, offline-first help engine for BANDHU Phase 1.
/// Provides elderly-friendly, comforting responses without any external AI or cloud API dependencies.
class LocalHelpEngine implements HelpEngine {
  const LocalHelpEngine();

  @override
  Future<HelpResponse> getHelp(HelpContext context, HelpRequest request) async {
    // Phase 1: Pure local evaluation with zero network requests
    return _generateResponse(context, request);
  }

  HelpResponse _generateResponse(HelpContext context, HelpRequest request) {
    // If the user typed a custom query, attempt gentle keyword routing
    if (request.action == HelpActionType.customQuestion &&
        request.query != null &&
        request.query!.isNotEmpty) {
      return _handleCustomQuery(context, request.query!.toLowerCase());
    }

    switch (context.screenId) {
      case HelpScreenId.home:
        return _handleHomeScreen(request);

      case HelpScreenId.games:
        return _handleGamesScreen(request);

      case HelpScreenId.memoryMatch:
        return _handleMemoryMatch(context, request);

      case HelpScreenId.patternRecognition:
        return _handlePatternRecognition(context, request);

      case HelpScreenId.routine:
        return _handleRoutineRecall(context, request);

      case HelpScreenId.reminders:
        return _handleReminders(request);

      case HelpScreenId.progress:
        return _handleProgress(request);

      case HelpScreenId.profile:
        return _handleProfile(request);

      case HelpScreenId.settings:
        return _handleSettings(request);

      case HelpScreenId.caregiverPairing:
        return _handleCaregiverPairing(request);

      case HelpScreenId.personalMemory:
        return _handlePersonalMemory(request);

      case HelpScreenId.lifeStory:
        return _handleLifeStory(request);

      case HelpScreenId.familiarWorld:
        return _handleFamiliarWorld(request);

      case HelpScreenId.familyConnect:
        return _handleFamilyConnect(request);

      case HelpScreenId.reminiscence:
        return _handleReminiscence(request);

      case HelpScreenId.musicMemory:
        return _handleMusicMemory(request);

      case HelpScreenId.talkToMe:
        return _handleTalkToMe(request);

      case HelpScreenId.myDay:
        return _handleMyDay(request);

      case HelpScreenId.moodCheckIn:
        return _handleMoodCheckIn(request);

      case HelpScreenId.unknown:
        return _handleUnknown(request);
    }
  }

  // ---------------------------------------------------------------------------
  // HOME SCREEN
  // ---------------------------------------------------------------------------
  HelpResponse _handleHomeScreen(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
      case HelpActionType.nextStep:
        return const HelpResponse(
          title: 'Welcome to BANDHU',
          message:
              'BANDHU is your gentle cognitive care companion. To start, you can explore today\'s activities or tap the Games icon below.',
          suggestedSteps: [
            'Tap the "Games" tab at the bottom to choose an exercise',
            'Tap "Check Reminders" to view your daily schedule',
            'Tap the microphone icon at top to talk with BANDHU',
          ],
        );
      case HelpActionType.stuck:
        return const HelpResponse(
          title: 'Finding Your Way',
          message:
              'You are on the Home screen. From here, you can access games, daily reminders, memories, and your progress anytime.',
          suggestedSteps: [
            'Look at the bottom navigation bar to switch sections',
            'Tap the top settings gear if you want to change language',
          ],
        );
      case HelpActionType.hint:
      default:
        return const HelpResponse(
          title: 'Home Navigation',
          message:
              'Tap the Games tab at the bottom to exercise your memory, or tap Reminders to see what is scheduled for today.',
          suggestedSteps: [
            'Games: Card matching, patterns, and daily routine steps',
            'Reminders: Daily medicines and healthy habits',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // GAMES CATALOG SCREEN
  // ---------------------------------------------------------------------------
  HelpResponse _handleGamesScreen(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
      case HelpActionType.nextStep:
        return const HelpResponse(
          title: 'Choosing a Brain Exercise',
          message:
              'Tap on any game card that you like. You can play Memory Match for picture pairing, Pattern Recognition for visual rhythms, or Routine Recall for daily steps.',
          suggestedSteps: [
            'Memory Match: Find matching pairs of cards',
            'Pattern Recognition: Spot the next repeating picture',
            'Routine Recall: Put daily activities in order',
          ],
        );
      case HelpActionType.stuck:
      case HelpActionType.hint:
      default:
        return const HelpResponse(
          title: 'Gentle Cognitive Games',
          message:
              'All games are designed for comfort and stress-free play. There is no time penalty, and hints are always ready to help you.',
          suggestedSteps: [
            'Select any game card to preview it',
            'Press "Begin Exercise" when you feel comfortable',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // MEMORY MATCH GAME
  // ---------------------------------------------------------------------------
  HelpResponse _handleMemoryMatch(HelpContext context, HelpRequest request) {
    final mmHint = context.gameContext?.memoryMatchHint;

    switch (request.action) {
      case HelpActionType.howDoIPlay:
        return const HelpResponse(
          title: 'How to Play Memory Match',
          message:
              'Tap a card to turn it over and see its picture. Then tap a second card to find its matching twin. When both match, they stay open!',
          suggestedSteps: [
            'Tap any card to reveal its picture',
            'Look for where you saw the same picture earlier',
            'Take your time—every try strengthens your recall',
          ],
        );
      case HelpActionType.hint:
      case HelpActionType.stuck:
        if (mmHint != null) {
          final hintMsg = mmHint.toGentleHintText();
          final String step1 = mmHint.hasFaceUpCard && mmHint.targetMatchingRow != null
              ? 'Try Row ${mmHint.targetMatchingRow}, Column ${mmHint.targetMatchingCol}'
              : 'Try Row ${mmHint.card1Row}, Column ${mmHint.card1Col}';

          return HelpResponse(
            title: 'Memory Match Hint',
            message: hintMsg,
            suggestedSteps: [
              step1,
              'Tap the top-right lightbulb for an in-game highlight',
              'Take your time—there is no rush',
            ],
          );
        }
        // GENERIC GUIDANCE ONLY - NEVER INVENT SPECIFIC CARD POSITIONS
        return const HelpResponse(
          title: 'Gentle Hint',
          message:
              'Try remembering where you saw the matching card. You can also tap the lightbulb icon at the top right to temporarily peek at unmatched cards.',
          suggestedSteps: [
            'Focus on one pair at a time',
            'Tap the top-right lightbulb for an in-game hint',
          ],
        );
      case HelpActionType.nextStep:
      default:
        if (mmHint != null && mmHint.hasFaceUpCard) {
          final target = mmHint.targetMatchingRow != null
              ? 'Look around Row ${mmHint.targetMatchingRow}, Column ${mmHint.targetMatchingCol}.'
              : 'Look for its matching twin on the board.';
          return HelpResponse(
            title: 'Next Step in Memory Match',
            message:
                'You have one card opened (${mmHint.faceUpLabel ?? "revealed"}). $target',
            suggestedSteps: [
              'Tap another card to complete the pair',
              'If it does not match, both will gently turn back over',
            ],
          );
        }
        return const HelpResponse(
          title: 'Next Step in Memory Match',
          message:
              'Pick any unopened card to reveal a picture. If the second card does not match, both will turn back over smoothly so you can try again.',
          suggestedSteps: [
            'Tap an unopened card to reveal it',
            'Use the top-right hint button if you\'d like assistance',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // PATTERN RECOGNITION GAME
  // ---------------------------------------------------------------------------
  HelpResponse _handlePatternRecognition(HelpContext context, HelpRequest request) {
    final pHint = context.gameContext?.patternHint;

    switch (request.action) {
      case HelpActionType.howDoIPlay:
        return const HelpResponse(
          title: 'How Pattern Recognition Works',
          message:
              'Look at the row of pictures from left to right. Notice how the pictures repeat in a gentle rhythm, then tap the picture below that completes the sequence.',
          suggestedSteps: [
            'Look at the first few pictures in order',
            'Notice the repeating pattern or sequence',
            'Tap the choice below that fits the question mark',
          ],
        );
      case HelpActionType.hint:
      case HelpActionType.stuck:
        if (pHint != null) {
          return HelpResponse(
            title: 'Pattern Guidance',
            message: pHint.toGentleHintText(),
            suggestedSteps: [
              'Pattern rule: ${pHint.patternRuleDescription}',
              'Say the sequence out loud to hear the rhythm',
              'Tap the choice below that fits the rhythm',
            ],
          );
        }
        return const HelpResponse(
          title: 'Pattern Hint Guidance',
          message:
              'Say the pictures out loud in order to hear the natural rhythm. You can also tap the Hint button to eliminate one incorrect option.',
          suggestedSteps: [
            'Notice which two or three pictures take turns',
            'Tap the Hint button on screen to remove an extra choice',
          ],
        );
      case HelpActionType.nextStep:
      default:
        if (pHint != null) {
          return HelpResponse(
            title: 'Completing the Sequence',
            message:
                'Look at the sequence before the question mark. Follow the ${pHint.patternRuleDescription} rhythm to find the missing item.',
            suggestedSteps: [
              'Review the pattern rhythm',
              'Tap the matching choice below',
            ],
          );
        }
        return const HelpResponse(
          title: 'Solving the Sequence',
          message:
              'Look closely at the pattern before the question mark. Choose the picture below that follows the same rhythm.',
          suggestedSteps: [
            'Look at the repeating choices',
            'Tap your best answer—there is no penalty for taking your time',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // DAILY ROUTINE RECALL
  // ---------------------------------------------------------------------------
  HelpResponse _handleRoutineRecall(HelpContext context, HelpRequest request) {
    final rHint = context.gameContext?.routineHint;

    switch (request.action) {
      case HelpActionType.howDoIPlay:
        return const HelpResponse(
          title: 'How Routine Recall Works',
          message:
              'Tap the daily activities at the bottom in the chronological order you usually do them throughout the day, like Morning Tea before Lunch.',
          suggestedSteps: [
            'Tap an activity below to add it to your day\'s order',
            'Tap any card in your sequence if you wish to remove it',
            'Press "Check Sequence" when you are satisfied',
          ],
        );
      case HelpActionType.hint:
      case HelpActionType.stuck:
        if (rHint != null) {
          return HelpResponse(
            title: 'Routine Sequence Hint',
            message: rHint.toGentleHintText(),
            suggestedSteps: [
              'Currently placed: ${rHint.currentPlacedSteps} of ${rHint.totalSteps} steps',
              'Think of your typical daily habit for ${rHint.routineTitle}',
            ],
          );
        }
        return const HelpResponse(
          title: 'Routine Hint',
          message:
              'Think of your typical morning, afternoon, and evening. Start with what you do first after waking up.',
          suggestedSteps: [
            'What happens right after you get out of bed?',
            'Tap the in-game hint for guided placement',
          ],
        );
      case HelpActionType.nextStep:
      default:
        if (rHint != null) {
          final nextMsg = rHint.currentPlacedSteps == 0
              ? 'Choose the first step of your ${rHint.routineTitle} from the cards below.'
              : 'Choose what you do after "${rHint.lastPlacedStepLabel ?? "the previous step"}".';
          return HelpResponse(
            title: 'Next Step in Routine',
            message: nextMsg,
            suggestedSteps: [
              'Tap an activity card below',
              'Tap "Check Sequence" when all slots are filled',
            ],
          );
        }
        return const HelpResponse(
          title: 'Arranging Your Routine',
          message:
              'Select the next activity in your day from the available list below. If you change your mind, tap any card in your order to remove it.',
          suggestedSteps: [
            'Pick the next step of your daily routine',
            'Tap "Check Sequence" when complete',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // REMINDERS SCREEN
  // ---------------------------------------------------------------------------
  HelpResponse _handleReminders(HelpRequest request) {
    return const HelpResponse(
      title: 'Daily Reminders',
      message:
          'This screen displays your scheduled medicines, walks, meals, and hydration alerts. Reminders help keep your daily routine steady and calm.',
      suggestedSteps: [
        'Tap the checkmark next to a reminder when you have completed it',
        'Your caregiver can also coordinate reminders with you',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PROGRESS SCREEN
  // ---------------------------------------------------------------------------
  HelpResponse _handleProgress(HelpRequest request) {
    return const HelpResponse(
      title: 'Your Progress & Trends',
      message:
          'Here you can view your cognitive exercise history, consistency streaks, and gentle trends over time. All records are stored safely right on your device.',
      suggestedSteps: [
        'Look at your weekly activity streak',
        'Review your favorite exercises and memory milestones',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PROFILE SCREEN
  // ---------------------------------------------------------------------------
  HelpResponse _handleProfile(HelpRequest request) {
    return const HelpResponse(
      title: 'Your Profile',
      message:
          'Your profile shows your account details, preferred alias, and caregiver connection status.',
      suggestedSteps: [
        'Review your personal details and account role',
        'Tap "Caregiver Connection" to manage your caregiver link',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CAREGIVER PAIRING
  // ---------------------------------------------------------------------------
  HelpResponse _handleCaregiverPairing(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
      case HelpActionType.nextStep:
        return const HelpResponse(
          title: 'Caregiver Pairing',
          message:
              'Pairing connects your BANDHU app to your family or caregiver so they can support you with reminders and celebrate your progress.',
          suggestedSteps: [
            'Enter the 4-digit code from your caregiver\'s dashboard',
            'Or tap "Scan QR" to point your camera at their QR code',
            'Once verified, your connection will be established securely',
          ],
        );
      case HelpActionType.stuck:
        return const HelpResponse(
          title: 'Troubleshooting Pairing',
          message:
              'If pairing doesn\'t succeed, make sure both devices are on the same Wi-Fi network and verify that the 4-digit code hasn\'t expired.',
          suggestedSteps: [
            'Ask your caregiver to generate a fresh 4-digit code',
            'Check that your Wi-Fi or local connection is active',
            'Tap Continue Offline if you want to play without pairing',
          ],
        );
      case HelpActionType.hint:
      default:
        return const HelpResponse(
          title: 'Pairing Methods',
          message:
              'You can pair using either the simple 4-digit numeric code or by scanning the caregiver QR code.',
          suggestedSteps: [
            '4-digit code: Type the 4 digits provided by caregiver',
            'QR code: Tap Scan QR and align the square with the code',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // SETTINGS SCREEN
  // ---------------------------------------------------------------------------
  HelpResponse _handleSettings(HelpRequest request) {
    return const HelpResponse(
      title: 'App Settings',
      message:
          'In Settings, you can switch languages across 9 regional languages, switch between Dark and Light mode, or review offline storage info.',
      suggestedSteps: [
        'Tap "Language" to choose English, Hindi, Assamese, etc.',
        'Toggle Dark Mode for high-contrast viewing at night',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // PERSONAL MEMORY BANK
  // ---------------------------------------------------------------------------
  HelpResponse _handlePersonalMemory(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
      case HelpActionType.nextStep:
        return const HelpResponse(
          title: 'Personal Memory Bank',
          message:
              'Browse your cherished memories by category, such as family photos, childhood places, and favourite foods. Tap any memory to view details.',
          suggestedSteps: [
            'Tap category pills at the top to filter memories',
            'Tap "+" to add a new memory with photo and story',
            'Tap any memory card to see its full story and details',
          ],
        );
      case HelpActionType.stuck:
        return const HelpResponse(
          title: 'Exploring Memories',
          message:
              'You are in your Personal Memory Bank. If you do not see a memory, try selecting "All" in the category filter above.',
          suggestedSteps: [
            'Tap "All" to view all your saved memories',
            'Tap the heart icon to view your favorites',
          ],
        );
      case HelpActionType.hint:
      default:
        return const HelpResponse(
          title: 'Memory Bank Tips',
          message:
              'You can mark your most cherished memories as favorites by tapping the heart icon on any memory card.',
          suggestedSteps: [
            'Tap the heart icon on any card to favorite it',
            'Tap My Life Story to view memories in a chronological timeline',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // MY LIFE STORY
  // ---------------------------------------------------------------------------
  HelpResponse _handleLifeStory(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
      case HelpActionType.nextStep:
        return const HelpResponse(
          title: 'My Life Story Timeline',
          message:
              'My Life Story organizes your personal memories chronologically by milestone years, from early childhood to family celebrations.',
          suggestedSteps: [
            'Scroll up and down to travel through your timeline milestones',
            'Tap any milestone to view its photo and story',
            'Tap "+" at the top right to add a new life milestone',
          ],
        );
      case HelpActionType.stuck:
      case HelpActionType.hint:
      default:
        return const HelpResponse(
          title: 'Life Story Navigation',
          message:
              'Each milestone shows the year and a memorable event. You can add new milestones anytime.',
          suggestedSteps: [
            'Tap "+" to add an important life milestone',
            'Tap "Load Sample Milestones" to see an example timeline',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // FAMILIAR WORLD (NER CULTURAL MEMORY)
  // ---------------------------------------------------------------------------
  HelpResponse _handleFamiliarWorld(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
        return const HelpResponse(
          title: 'Familiar World Activity',
          message:
              'Look at the cultural picture shown on screen and choose the answer that describes it. There is no rush or time limit.',
          suggestedSteps: [
            'Look at the familiar cultural picture or object',
            'Read the question "What is this?"',
            'Tap the button that matches the picture',
          ],
        );
      case HelpActionType.stuck:
        return const HelpResponse(
          title: 'Cultural Recognition',
          message:
              'Take your time looking at the colors, shapes, and patterns in the picture. Think about familiar festivals, foods, or household items.',
          suggestedSteps: [
            'Tap any option that feels familiar to you',
            'Gentle feedback will let you know right away',
          ],
        );
      case HelpActionType.hint:
        return const HelpResponse(
          title: 'Cultural Hint',
          message:
              'Consider the region and traditions associated with the picture, like Bihu, traditional attire, or festive dishes.',
          suggestedSteps: [
            'Look at whether the item is a food, clothing, or festival item',
          ],
        );
      case HelpActionType.nextStep:
      default:
        return const HelpResponse(
          title: 'Next Question',
          message:
              'After choosing an answer, tap "Next Activity" to explore another familiar cultural memory.',
          suggestedSteps: [
            'Select an answer to see the result',
            'Tap "Next Activity" to continue',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // FAMILY CONNECT
  // ---------------------------------------------------------------------------
  HelpResponse _handleFamilyConnect(HelpRequest request) {
    return const HelpResponse(
      title: 'Family Connect',
      message:
          'Family Connect allows loved ones and caregivers to contribute family photos, names, and meaningful moments to the patient\'s Memory Bank.',
      suggestedSteps: [
        'Enter the person\'s name, relationship, and milestone',
        'Add a photo and description of the cherished memory',
        'Tap "Save to Memory Bank" to make it visible to the patient',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // REMINISCENCE MODE
  // ---------------------------------------------------------------------------
  HelpResponse _handleReminiscence(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
      case HelpActionType.nextStep:
        return const HelpResponse(
          title: 'Reminiscence Mode',
          message:
              'Reminiscence Mode presents a cherished photograph with gentle conversation prompts to awaken fond memories and peaceful reflections.',
          suggestedSteps: [
            'Look closely at the photo and notice familiar faces or places',
            'Tap the microphone to speak your thoughts aloud',
            'Or type your reflection in the text box below',
            'Tap "Save Reflection" to record your memory',
          ],
        );
      case HelpActionType.stuck:
      case HelpActionType.hint:
      default:
        return const HelpResponse(
          title: 'Reflection Prompts',
          message:
              'Think about who was with you that day, what season it was, what sounds or scents you remember, and how it made you feel.',
          suggestedSteps: [
            'There are no right or wrong answers',
            'Share whatever brings you comfort and warmth',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // MEMORY THROUGH MUSIC
  // ---------------------------------------------------------------------------
  HelpResponse _handleMusicMemory(HelpRequest request) {
    return const HelpResponse(
      title: 'Memory Through Music',
      message:
          'Music can awaken powerful, joyful memories. Choose from favourite songs, family melodies, or regional festival tunes.',
      suggestedSteps: [
        'Tap Play on any song card to begin listening',
        'Use the bottom player to Pause, Resume, or Stop',
        'Explore different categories like Festival Music or Family Songs',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TALK TO ME
  // ---------------------------------------------------------------------------
  HelpResponse _handleTalkToMe(HelpRequest request) {
    return const HelpResponse(
      title: 'Talk to Me Companion',
      message:
          'Talk to Me is your friendly conversational companion. You can chat about your day, ask for a gentle folk tale, or simply say hello.',
      suggestedSteps: [
        'Tap any quick topic chip like "Tell me a folk story"',
        'Or type a message in the text box and tap Send',
        'Tap the microphone to speak naturally',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MY DAY (DAILY ROUTINE COMPANION)
  // ---------------------------------------------------------------------------
  HelpResponse _handleMyDay(HelpRequest request) {
    switch (request.action) {
      case HelpActionType.howDoIPlay:
      case HelpActionType.nextStep:
        return const HelpResponse(
          title: 'My Day Routine',
          message:
              'My Day organizes your daily activities from morning to evening. Check off activities as you complete them throughout the day.',
          suggestedSteps: [
            'Record your daily feeling in the check-in card at the top',
            'Tap the checkmark next to an activity when finished',
            'Upcoming activities show your next recommended time',
          ],
        );
      case HelpActionType.stuck:
      case HelpActionType.hint:
      default:
        return const HelpResponse(
          title: 'Today\'s Schedule',
          message:
              'Follow your schedule comfortably at your own pace. If you miss an activity, do not worry — you can complete it whenever you are ready.',
          suggestedSteps: [
            'Tap any item to see its reminder details',
            'Tap the checkmark to mark it done',
          ],
        );
    }
  }

  // ---------------------------------------------------------------------------
  // MOOD CHECK-IN
  // ---------------------------------------------------------------------------
  HelpResponse _handleMoodCheckIn(HelpRequest request) {
    return const HelpResponse(
      title: 'Daily Check-In',
      message:
          'This is a simple self-reported check-in to express how you feel today. It is kept privately on your device.',
      suggestedSteps: [
        'Tap one of the four feelings: Good, Okay, Not great, or Sad',
        'Your response is recorded instantly with zero stress',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // UNKNOWN / SAFE FALLBACK
  // ---------------------------------------------------------------------------
  HelpResponse _handleUnknown(HelpRequest request) {
    return const HelpResponse(
      title: 'BANDHU Help',
      message:
          'I can help you with this screen. Try telling me what you need help with, or tap one of the common questions.',
      suggestedSteps: [
        'Tap "How do I play?" to learn about the current activity',
        'Tap "I\'m stuck" for a gentle guiding step',
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CUSTOM QUESTION KEYWORD ROUTING
  // ---------------------------------------------------------------------------
  HelpResponse _handleCustomQuery(HelpContext context, String query) {
    if (query.contains('pair') || query.contains('code') || query.contains('qr') || query.contains('caregiver')) {
      return _handleCaregiverPairing(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('family connect') || query.contains('contribute')) {
      return _handleFamilyConnect(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('mood') || query.contains('feeling') || query.contains('check-in') || query.contains('checkin')) {
      return _handleMoodCheckIn(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('my day') || query.contains('day') || query.contains('schedule')) {
      return _handleMyDay(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('life story') || query.contains('story') || query.contains('timeline') || query.contains('milestone')) {
      return _handleLifeStory(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('reminisc') || query.contains('reflect') || query.contains('photo talk')) {
      return _handleReminiscence(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('music') || query.contains('song') || query.contains('audio') || query.contains('melody')) {
      return _handleMusicMemory(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('talk') || query.contains('chat') || query.contains('companion') || query.contains('conversation')) {
      return _handleTalkToMe(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('familiar') || query.contains('cultural') || query.contains('ner') || query.contains('bihu')) {
      return _handleFamiliarWorld(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('memory') || query.contains('photo') || query.contains('bank')) {
      return _handlePersonalMemory(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('match') || query.contains('card')) {
      return _handleMemoryMatch(context, HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('pattern') || query.contains('sequence') || query.contains('rhythm')) {
      return _handlePatternRecognition(context, HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('routine') || query.contains('order')) {
      return _handleRoutineRecall(context, HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('reminder') || query.contains('medicine') || query.contains('alert')) {
      return _handleReminders(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('progress') || query.contains('streak') || query.contains('history')) {
      return _handleProgress(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('setting') || query.contains('theme') || query.contains('dark') || query.contains('light') || query.contains('language')) {
      return _handleSettings(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('profile') || query.contains('alias')) {
      return _handleProfile(HelpRequest.action(HelpActionType.howDoIPlay));
    }
    if (query.contains('stuck') || query.contains('lost') || query.contains('confus')) {
      return _generateResponse(context, HelpRequest.action(HelpActionType.stuck));
    }
    if (query.contains('hint') || query.contains('clue') || query.contains('tip')) {
      return _generateResponse(context, HelpRequest.action(HelpActionType.hint));
    }
    if (query.contains('next') || query.contains('step')) {
      return _generateResponse(context, HelpRequest.action(HelpActionType.nextStep));
    }
    if (query.contains('how') || query.contains('play') || query.contains('start') || query.contains('begin') || query.contains('game')) {
      return _generateResponse(context, HelpRequest.action(HelpActionType.howDoIPlay));
    }

    // Default to the contextual screen overview
    return _generateResponse(context, HelpRequest.action(HelpActionType.howDoIPlay));
  }
}
