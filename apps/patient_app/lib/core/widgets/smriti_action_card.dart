import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'smriti_card.dart';

/// Standardized elderly-first action card with high contrast,
/// large touch area, and clear directional chevron.
class SmritiActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback onTap;
  final Widget? trailing;
  final Color? borderColor;
  final Color? backgroundColor;

  const SmritiActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    required this.onTap,
    this.trailing,
    this.borderColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultIconColor = iconColor ?? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);
    final defaultBg = iconBackgroundColor ??
        (isDark ? AppColors.darkSoftBlue : const Color(0xFFEDE9DE));

    return SmritiCard(
      backgroundColor: backgroundColor,
      borderColor: borderColor,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: defaultBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 36.0, color: defaultIconColor),
          ),
          const SizedBox(width: 18.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8.0),
          trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                size: 22.0,
              ),
        ],
      ),
    );
  }
}
