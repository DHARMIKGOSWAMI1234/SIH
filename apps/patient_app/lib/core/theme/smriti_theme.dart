import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized Elderly-First Design System for SMRITI.
///
/// Implements the SIH26003 approved dual-theme specification:
/// - Light Mode: Warm Ivory (#F8F5EE), Cream White Cards (#FFFDFC), Dusty Blue (#7896A8), Warm Charcoal Text (#39413F)
/// - Dark Mode: Deep Dark (#1C252B), Cards (#273239), Primary Dusty Blue (#8EADBD), Off-White Text (#F4EFE6)
class SmritiTheme {
  // ---------------------------------------------------------------------------
  // BACKWARD COMPATIBLE & THEME CONSTANTS
  // ---------------------------------------------------------------------------
  static const Color warmCream = AppColors.lightBackground;
  static const Color cardSurface = AppColors.lightCard;
  static const Color deepSlate = AppColors.lightTextPrimary;
  static const Color darkText = AppColors.lightTextPrimary;
  static const Color mutedText = AppColors.lightTextSecondary;
  static const Color restorativeSage = AppColors.lightPrimary;
  static const Color sageLight = Color(0xFFE9F0F4);
  static const Color borderSubtle = AppColors.lightBorder;
  static const Color alertOrange = AppColors.errorRed;
  static const Color alertOrangeLight = Color(0xFFFFF7ED);
  static const Color successGreen = AppColors.successGreen;

  // Dark Theme Palette Constants
  static const Color darkNavy = AppColors.darkBackground;
  static const Color darkSurface = AppColors.darkCard;
  static const Color darkSurfaceCard = AppColors.darkCard;
  static const Color darkTextPrimary = AppColors.darkTextPrimary;
  static const Color darkTextSecondary = AppColors.darkTextSecondary;
  static const Color darkBorder = AppColors.darkBorder;
  static const Color sageAccentDark = AppColors.darkPrimary;

  // Touch Targets
  static const double minTouchTarget = 56.0;
  static const double recommendedTouchTarget = 64.0;

  // ---------------------------------------------------------------------------
  // CONTEXTUAL THEME HELPERS
  // ---------------------------------------------------------------------------
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color cardBg(BuildContext context) =>
      isDarkMode(context) ? AppColors.darkCard : AppColors.lightCard;

  static Color cardBorderColor(BuildContext context) =>
      isDarkMode(context) ? AppColors.darkBorder : AppColors.lightBorder;

  static Color textPrimaryColor(BuildContext context) =>
      isDarkMode(context) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color textSecondaryColor(BuildContext context) =>
      isDarkMode(context) ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  static Color primaryAccent(BuildContext context) =>
      isDarkMode(context) ? AppColors.darkPrimary : AppColors.lightPrimary;

  static Color surfaceSubtle(BuildContext context) =>
      isDarkMode(context) ? AppColors.darkSoftBlue : const Color(0xFFEDE9DE);

  // ---------------------------------------------------------------------------
  // LIGHT THEME CONFIGURATION
  // ---------------------------------------------------------------------------
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: SmritiTheme.deepSlate,
        onPrimary: Colors.white,
        secondary: SmritiTheme.restorativeSage,
        onSecondary: Colors.white,
        surface: AppColors.lightCard,
        onSurface: AppColors.lightTextPrimary,
        error: AppColors.errorRed,
        onError: Colors.white,
        outline: AppColors.lightBorder,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
          height: 1.3,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
          color: AppColors.lightTextPrimary,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: AppColors.lightTextPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          color: AppColors.lightTextSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.lightTextPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 1.5,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 17.0,
          color: AppColors.lightTextPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightCard,
        modalBackgroundColor: AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightCard,
        hintStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 16.0),
        labelStyle: const TextStyle(color: AppColors.lightTextPrimary, fontSize: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.lightBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 2.0),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // DARK THEME CONFIGURATION
  // ---------------------------------------------------------------------------
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBackground,
        secondary: AppColors.darkSoftBlue,
        onSecondary: AppColors.darkTextPrimary,
        surface: AppColors.darkCard,
        onSurface: AppColors.darkTextPrimary,
        error: AppColors.errorRed,
        onError: Colors.white,
        outline: AppColors.darkBorder,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
          height: 1.3,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
          height: 1.3,
        ),
        titleLarge: TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.w700,
          color: AppColors.darkTextPrimary,
          height: 1.3,
        ),
        titleMedium: TextStyle(
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.darkTextPrimary,
          height: 1.4,
        ),
        bodyLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w500,
          color: AppColors.darkTextPrimary,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          color: AppColors.darkTextSecondary,
          height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
          color: AppColors.darkTextPrimary,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.35),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18.0),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 17.0,
          color: AppColors.darkTextPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        modalBackgroundColor: AppColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        hintStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 16.0),
        labelStyle: const TextStyle(color: AppColors.darkTextPrimary, fontSize: 16.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.0),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2.0),
        ),
      ),
    );
  }
}
