import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Standardized elderly-first confirmation dialog.
/// Avoids clinical or alarming language and ensures clear, large buttons.
class SmritiConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String positiveLabel;
  final String negativeLabel;
  final VoidCallback onPositive;
  final VoidCallback onNegative;
  final IconData icon;

  const SmritiConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.positiveLabel = 'Resume',
    this.negativeLabel = 'Leave Exercise',
    required this.onPositive,
    required this.onNegative,
    this.icon = Icons.pause_circle_outline_rounded,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String positiveLabel = 'Resume',
    String negativeLabel = 'Leave Exercise',
    IconData icon = Icons.pause_circle_outline_rounded,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => SmritiConfirmationDialog(
        title: title,
        message: message,
        positiveLabel: positiveLabel,
        negativeLabel: negativeLabel,
        icon: icon,
        onPositive: () => Navigator.of(ctx).pop(true),
        onNegative: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
        side: BorderSide(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      title: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            size: 32.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(
          fontSize: 18.0,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          height: 1.4,
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      actions: [
        TextButton(
          onPressed: onNegative,
          child: Text(
            negativeLabel,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Color(0xFFDC2626),
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          onPressed: onPositive,
          child: Text(
            positiveLabel,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkBg : Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
