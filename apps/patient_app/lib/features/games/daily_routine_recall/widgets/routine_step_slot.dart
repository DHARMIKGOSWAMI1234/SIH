import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../l10n/app_strings.dart';
import '../models/routine_item.dart';

/// Single chronological sequence slot widget for Daily Routine Recall.
class RoutineStepSlot extends StatelessWidget {
  final int stepNumber;
  final RoutineItem? item;
  final VoidCallback? onTapRemove;
  final String locale;
  final bool isVerified;
  final bool isSequenceCorrect;

  const RoutineStepSlot({
    super.key,
    required this.stepNumber,
    required this.item,
    this.onTapRemove,
    this.locale = 'en',
    this.isVerified = false,
    this.isSequenceCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (item == null) {
      // Empty Slot Placeholder
      return Semantics(
        label: '${AppStrings.get('stepLabel', locale: locale)} $stepNumber: Empty. ${AppStrings.get('tapToAddToOrder', locale: locale)}',
        child: Container(
          constraints: const BoxConstraints(minHeight: 64.0),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : SmritiTheme.deepSlate.withValues(alpha: 0.2),
              width: 1.5,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            children: [
              // Step Number Badge
              Container(
                width: 36.0,
                height: 36.0,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder.withValues(alpha: 0.4) : SmritiTheme.deepSlate.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : SmritiTheme.deepSlate,
                  ),
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Text(
                  '${AppStrings.get('stepLabel', locale: locale)} $stepNumber: ${AppStrings.get('tapToAddToOrder', locale: locale)}',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.7) : SmritiTheme.mutedText.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Filled Slot with chosen Activity
    final routineItem = item!;
    final icon = RoutineVisualResolver.getIcon(routineItem.iconIdentifier);
    final color = RoutineVisualResolver.getColor(routineItem.colorIdentifier);
    final label = routineItem.getLocalizedLabel(locale);

    Color borderColor = isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage;
    Color bgColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    if (isVerified) {
      if (isSequenceCorrect) {
        borderColor = isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage;
        bgColor = isDark ? const Color(0xFF064E3B) : SmritiTheme.sageLight;
      } else {
        borderColor = const Color(0xFFD97706);
        bgColor = isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7);
      }
    }

    return Semantics(
      label: '${AppStrings.get('stepLabel', locale: locale)} $stepNumber: $label. Tap to remove.',
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isVerified ? null : onTapRemove,
          borderRadius: BorderRadius.circular(16.0),
          child: Container(
            constraints: const BoxConstraints(minHeight: 64.0),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 6.0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Step Badge
                Container(
                  width: 32.0,
                  height: 32.0,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Transform.translate(
                  offset: const Offset(-24, 0),
                  child: Text(
                    '$stepNumber',
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 2.0),

                // Activity Icon
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24.0),
                ),
                const SizedBox(width: 12.0),

                // Activity Label
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : SmritiTheme.deepSlate,
                    ),
                  ),
                ),

                // Remove Action Indicator
                if (!isVerified)
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 26.0,
                    ),
                    tooltip: 'Remove from step $stepNumber',
                    onPressed: onTapRemove,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
