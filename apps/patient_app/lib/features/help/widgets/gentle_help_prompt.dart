import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/smriti_theme.dart';

/// Subtle, elderly-friendly stuck assistance prompt banner.
///
/// Designed to provide gentle encouragement and assistance without interrupting
/// gameplay, pausing the board, or inducing anxiety.
class GentleHelpPrompt extends StatelessWidget {
  final VoidCallback onHelpMe;
  final VoidCallback onNotNow;

  const GentleHelpPrompt({
    super.key,
    required this.onHelpMe,
    required this.onNotNow,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Semantics(
      liveRegion: true,
      label: 'Need a little help? Assistance is available.',
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCardElevated : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: SmritiTheme.restorativeSage.withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
              blurRadius: 10.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gentle Icon
            Container(
              width: 44.0,
              height: 44.0,
              decoration: BoxDecoration(
                color: SmritiTheme.restorativeSage.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: SmritiTheme.restorativeSage,
                size: 26.0,
              ),
            ),
            const SizedBox(width: 12.0),

            // Supportive Message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Need a little help?',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    'Take your time. A hint is ready if you\'d like one.',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),

            // Action Buttons (min 48-56dp target)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // [Not now] button
                TextButton(
                  onPressed: onNotNow,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(64.0, 48.0),
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Text(
                    'Not now',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 4.0),

                // [Help me] button
                ElevatedButton(
                  onPressed: onHelpMe,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SmritiTheme.restorativeSage,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(80.0, 48.0),
                    padding: const EdgeInsets.symmetric(horizontal: 14.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 1.0,
                  ),
                  child: const Text(
                    'Help me',
                    style: TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
