import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/smriti_theme.dart';
import '../../../l10n/app_strings.dart';
import '../../../l10n/locale_notifier.dart';
import '../models/help_screen_id.dart';
import 'bandhu_help_sheet.dart';

/// Patient-app-wide floating help control.
/// Designed for elderly users with a minimum 56x56 touch target, high contrast,
/// clear semantics, and full compatibility with light/dark themes.
class BandhuHelpButton extends StatelessWidget {
  final HelpScreenId? screenId;
  final VoidCallback? onPressed;
  final bool mini;
  final IconData icon;

  const BandhuHelpButton({
    super.key,
    this.screenId,
    this.onPressed,
    this.mini = false,
    this.icon = Icons.live_help_rounded,
  });

  String _getLocale(BuildContext context) {
    try {
      final locNotifier = context.watch<LocaleNotifier?>();
      if (locNotifier != null) return locNotifier.currentLocale;
    } catch (_) {}
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = _getLocale(context);
    final label = AppStrings.get('bandhuHelp', locale: locale);

    final bgColor = isDark ? SmritiTheme.restorativeSage : SmritiTheme.restorativeSage;
    final fgColor = Colors.white;
    final borderColor = isDark ? AppColors.darkTextPrimary.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.4);

    return Semantics(
      button: true,
      label: label,
      hint: AppStrings.get('helpAvailableHere', locale: locale),
      child: Tooltip(
        message: label,
        child: Material(
          color: Colors.transparent,
          elevation: 6.0,
          shadowColor: Colors.black.withValues(alpha: isDark ? 0.5 : 0.25),
          shape: const CircleBorder(),
          child: InkWell(
            key: const Key('bandhu_help_button'),
            onTap: onPressed ?? () => BandhuHelpSheet.show(context, screenId: screenId),
            customBorder: const CircleBorder(),
            child: Container(
              width: 58.0,
              height: 58.0,
              constraints: const BoxConstraints(minWidth: 56.0, minHeight: 56.0),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2.0),
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: fgColor,
                  size: 32.0,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
