import 'package:flutter/material.dart';
import '../theme/smriti_theme.dart';

/// Calming, high-visibility loading state.
class SmritiLoadingState extends StatelessWidget {
  final String message;

  const SmritiLoadingState({
    super.key,
    this.message = 'Loading gently...',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 54.0,
              height: 54.0,
              child: CircularProgressIndicator(
                strokeWidth: 4.5,
                valueColor: AlwaysStoppedAnimation<Color>(SmritiTheme.restorativeSage),
              ),
            ),
            const SizedBox(height: 24.0),
            Text(
              message,
              style: const TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w600,
                color: SmritiTheme.darkText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
