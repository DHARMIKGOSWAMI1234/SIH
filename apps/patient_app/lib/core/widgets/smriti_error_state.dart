import 'package:flutter/material.dart';
import '../theme/smriti_theme.dart';
import 'smriti_primary_button.dart';

/// Clear, calm error display with a prominent retry action.
class SmritiErrorState extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const SmritiErrorState({
    super.key,
    this.title = 'Something went gently wrong',
    this.message = 'Please tap below to try again.',
    this.onRetry,
    this.retryLabel = 'Try Again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: const BoxDecoration(
                color: SmritiTheme.alertOrangeLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 54.0,
                color: SmritiTheme.alertOrange,
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: SmritiTheme.darkText,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12.0),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18.0,
                color: SmritiTheme.mutedText,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 28.0),
              SmritiPrimaryButton(
                label: retryLabel,
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
