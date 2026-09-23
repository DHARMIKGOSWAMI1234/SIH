/// Help response produced by a [HelpEngine].
class HelpResponse {
  final String title;
  final String message;
  final List<String> suggestedSteps;
  final bool isOffline;
  final String disclaimer;

  const HelpResponse({
    required this.title,
    required this.message,
    this.suggestedSteps = const [],
    this.isOffline = true,
    this.disclaimer = 'Offline Local Guidance',
  });

  @override
  String toString() => 'HelpResponse(title: $title, message: $message)';
}
