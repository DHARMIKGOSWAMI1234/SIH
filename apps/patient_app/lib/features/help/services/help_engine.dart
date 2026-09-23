import '../models/help_context.dart';
import '../models/help_request.dart';
import '../models/help_response.dart';

/// Abstract contract for providing contextual help in BANDHU.
/// Designed for extensible architectures (e.g. future AI providers)
/// while strictly using [LocalHelpEngine] in Phase 1.
abstract class HelpEngine {
  Future<HelpResponse> getHelp(HelpContext context, HelpRequest request);
}
