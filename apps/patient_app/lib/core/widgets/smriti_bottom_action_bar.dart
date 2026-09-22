import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Sticky, accessible bottom action bar for game and result screens.
/// Guarantees generous touch targets and avoids screen-edge cramping.
class SmritiBottomActionBar extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  const SmritiBottomActionBar({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10.0,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: padding,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
