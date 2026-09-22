import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Clear, large section header with optional subtitle.
class SmritiSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SmritiSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: 28.0,
                ),
                const SizedBox(width: 10.0),
              ],
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
              if (actionLabel != null && onAction != null)
                TextButton(
                  onPressed: onAction,
                  child: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                  ),
                ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4.0),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: 16.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
