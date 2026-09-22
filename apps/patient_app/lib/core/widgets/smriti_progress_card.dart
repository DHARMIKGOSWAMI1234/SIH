import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'smriti_card.dart';

/// Reusable metric card for progress, participation summaries, and result screens.
class SmritiProgressCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final String? subtitle;

  const SmritiProgressCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = color ?? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);

    return SmritiCard(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10.0),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28.0, color: accentColor),
              ),
              if (subtitle != null) ...[
                const SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    subtitle!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 14.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 28.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
