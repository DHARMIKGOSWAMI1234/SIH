import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'smriti_card.dart';

/// Standardized cognitive game card ensuring visual family consistency
/// across Memory Match, Pattern Recognition, and Daily Routine Recall.
class SmritiGameCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String category;
  final int difficultyLevel;
  final VoidCallback onTap;
  final String ctaLabel;

  const SmritiGameCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.difficultyLevel = 1,
    required this.onTap,
    this.ctaLabel = 'Play Activity',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 48.0,
                height: 48.0,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSoftBlue : const Color(0xFFEDE9DE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 26.0,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 14.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSoftBlue
                                : AppColors.lightPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.0),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF323D42)
                                : const Color(0xFFF9F3E7),
                            borderRadius: BorderRadius.circular(6.0),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkSoftGold.withValues(alpha: 0.4)
                                  : AppColors.lightHighlight.withValues(alpha: 0.6),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'Gentle • Level $difficultyLevel',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkSoftGold : const Color(0xFF96732B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            description,
            style: TextStyle(
              fontSize: 15.0,
              height: 1.35,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12.0),
          SizedBox(
            width: double.infinity,
            height: 56.0,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark ? AppColors.darkSoftBlue : AppColors.lightPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  side: BorderSide(
                    color: isDark
                        ? AppColors.darkPrimary.withValues(alpha: 0.5)
                        : AppColors.lightPrimary,
                    width: 1.2,
                  ),
                ),
              ),
              icon: const Icon(Icons.play_circle_filled_rounded, size: 24.0),
              label: Text(
                ctaLabel,
                style: const TextStyle(
                  fontSize: 17.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
