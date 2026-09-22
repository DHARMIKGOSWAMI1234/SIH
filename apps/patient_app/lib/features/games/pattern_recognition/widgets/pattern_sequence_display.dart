import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../l10n/app_strings.dart';
import '../models/pattern_item.dart';

/// Accessible sequence display showing the visual rhythm and the target question slot.
class PatternSequenceDisplay extends StatelessWidget {
  final List<PatternItem> sequence;
  final bool isAnswerRevealed;
  final PatternItem? revealedAnswer;
  final String locale;

  const PatternSequenceDisplay({
    super.key,
    required this.sequence,
    this.isAnswerRevealed = false,
    this.revealedAnswer,
    this.locale = 'en',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(20.0),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.pattern_rounded,
                color: SmritiTheme.restorativeSage,
                size: 24.0,
              ),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  AppStrings.get('patternSequence', locale: locale),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: SmritiTheme.mutedText,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < sequence.length; i++) ...[
                  _buildSequenceItemCard(sequence[i], index: i + 1, isDark: isDark),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      size: 24.0,
                    ),
                  ),
                ],
                // Target slot for next item
                _buildTargetSlotCard(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSequenceItemCard(PatternItem item, {required int index, required bool isDark}) {
    final localizedLabel = item.getLocalizedLabel(locale);
    return Semantics(
      label: 'Pattern item $index: $localizedLabel',
      child: Container(
        width: 72.0,
        height: 90.0,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          color: item.color.withValues(alpha: isDark ? 0.2 : 0.12),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: item.color.withValues(alpha: isDark ? 0.7 : 0.6),
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              size: 38.0,
              color: item.color,
            ),
            const SizedBox(height: 4.0),
            Text(
              localizedLabel,
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSlotCard(bool isDark) {
    if (isAnswerRevealed && revealedAnswer != null) {
      final localizedLabel = revealedAnswer!.getLocalizedLabel(locale);
      return Semantics(
        label: 'Completed next item: $localizedLabel',
        child: Container(
          width: 72.0,
          height: 90.0,
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              width: 2.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                revealedAnswer!.icon,
                size: 38.0,
                color: revealedAnswer!.color,
              ),
              const SizedBox(height: 4.0),
              Text(
                localizedLabel,
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Semantics(
      label: 'Target item: What comes next?',
      child: Container(
        width: 72.0,
        height: 90.0,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            width: 2.0,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.help_outline_rounded,
              size: 36.0,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            ),
            const SizedBox(height: 4.0),
            Text(
              AppStrings.get('nextQuestionSlot', locale: locale),
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
