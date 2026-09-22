import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../core/widgets/smriti_primary_button.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_section_header.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../l10n/locale_notifier.dart';
import '../models/pattern_recognition_state.dart';
import 'pattern_recognition_game_screen.dart';

/// Patient-facing introductory screen for Pattern Recognition.
/// Explains how to play gently and allows selection of difficulty.
class PatternRecognitionIntroScreen extends StatefulWidget {
  final PatternDifficulty initialDifficulty;

  const PatternRecognitionIntroScreen({
    super.key,
    this.initialDifficulty = PatternDifficulty.easy,
  });

  @override
  State<PatternRecognitionIntroScreen> createState() =>
      _PatternRecognitionIntroScreenState();
}

class _PatternRecognitionIntroScreenState
    extends State<PatternRecognitionIntroScreen> {
  late PatternDifficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
  }

  String _getLocale(BuildContext context) {
    try {
      final notifier = context.watch<LocaleNotifier?>();
      if (notifier != null) return notifier.currentLocale;
    } catch (_) {}
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = _getLocale(context);

    return SmritiScaffold(
      title: AppStrings.get('patternGame', locale: loc),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Section 1: Calm Guidance Header
          SmritiSectionHeader(
            title: AppStrings.get('visualRhythms', locale: loc),
            subtitle: AppStrings.get('patternSubtitle', locale: loc),
            icon: Icons.pattern_rounded,
          ),
          const SizedBox(height: 16.0),

          // Section 2: Instructions Card
          SmritiCard(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightWarmAccent.withValues(alpha: 0.15),
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightWarmAccent.withValues(alpha: 0.3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      size: 28.0,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      AppStrings.get('patternHowToPlay', locale: loc),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                _buildInstructionRow('1', AppStrings.get('patternInstruction1', locale: loc), isDark),
                const SizedBox(height: 8.0),
                _buildInstructionRow('2', AppStrings.get('patternInstruction2', locale: loc), isDark),
                const SizedBox(height: 8.0),
                _buildInstructionRow('3', AppStrings.get('patternInstruction3', locale: loc), isDark),
                const SizedBox(height: 8.0),
                _buildInstructionRow('4', AppStrings.get('patternInstruction4', locale: loc), isDark),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Section 3: Difficulty Selection
          Text(
            AppStrings.get('patternSelectLevel', locale: loc),
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 12.0),

          _buildDifficultyCard(
            difficulty: PatternDifficulty.easy,
            title: '${AppStrings.get('difficultyEasy', locale: loc)} (Level 1)',
            subtitle: AppStrings.get('patternEasyDesc', locale: loc),
            icon: Icons.filter_1_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12.0),

          _buildDifficultyCard(
            difficulty: PatternDifficulty.medium,
            title: '${AppStrings.get('difficultyMedium', locale: loc)} (Level 2)',
            subtitle: AppStrings.get('patternMediumDesc', locale: loc),
            icon: Icons.filter_2_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12.0),

          _buildDifficultyCard(
            difficulty: PatternDifficulty.hard,
            title: '${AppStrings.get('difficultyHard', locale: loc)} (Level 3)',
            subtitle: AppStrings.get('patternHardDesc', locale: loc),
            icon: Icons.filter_3_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 28.0),

          // Section 4: Start Action Button
          SmritiPrimaryButton(
            label: AppStrings.get('startPatternExercise', locale: loc),
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PatternRecognitionGameScreen(
                    difficulty: _selectedDifficulty,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionRow(String number, String text, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.0,
          height: 24.0,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: isDark ? AppColors.darkBackground : Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard({
    required PatternDifficulty difficulty,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _selectedDifficulty == difficulty;

    return Semantics(
      label: '$title, $subtitle, ${isSelected ? 'selected' : 'not selected'}',
      button: true,
      child: SmritiCard(
        onTap: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        backgroundColor: isSelected
            ? (isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.2))
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderColor: isSelected
            ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36.0,
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              size: 28.0,
            ),
          ],
        ),
      ),
    );
  }
}
