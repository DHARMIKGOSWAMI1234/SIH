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
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Standard circular icon container
              Container(
                padding: const EdgeInsets.all(14.0),
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
                  size: 32.0,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              const SizedBox(width: 16.0),
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
                    const SizedBox(height: 6.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 6.0,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkSoftBlue
                                : AppColors.lightPrimary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Text(
                            category,
                            style: TextStyle(
                              fontSize: 13.0,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF323D42)
                                : const Color(0xFFF9F3E7),
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkSoftGold.withValues(alpha: 0.4)
                                  : AppColors.lightHighlight.withValues(alpha: 0.6),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'Gentle • Level $difficultyLevel of 5',
                            style: TextStyle(
                              fontSize: 13.0,
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
          const SizedBox(height: 14.0),
          Text(
            description,
            style: TextStyle(
              fontSize: 17.0,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 16.0),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkSoftBlue
                    : AppColors.lightPrimary.withValues(alpha: 0.18),
                foregroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  side: BorderSide(
                    color: isDark ? AppColors.darkPrimary.withValues(alpha: 0.3) : AppColors.lightPrimary.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 20.0),
              label: Text(
                ctaLabel,
                style: const TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold),
              ),
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
