/// Predefined question/action types available in the BANDHU Help panel.
enum HelpActionType {
  howDoIPlay,
  stuck,
  hint,
  nextStep,
  customQuestion,
  general;

  String get localizationKey {
    switch (this) {
      case HelpActionType.howDoIPlay:
        return 'helpHowDoIPlay';
      case HelpActionType.stuck:
        return 'helpImStuck';
      case HelpActionType.hint:
        return 'helpGiveHint';
      case HelpActionType.nextStep:
        return 'helpNextStep';
      case HelpActionType.customQuestion:
      case HelpActionType.general:
        return 'helpGeneralQuestion';
    }
  }
}

/// User's help request carrying the selected action or typed question.
class HelpRequest {
  final HelpActionType action;
  final String? query;
  final DateTime timestamp;

  HelpRequest({
    required this.action,
    this.query,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory HelpRequest.action(HelpActionType action) =>
      HelpRequest(action: action);

  factory HelpRequest.query(String query) => HelpRequest(
        action: HelpActionType.customQuestion,
        query: query.trim(),
      );
}
