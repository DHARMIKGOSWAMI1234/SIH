import 'package:flutter/material.dart';

/// Centralized Color Palette for SMRITI AI Cognitive Care Companion.
///
/// Implements the elderly-first dual-theme specification:
/// Light Mode: Warm Ivory, Soft Dusty Blue, Muted Lavender, Soft Peach, Champagne Gold.
/// Dark Mode: #1C252B Deep Slate, #273239 Cards, #8EADBD Dusty Blue, #354650 Soft Blue, #D6A08D Warm Peach.
class AppColors {
  // ---------------------------------------------------------------------------
  // LIGHT MODE PALETTE
  // ---------------------------------------------------------------------------
  static const Color lightBackground = Color(0xFFF8F5EE); // Warm Ivory
  static const Color lightCard = Color(0xFFFFFDFC);       // Cream White
  static const Color lightPrimary = Color(0xFF7896A8);    // Soft Dusty Blue
  static const Color lightSecondary = Color(0xFFA69AB8);  // Muted Lavender
  static const Color lightWarmAccent = Color(0xFFD9A08B); // Soft Peach
  static const Color lightHighlight = Color(0xFFD6BC82);  // Champagne Gold
  static const Color lightTextPrimary = Color(0xFF39413F);// Warm Charcoal
  static const Color lightTextSecondary = Color(0xFF707775);// Soft Gray
  static const Color lightSage = Color(0xFF91A28F);       // Sage (sparingly)
  static const Color lightBorder = Color(0xFFE5DFC6);     // Subtle Warm Border

  // ---------------------------------------------------------------------------
  // DARK MODE PALETTE
  // ---------------------------------------------------------------------------
  static const Color darkBackground = Color(0xFF1C252B);  // Deep Dark Background
  static const Color darkBg = darkBackground;             // Convenient alias
  static const Color darkCard = Color(0xFF273239);        // Deep Slate Card
  static const Color darkCardElevated = Color(0xFF2E3B43);// Elevated Slate Card
  static const Color darkPrimary = Color(0xFF8EADBD);     // Primary Interactive Blue
  static const Color darkSoftBlue = Color(0xFF354650);    // Secondary Surface / Accent
  static const Color darkWarmPeach = Color(0xFFD6A08D);   // Warm Peach
  static const Color darkWarmAccent = darkWarmPeach;      // Convenient alias
  static const Color darkSoftGold = Color(0xFFD5BC7A);    // Soft Gold Highlight
  static const Color darkTextPrimary = Color(0xFFF4EFE6); // Off-White Primary Text
  static const Color darkTextSecondary = Color(0xFFB9C1C3);// Muted Slate Text
  static const Color darkBorder = Color(0xFF3A464D);      // Clean Dark Border

  // ---------------------------------------------------------------------------
  // SEMANTIC STATUS COLORS (Calm & Non-Alarming)
  // ---------------------------------------------------------------------------
  static const Color successGreen = Color(0xFF4E9A70);
  static const Color warningOrange = Color(0xFFD97706);
  static const Color errorRed = Color(0xFFC2410C);
  static const Color darkError = errorRed;
}
