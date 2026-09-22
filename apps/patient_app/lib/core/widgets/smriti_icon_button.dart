import 'package:flutter/material.dart';
import '../theme/smriti_theme.dart';

/// Accessible icon button strictly adhering to the 56dp+ minimum touch target.
class SmritiIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double? minSize;
  final double? iconSize;

  const SmritiIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.minSize,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final targetSize = minSize ?? SmritiTheme.minTouchTarget;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: targetSize,
        minHeight: targetSize,
      ),
      child: Tooltip(
        message: tooltip,
        textStyle: const TextStyle(fontSize: 16.0, color: Colors.white),
        child: Material(
          color: backgroundColor ?? Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            iconSize: iconSize ?? 32.0,
            icon: Icon(icon, color: color ?? SmritiTheme.deepSlate),
            onPressed: onPressed,
          ),
        ),
      ),
    );
  }
}
