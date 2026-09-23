import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/smriti_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/locale_notifier.dart';
import '../models/help_context.dart';
import '../models/help_request.dart';
import '../models/help_response.dart';
import '../models/help_screen_id.dart';
import '../services/help_context_service.dart';

/// Modal contextual help panel for BANDHU.
/// Displays active screen context and provides instant deterministic offline guidance.
class BandhuHelpSheet extends StatefulWidget {
  final HelpContext initialContext;

  const BandhuHelpSheet({
    super.key,
    required this.initialContext,
  });

  /// Displays the contextual help sheet modally.
  static Future<void> show(
    BuildContext context, {
    HelpScreenId? screenId,
    HelpContext? contextOverride,
  }) {
    String currentLocale = 'en';
    try {
      final locNotifier = Provider.of<LocaleNotifier?>(context, listen: false);
      if (locNotifier != null) currentLocale = locNotifier.currentLocale;
    } catch (_) {}

    HelpContext resolvedContext;
    if (contextOverride != null) {
      resolvedContext = contextOverride;
    } else if (screenId != null) {
      resolvedContext = HelpContext.fromScreenId(screenId, language: currentLocale);
    } else {
      final serviceContext = HelpContextService.instance.currentContext;
      resolvedContext = serviceContext.copyWith(language: currentLocale);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) => BandhuHelpSheet(initialContext: resolvedContext),
    );
  }

  @override
  State<BandhuHelpSheet> createState() => _BandhuHelpSheetState();
}

class _BandhuHelpSheetState extends State<BandhuHelpSheet> {
  late HelpContext _context;
  final TextEditingController _questionController = TextEditingController();
  HelpResponse? _activeResponse;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _context = widget.initialContext;
    // Pre-populate with default contextual greeting
    _fetchHelp(HelpRequest.action(HelpActionType.howDoIPlay));
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _fetchHelp(HelpRequest request) async {
    setState(() {
      _isLoading = true;
    });

    final engine = HelpContextService.instance.engine;
    final response = await engine.getHelp(_context, request);

    if (mounted) {
      setState(() {
        _activeResponse = response;
        _isLoading = false;
      });
    }
  }

  void _onActionChipTapped(HelpActionType action) {
    _fetchHelp(HelpRequest.action(action));
  }

  void _onSubmitCustomQuery() {
    final text = _questionController.text.trim();
    if (text.isEmpty) return;
    _questionController.clear();
    _fetchHelp(HelpRequest.query(text));
  }

  String _getLocale() {
    try {
      final locNotifier = Provider.of<LocaleNotifier?>(context, listen: false);
      if (locNotifier != null) return locNotifier.currentLocale;
    } catch (_) {}
    return _context.language;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = _getLocale();
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardBg = isDark ? AppColors.darkCardElevated : AppColors.lightBackground;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final isGame = _context.isGame;
    final gameCtx = _context.gameContext;
    final headerTitle = isGame
        ? 'You\'re currently playing:'
        : AppStrings.get('helpCurrentlyIn', locale: locale);
    final screenName = AppStrings.get(_context.screenId.localizationKey, locale: locale);
    final displayName = isGame && gameCtx != null ? gameCtx.gameTitle : screenName;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Drag Handle
                Center(
                  child: Container(
                    width: 44.0,
                    height: 5.0,
                    margin: const EdgeInsets.only(bottom: 14.0),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.white30 : Colors.black26),
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),

                // Header Row
                Row(
                  children: [
                    Container(
                      width: 44.0,
                      height: 44.0,
                      decoration: BoxDecoration(
                        color: SmritiTheme.restorativeSage.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: const Center(
                        child: Text(
                          '🤝',
                          style: TextStyle(fontSize: 24.0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        AppStrings.get('bandhuHelp', locale: locale),
                        style: TextStyle(
                          fontSize: 22.0,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28.0),
                      color: textSecondary,
                      tooltip: AppStrings.get('close', locale: locale),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Current Context Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: borderColor, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isGame ? Icons.psychology_rounded : Icons.place_rounded,
                            color: SmritiTheme.restorativeSage,
                            size: 26.0,
                          ),
                          const SizedBox(width: 12.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  headerTitle,
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    color: textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2.0),
                                Text(
                                  displayName,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                            decoration: BoxDecoration(
                              color: SmritiTheme.restorativeSage.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Text(
                              _context.screenId.code,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isGame && gameCtx != null) ...[
                        const SizedBox(height: 8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                          decoration: BoxDecoration(
                            color: SmritiTheme.restorativeSage.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                size: 16.0,
                                color: SmritiTheme.restorativeSage,
                              ),
                              const SizedBox(width: 8.0),
                              Expanded(
                                child: Text(
                                  'Current activity: ${gameCtx.progressDescription}',
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),

                // Prompt Section Title
                Text(
                  AppStrings.get('helpPrompt', locale: locale),
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 12.0),

                // Quick Action Chips in Requested Order
                Wrap(
                  spacing: 8.0,
                  runSpacing: 10.0,
                  children: [
                    _buildQuickActionChip(
                      label: AppStrings.get('helpHowDoIPlay', locale: locale),
                      icon: Icons.help_outline_rounded,
                      action: HelpActionType.howDoIPlay,
                      isDark: isDark,
                    ),
                    _buildQuickActionChip(
                      label: AppStrings.get('helpGiveHint', locale: locale),
                      icon: Icons.lightbulb_outline_rounded,
                      action: HelpActionType.hint,
                      isDark: isDark,
                    ),
                    _buildQuickActionChip(
                      label: AppStrings.get('helpImStuck', locale: locale),
                      icon: Icons.navigation_rounded,
                      action: HelpActionType.stuck,
                      isDark: isDark,
                    ),
                    _buildQuickActionChip(
                      label: AppStrings.get('helpNextStep', locale: locale),
                      icon: Icons.arrow_forward_rounded,
                      action: HelpActionType.nextStep,
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: 18.0),

                // Custom Query Field
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _questionController,
                        style: TextStyle(fontSize: 16.0, color: textPrimary),
                        decoration: InputDecoration(
                          hintText: AppStrings.get('helpAskHint', locale: locale),
                          hintStyle: TextStyle(fontSize: 15.0, color: textSecondary),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          filled: true,
                          fillColor: cardBg,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: borderColor, width: 1.5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: borderColor, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14.0),
                            borderSide: BorderSide(color: primaryColor, width: 2.0),
                          ),
                        ),
                        onSubmitted: (_) => _onSubmitCustomQuery(),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SmritiTheme.restorativeSage,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        minimumSize: const Size(56.0, 48.0),
                      ),
                      onPressed: _onSubmitCustomQuery,
                      child: Text(
                        AppStrings.get('helpSend', locale: locale),
                        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20.0),

                // Response Card
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_activeResponse != null)
                  _buildResponseCard(
                    response: _activeResponse!,
                    isDark: isDark,
                    locale: locale,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip({
    required String label,
    required IconData icon,
    required HelpActionType action,
    required bool isDark,
  }) {
    return ActionChip(
      avatar: Icon(
        icon,
        size: 18.0,
        color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      backgroundColor: isDark
          ? AppColors.darkSoftBlue.withValues(alpha: 0.6)
          : AppColors.lightWarmAccent.withValues(alpha: 0.18),
      side: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        width: 1.2,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      onPressed: () => _onActionChipTapped(action),
    );
  }

  Widget _buildResponseCard({
    required HelpResponse response,
    required bool isDark,
    required String locale,
  }) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardElevated : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : SmritiTheme.restorativeSage.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Disclaimer Row
          Row(
            children: [
              Expanded(
                child: Text(
                  response.title,
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 3.0),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSoftBlue.withValues(alpha: 0.6)
                      : SmritiTheme.restorativeSage.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  response.disclaimer,
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Message Body
          Text(
            response.message,
            style: TextStyle(
              fontSize: 15.5,
              height: 1.45,
              color: textSecondary,
            ),
          ),

          // Suggested Steps
          if (response.suggestedSteps.isNotEmpty) ...[
            const SizedBox(height: 14.0),
            ...response.suggestedSteps.asMap().entries.map((entry) {
              final stepIndex = entry.key + 1;
              final stepText = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 22.0,
                      height: 22.0,
                      margin: const EdgeInsets.only(top: 2.0, right: 10.0),
                      decoration: BoxDecoration(
                        color: SmritiTheme.restorativeSage,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$stepIndex',
                          style: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        stepText,
                        style: TextStyle(
                          fontSize: 14.5,
                          height: 1.35,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
