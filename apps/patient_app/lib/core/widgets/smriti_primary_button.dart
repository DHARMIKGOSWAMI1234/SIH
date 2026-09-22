import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/smriti_theme.dart';

/// Large, accessible high-contrast button for elderly users.
class SmritiPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double minWidth;

  const SmritiPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.minWidth = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final defaultText = isDark ? AppColors.darkBackground : Colors.white;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: SmritiTheme.recommendedTouchTarget,
        minWidth: minWidth,
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? defaultBg,
          foregroundColor: textColor ?? defaultText,
          elevation: isDark ? 2.0 : 1.5,
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
              Icon(icon, size: 26.0),
              const SizedBox(width: 10.0),
            ],
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
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
