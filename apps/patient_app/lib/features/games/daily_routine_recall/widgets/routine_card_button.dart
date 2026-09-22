import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../l10n/app_strings.dart';
import '../models/routine_item.dart';

enum RoutineCardState {
  available,
  selectedInSequence,
  highlightedByHint,
  eliminatedByHint,
}

/// Large accessible activity card in the pool for Daily Routine Recall.
class RoutineCardButton extends StatelessWidget {
  final RoutineItem item;
  final RoutineCardState state;
  final VoidCallback? onTap;
  final String locale;

  const RoutineCardButton({
    super.key,
    required this.item,
    this.state = RoutineCardState.available,
    this.onTap,
    this.locale = 'en',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final icon = RoutineVisualResolver.getIcon(item.iconIdentifier);
    final color = RoutineVisualResolver.getColor(item.colorIdentifier);
    final label = item.getLocalizedLabel(locale);

    final isSelected = state == RoutineCardState.selectedInSequence;
    final isEliminated = state == RoutineCardState.eliminatedByHint;
    final isHighlighted = state == RoutineCardState.highlightedByHint;
    final isClickable = state == RoutineCardState.available || isHighlighted;

    Color borderColor;
    Color cardColor;
    double borderWidth = 1.5;

    if (isHighlighted) {
      borderColor = const Color(0xFFF59E0B);
      borderWidth = 2.5;
      cardColor = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
    } else if (isSelected) {
      borderColor = isDark ? AppColors.darkPrimary.withValues(alpha: 0.5) : SmritiTheme.restorativeSage.withValues(alpha: 0.4);
      cardColor = isDark ? AppColors.darkCardElevated : SmritiTheme.sageLight.withValues(alpha: 0.5);
    } else if (isEliminated) {
      borderColor = isDark ? AppColors.darkBorder.withValues(alpha: 0.4) : Colors.grey.shade300;
      cardColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey.shade100;
    } else {
      borderColor = isDark ? AppColors.darkBorder : SmritiTheme.deepSlate.withValues(alpha: 0.15);
      cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    }

    return Semantics(
      label: '$label. ${item.category}. '
          '${isSelected ? "Already in sequence" : ""}'
          '${isEliminated ? "Eliminated by hint" : ""}'
          '${isHighlighted ? "Suggested by hint" : ""}',
      button: isClickable,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isEliminated ? 0.45 : (isSelected ? 0.65 : 1.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isClickable ? onTap : null,
            borderRadius: BorderRadius.circular(16.0),
            child: Container(
              constraints: const BoxConstraints(minHeight: 64.0),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(color: borderColor, width: borderWidth),
                boxShadow: isClickable
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 6.0,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Activity Icon Container
                  Container(
                    width: 44.0,
                    height: 44.0,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 26.0),
                  ),
                  const SizedBox(width: 14.0),

                  // Title and Category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: isEliminated
                                ? (isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.5) : SmritiTheme.mutedText)
                                : (isDark ? AppColors.darkTextPrimary : SmritiTheme.deepSlate),
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          item.category,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: isHighlighted
                                ? const Color(0xFFB45309)
                                : (isDark ? AppColors.darkTextSecondary : SmritiTheme.mutedText),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // State Indicator Trailing Icon
                  if (isSelected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_rounded,
                              color: Colors.white, size: 16.0),
                          SizedBox(width: 4.0),
                          Text(
                            'Added',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isEliminated)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        AppStrings.get('distractorEliminated', locale: locale),
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : Colors.grey.shade700,
                        ),
                      ),
                    )
                  else if (isHighlighted)
                    const Icon(
                      Icons.lightbulb_rounded,
                      color: Color(0xFFD97706),
                      size: 26.0,
                    )
                  else
                    Icon(
                      Icons.add_circle_outline_rounded,
                      color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
                      size: 28.0,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
