import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../l10n/app_strings.dart';
import '../models/pattern_item.dart';

enum OptionButtonState {
  normal,
  eliminatedByHint,
  selectedCorrect,
  selectedIncorrect,
}

/// Large, accessible answer button for Pattern Recognition.
/// Elderly-first design with high contrast, large touch targets (>=64dp),
/// and multi-sensory feedback (icon, color, and descriptive text).
class PatternOptionButton extends StatelessWidget {
  final PatternItem item;
  final OptionButtonState state;
  final VoidCallback? onTap;
  final String locale;

  const PatternOptionButton({
    super.key,
    required this.item,
    this.state = OptionButtonState.normal,
    this.onTap,
    this.locale = 'en',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isEliminated = state == OptionButtonState.eliminatedByHint;
    final bool isCorrect = state == OptionButtonState.selectedCorrect;
    final bool isIncorrect = state == OptionButtonState.selectedIncorrect;
    final String localizedLabel = item.getLocalizedLabel(locale);
    final String eliminatedText = AppStrings.get('eliminated', locale: locale);

    Color backgroundColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    Color borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    Color contentColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    if (isEliminated) {
      backgroundColor = isDark ? AppColors.darkSoftBlue.withValues(alpha: 0.3) : const Color(0xFFF1F5F9);
      borderColor = isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1);
      contentColor = isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : const Color(0xFF94A3B8);
    } else if (isCorrect) {
      backgroundColor = isDark ? const Color(0xFF1E2E2A) : const Color(0xFFF2F6F3);
      borderColor = isDark ? AppColors.darkPrimary : SmritiTheme.successGreen;
      contentColor = isDark ? AppColors.darkPrimary : SmritiTheme.successGreen;
    } else if (isIncorrect) {
      backgroundColor = isDark ? const Color(0xFF2A281E) : const Color(0xFFFEF3C7);
      borderColor = isDark ? AppColors.darkSoftGold : const Color(0xFFD97706);
      contentColor = isDark ? AppColors.darkSoftGold : const Color(0xFFB45309);
    }

    return Semantics(
      label: isEliminated
          ? '$localizedLabel, $eliminatedText'
          : 'Answer choice: $localizedLabel',
      button: !isEliminated,
      enabled: !isEliminated && onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEliminated ? null : onTap,
          borderRadius: BorderRadius.circular(18.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
            constraints: const BoxConstraints(minHeight: 64.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(18.0),
              border: Border.all(
                color: borderColor,
                width: (isCorrect || isIncorrect) ? 3.0 : 2.0,
              ),
              boxShadow: isEliminated
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8.0,
                        offset: const Offset(0, 3),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Item Icon Circle
                Container(
                  width: 52.0,
                  height: 52.0,
                  decoration: BoxDecoration(
                    color: isEliminated
                        ? const Color(0xFFE2E8F0)
                        : item.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    item.icon,
                    size: 32.0,
                    color: isEliminated ? const Color(0xFF94A3B8) : item.color,
                  ),
                ),
                const SizedBox(width: 18.0),

                // Item Label
                Expanded(
                  child: Text(
                    localizedLabel,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: contentColor,
                      decoration: isEliminated
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),

                // Status Indicator Icon & Text (Multi-sensory: not color alone)
                if (isCorrect) ...[
                  const Icon(
                    Icons.check_circle_rounded,
                    color: SmritiTheme.restorativeSage,
                    size: 32.0,
                  ),
                ] else if (isIncorrect) ...[
                  const Icon(
                    Icons.replay_rounded,
                    color: Color(0xFFD97706),
                    size: 32.0,
                  ),
                ] else if (isEliminated) ...[
                  Text(
                    eliminatedText,
                    style: const TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.touch_app_outlined,
                    color: SmritiTheme.mutedText.withValues(alpha: 0.5),
                    size: 24.0,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
