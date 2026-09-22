import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/core/theme/smriti_theme.dart';

void main() {
  group('Elderly-First SmritiTheme Guarantees', () {
    test('Theme provides high-contrast palette with warm cream background', () {
      final theme = SmritiTheme.lightTheme;

      expect(theme.scaffoldBackgroundColor, SmritiTheme.warmCream);
      expect(theme.colorScheme.primary, SmritiTheme.deepSlate);
      expect(theme.colorScheme.secondary, SmritiTheme.restorativeSage);
    });

    test('Typography guarantees large readable body and heading sizes', () {
      final theme = SmritiTheme.lightTheme;
      final textTheme = theme.textTheme;

      // Body text must be at least 18sp
      expect(textTheme.bodyLarge?.fontSize, greaterThanOrEqualTo(18.0));
      expect(textTheme.bodyMedium?.fontSize, greaterThanOrEqualTo(18.0));

      // Headings must be prominent (>= 22sp)
      expect(textTheme.titleLarge?.fontSize, greaterThanOrEqualTo(22.0));
      expect(textTheme.headlineMedium?.fontSize, greaterThanOrEqualTo(24.0));
      expect(textTheme.headlineLarge?.fontSize, greaterThanOrEqualTo(30.0));
    });

    test('Touch target dimensions meet minimum accessibility criteria', () {
      expect(SmritiTheme.minTouchTarget, greaterThanOrEqualTo(56.0));
      expect(SmritiTheme.recommendedTouchTarget, greaterThanOrEqualTo(64.0));
    });
  });
}
