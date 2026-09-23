import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../models/memory_card_item.dart';

/// Accessible Memory Match Card Widget with smooth 3D flip animation and high contrast.
class MemoryCardWidget extends StatelessWidget {
  final MemoryCardTile tile;
  final VoidCallback onTap;
  final double cardWidth;
  final double cardHeight;

  const MemoryCardWidget({
    super.key,
    required this.tile,
    required this.onTap,
    this.cardWidth = 100.0,
    this.cardHeight = 125.0,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: tile.semanticLabel,
      button: !tile.isMatched,
      enabled: !tile.isMatched,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: SmritiTheme.recommendedTouchTarget,
          minHeight: SmritiTheme.recommendedTouchTarget,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: tile.isMatched ? null : onTap,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            transitionBuilder: (Widget child, Animation<double> animation) {
              final rotate = Tween(begin: pi, end: 0.0).animate(animation);
              return AnimatedBuilder(
                animation: rotate,
                child: child,
                builder: (context, child) {
                  final isUnder = (ValueKey(tile.isFaceUp || tile.isMatched) != child?.key);
                  var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
                  tilt *= isUnder ? -1.0 : 1.0;
                  final value = isUnder ? min(rotate.value, pi / 2) : rotate.value;
                  return Transform(
                    transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
                    alignment: Alignment.center,
                    child: child,
                  );
                },
              );
            },
            layoutBuilder: (widget, list) => Stack(children: [?widget, ...list]),
            child: (tile.isFaceUp || tile.isMatched)
                ? _buildFrontCard(context)
                : _buildBackCard(context),
          ),
        ),
      ),
    );
  }

  /// Front Face (Revealed or Matched)
  Widget _buildFrontCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMatched = tile.isMatched;
    final isHinted = tile.isHighlighted;

    Color borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    Color bgColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    if (isMatched) {
      borderColor = isDark ? AppColors.darkPrimary : SmritiTheme.successGreen;
      bgColor = isDark ? const Color(0xFF1E2E2A) : const Color(0xFFF2F6F3);
    } else if (isHinted) {
      borderColor = isDark ? AppColors.darkSoftGold : const Color(0xFFD97706);
      bgColor = isDark ? const Color(0xFF2A281E) : const Color(0xFFFFFBEB);
    }

    final accentColor = isMatched
        ? (isDark ? AppColors.darkPrimary : SmritiTheme.successGreen)
        : (isDark ? AppColors.darkPrimary : AppColors.lightPrimary);

    return Container(
      key: const ValueKey(true),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: borderColor, width: isMatched || isHinted ? 2.5 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 8.0,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 6.0),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tile.item.icon,
              size: cardHeight > 110 ? 40.0 : 32.0,
              color: accentColor,
            ),
            const SizedBox(height: 4.0),
            Text(
              tile.item.label,
              style: TextStyle(
                fontSize: cardHeight > 110 ? 15.0 : 13.0,
                fontWeight: FontWeight.bold,
                color: isMatched
                    ? accentColor
                    : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (isMatched) ...[
              const SizedBox(height: 2.0),
              Icon(Icons.check_circle_rounded, size: 16.0, color: accentColor),
            ],
          ],
        ),
      ),
    );
  }

  /// Back Face (Hidden)
  Widget _buildBackCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isHinted = tile.isHighlighted;

    final backColor = isHinted
        ? (isDark ? const Color(0xFF2A281E) : const Color(0xFFFFFBEB))
        : (isDark ? AppColors.darkCard : AppColors.lightPrimary);
    final borderColor = isHinted
        ? (isDark ? AppColors.darkSoftGold : const Color(0xFFD97706))
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Container(
      key: const ValueKey(false),
      width: cardWidth,
      height: cardHeight,
      decoration: BoxDecoration(
        color: backColor,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: borderColor,
          width: isHinted ? 3.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
            blurRadius: 8.0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isHinted ? Icons.lightbulb_rounded : Icons.spa_rounded,
              size: cardHeight > 110 ? 38.0 : 30.0,
              color: isHinted
                  ? (isDark ? AppColors.darkSoftGold : const Color(0xFFD97706))
                  : (isDark ? AppColors.darkPrimary : Colors.white),
            ),
            const SizedBox(height: 4.0),
            Text(
              isHinted ? 'Hint' : 'BANDHU',
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: isHinted
                    ? (isDark ? AppColors.darkSoftGold : const Color(0xFFD97706))
                    : (isDark ? AppColors.darkTextSecondary : Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
