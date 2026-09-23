import '../../games/models/game_model.dart';
import '../../games/models/game_context.dart';
import 'help_screen_id.dart';

/// Reusable context model representing the user's active screen, feature, and state.
/// Designed to be lightweight, extensible, and safely fallback to UNKNOWN.
class HelpContext {
  final HelpScreenId screenId;
  final String route;
  final String feature;
  final String? subFeature;
  final String language;
  final bool isGame;
  final CognitiveGameType? gameType;
  final Map<String, dynamic>? basicGameState;

  // Extensible fields for game-aware help
  final GameContext? gameContext;
  final int? difficulty;
  final int? hintsUsed;
  final int? elapsedSeconds;
  final int? mistakes;

  const HelpContext({
    required this.screenId,
    required this.route,
    required this.feature,
    this.subFeature,
    this.language = 'en',
    this.isGame = false,
    this.gameType,
    this.basicGameState,
    this.gameContext,
    this.difficulty,
    this.hintsUsed,
    this.elapsedSeconds,
    this.mistakes,
  });

  /// Safe fallback context when the active screen cannot be determined.
  factory HelpContext.unknown({
    String route = 'unknown',
    String language = 'en',
  }) {
    return HelpContext(
      screenId: HelpScreenId.unknown,
      route: route,
      feature: 'UNKNOWN',
      language: language,
      isGame: false,
    );
  }

  /// Create a context for a specific [HelpScreenId] with appropriate defaults.
  factory HelpContext.fromScreenId(
    HelpScreenId screenId, {
    String? route,
    String? subFeature,
    String language = 'en',
    CognitiveGameType? gameType,
    Map<String, dynamic>? basicGameState,
    GameContext? gameContext,
    int? difficulty,
    int? hintsUsed,
    int? elapsedSeconds,
    int? mistakes,
  }) {
    final bool isGame = screenId.isGame;
    CognitiveGameType? resolvedGameType = gameType ?? gameContext?.gameType;
    if (isGame && resolvedGameType == null) {
      if (screenId == HelpScreenId.memoryMatch) {
        resolvedGameType = CognitiveGameType.memoryMatch;
      } else if (screenId == HelpScreenId.patternRecognition) {
        resolvedGameType = CognitiveGameType.patternRecognition;
      } else if (screenId == HelpScreenId.routine) {
        resolvedGameType = CognitiveGameType.dailyRoutineRecall;
      }
    }

    return HelpContext(
      screenId: screenId,
      route: route ?? screenId.code.toLowerCase(),
      feature: screenId.code,
      subFeature: subFeature,
      language: language,
      isGame: isGame,
      gameType: resolvedGameType,
      basicGameState: basicGameState,
      gameContext: gameContext,
      difficulty: difficulty ?? gameContext?.difficulty,
      hintsUsed: hintsUsed ?? gameContext?.hintsUsed,
      elapsedSeconds: elapsedSeconds ?? gameContext?.elapsedTime.inSeconds,
      mistakes: mistakes ?? gameContext?.mistakes,
    );
  }

  HelpContext copyWith({
    HelpScreenId? screenId,
    String? route,
    String? feature,
    String? subFeature,
    String? language,
    bool? isGame,
    CognitiveGameType? gameType,
    Map<String, dynamic>? basicGameState,
    GameContext? gameContext,
    int? difficulty,
    int? hintsUsed,
    int? elapsedSeconds,
    int? mistakes,
  }) {
    return HelpContext(
      screenId: screenId ?? this.screenId,
      route: route ?? this.route,
      feature: feature ?? this.feature,
      subFeature: subFeature ?? this.subFeature,
      language: language ?? this.language,
      isGame: isGame ?? this.isGame,
      gameType: gameType ?? this.gameType,
      basicGameState: basicGameState ?? this.basicGameState,
      gameContext: gameContext ?? this.gameContext,
      difficulty: difficulty ?? this.difficulty,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      mistakes: mistakes ?? this.mistakes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'screenId': screenId.code,
      'route': route,
      'feature': feature,
      'subFeature': subFeature,
      'language': language,
      'isGame': isGame,
      'gameType': gameType?.code,
      'basicGameState': basicGameState,
      'gameContext': gameContext?.toMap(),
      'difficulty': difficulty,
      'hintsUsed': hintsUsed,
      'elapsedSeconds': elapsedSeconds,
      'mistakes': mistakes,
    };
  }

  @override
  String toString() =>
      'HelpContext(screen: ${screenId.code}, route: $route, isGame: $isGame, lang: $language)';
}
