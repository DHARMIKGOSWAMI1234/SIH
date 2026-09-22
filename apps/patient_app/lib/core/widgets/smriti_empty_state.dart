import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'smriti_primary_button.dart';

/// Friendly, large empty state for elderly users.
class SmritiEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SmritiEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconBg = isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.2);
    final iconColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final titleColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final msgColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 54.0, color: iconColor),
            ),
            const SizedBox(height: 24.0),
            Text(
              title,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: titleColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              style: TextStyle(
                fontSize: 18.0,
                color: msgColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28.0),
              SmritiPrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
