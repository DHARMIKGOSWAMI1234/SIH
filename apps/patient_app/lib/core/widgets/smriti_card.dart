import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Large, accessible touch card with clear visual feedback for elderly users.
/// Dynamically adapts to Light Mode (#FFFDFC) and Dark Mode (#273239).
class SmritiCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;

  const SmritiCard({
    super.key,
    required this.child,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.padding = const EdgeInsets.all(20.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = backgroundColor ?? (isDark ? AppColors.darkCard : AppColors.lightCard);
    final border = borderColor ?? (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Card(
      color: cardBg,
      elevation: isDark ? 2.0 : 1.5,
      shadowColor: Colors.black.withValues(alpha: isDark ? 0.35 : 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18.0),
        side: BorderSide(
          color: border,
          width: 1.5,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18.0),
        onTap: onTap,
        splashColor: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
        highlightColor: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.06),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
