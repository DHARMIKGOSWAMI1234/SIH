import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/smriti_theme.dart';

/// Secondary action button with high-contrast outline and large touch target.
class SmritiSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double minWidth;

  const SmritiSecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.minWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: SmritiTheme.recommendedTouchTarget,
        minWidth: minWidth,
      ),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: color,
          side: BorderSide(color: color, width: 2.0),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 24.0, color: color),
              const SizedBox(width: 10.0),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
