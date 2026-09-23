import 'package:flutter/foundation.dart';
import '../../games/models/game_context.dart';
import '../models/help_context.dart';
import '../models/help_screen_id.dart';
import 'help_engine.dart';
import 'local_help_engine.dart';

/// Centralized service tracking the patient application's active screen context.
/// Provides reliable context resolution with guaranteed fallback to [HelpScreenId.unknown].
class HelpContextService extends ChangeNotifier {
  static final HelpContextService _instance = HelpContextService._internal();

  /// Shared singleton instance for convenient cross-component access.
  static HelpContextService get instance => _instance;

  HelpEngine _engine;
  HelpContext _currentContext;

  HelpContextService._internal({HelpEngine? engine})
      : _engine = engine ?? const LocalHelpEngine(),
        _currentContext = HelpContext.fromScreenId(HelpScreenId.home);

  factory HelpContextService({HelpEngine? engine}) {
    if (engine != null) {
      _instance._engine = engine;
    }
    return _instance;
  }

  /// Current active help engine (Phase 1 uses [LocalHelpEngine]).
  HelpEngine get engine => _engine;

  /// Current active help context.
  HelpContext get currentContext => _currentContext;

  /// Update the current context directly.
  void updateContext(HelpContext context) {
    if (_currentContext.screenId == context.screenId &&
        _currentContext.subFeature == context.subFeature &&
        _currentContext.route == context.route &&
        _currentContext.language == context.language &&
        _currentContext.isGame == context.isGame &&
        _currentContext.gameContext == context.gameContext) {
      return;
    }
    _currentContext = context;
    notifyListeners();
  }

  /// Update context using a [HelpScreenId].
  void updateFromScreenId(
    HelpScreenId screenId, {
    String? route,
    String? subFeature,
    String language = 'en',
    Map<String, dynamic>? basicGameState,
    GameContext? gameContext,
  }) {
    final next = HelpContext.fromScreenId(
      screenId,
      route: route,
      subFeature: subFeature,
      language: language,
      basicGameState: basicGameState,
      gameContext: gameContext,
    );
    updateContext(next);
  }

  /// Convenience method to update the active game context while preserving current screen ID.
  void updateGameContext(GameContext gameContext) {
    final next = _currentContext.copyWith(
      gameContext: gameContext,
      difficulty: gameContext.difficulty,
      hintsUsed: gameContext.hintsUsed,
      elapsedSeconds: gameContext.elapsedTime.inSeconds,
      mistakes: gameContext.mistakes,
    );
    updateContext(next);
  }

  /// Update context based on the bottom navigation tab index in SmritiAppShell.
  void updateFromShellTab(int tabIndex, {String language = 'en'}) {
    HelpScreenId screenId;
    switch (tabIndex) {
      case 0:
        screenId = HelpScreenId.home;
        break;
      case 1:
        screenId = HelpScreenId.games;
        break;
      case 2:
        screenId = HelpScreenId.personalMemory;
        break;
      case 3:
        screenId = HelpScreenId.reminders;
        break;
      case 4:
        screenId = HelpScreenId.progress;
        break;
      case 5:
        screenId = HelpScreenId.myDay;
        break;
      default:
        screenId = HelpScreenId.unknown;
        break;
    }
    updateFromScreenId(screenId, route: 'shell_tab_$tabIndex', language: language);
  }

  /// Map route name to context with safe fallback to UNKNOWN.
  void updateFromRouteName(String? routeName, {String language = 'en'}) {
    if (routeName == null || routeName.isEmpty) {
      updateFromScreenId(HelpScreenId.unknown, language: language);
      return;
    }
    final screenId = HelpScreenId.fromString(routeName);
    updateFromScreenId(screenId, route: routeName, language: language);
  }
}
