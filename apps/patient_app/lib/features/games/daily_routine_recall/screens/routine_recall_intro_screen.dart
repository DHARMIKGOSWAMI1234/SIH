import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../core/widgets/smriti_primary_button.dart';
import '../../../../core/widgets/smriti_section_header.dart';
import '../../../../l10n/app_strings.dart';
import '../models/routine_recall_state.dart';
import 'routine_recall_game_screen.dart';
import '../../../help/models/help_screen_id.dart';

/// Instructions and difficulty selection screen for Daily Routine Recall.
class RoutineRecallIntroScreen extends StatefulWidget {
  final RoutineRecallDifficulty initialDifficulty;

  const RoutineRecallIntroScreen({
    super.key,
    this.initialDifficulty = RoutineRecallDifficulty.easy,
  });

  @override
  State<RoutineRecallIntroScreen> createState() =>
      _RoutineRecallIntroScreenState();
}

class _RoutineRecallIntroScreenState extends State<RoutineRecallIntroScreen> {
  late RoutineRecallDifficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: AppStrings.get('routineRecallTitle'),
      helpScreenId: HelpScreenId.routine,
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Section 1: Calm Guidance Header
          SmritiSectionHeader(
            title: AppStrings.get('routineRecallTitle'),
            subtitle: AppStrings.get('routineRecallSubtitle'),
            icon: Icons.checklist_rounded,
          ),
          const SizedBox(height: 16.0),

          // Section 2: Instructions Card
          SmritiCard(
            backgroundColor: isDark ? AppColors.darkCardElevated : SmritiTheme.sageLight,
            borderColor: isDark ? AppColors.darkPrimary.withValues(alpha: 0.5) : SmritiTheme.restorativeSage,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline_rounded,
                      color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
                      size: 28.0,
                    ),
                    const SizedBox(width: 10.0),
                    Text(
                      AppStrings.get('routineHowToPlay'),
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14.0),
                _buildInstructionRow('1', AppStrings.get('routineInstruction1'), isDark),
                const SizedBox(height: 8.0),
                _buildInstructionRow('2', AppStrings.get('routineInstruction2'), isDark),
                const SizedBox(height: 8.0),
                _buildInstructionRow('3', AppStrings.get('routineInstruction3'), isDark),
                const SizedBox(height: 8.0),
                _buildInstructionRow('4', AppStrings.get('routineInstruction4'), isDark),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Section 3: Difficulty Selection
          Text(
            'Select Comfortable Level',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : SmritiTheme.deepSlate,
            ),
          ),
          const SizedBox(height: 12.0),

          _buildDifficultyCard(
            difficulty: RoutineRecallDifficulty.easy,
            title: 'Easy (Level 1)',
            subtitle: RoutineRecallDifficulty.easy.stepCountDescription,
            icon: Icons.filter_1_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12.0),

          _buildDifficultyCard(
            difficulty: RoutineRecallDifficulty.medium,
            title: 'Medium (Level 2)',
            subtitle: RoutineRecallDifficulty.medium.stepCountDescription,
            icon: Icons.filter_2_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12.0),

          _buildDifficultyCard(
            difficulty: RoutineRecallDifficulty.hard,
            title: 'Challenging (Level 3)',
            subtitle: RoutineRecallDifficulty.hard.stepCountDescription,
            icon: Icons.filter_3_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 28.0),

          // Section 4: Start Action Button
          SmritiPrimaryButton(
            label: 'Start Routine Exercise',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => RoutineRecallGameScreen(
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
            color: isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
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
              color: isDark ? AppColors.darkTextPrimary : SmritiTheme.deepSlate,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultyCard({
    required RoutineRecallDifficulty difficulty,
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
            ? (isDark ? AppColors.darkCardElevated : SmritiTheme.sageLight)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderColor: isSelected
            ? (isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage)
            : (isDark ? AppColors.darkBorder : SmritiTheme.deepSlate.withValues(alpha: 0.15)),
        child: Row(
          children: [
            Icon(
              icon,
              size: 36.0,
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage)
                  : (isDark ? AppColors.darkTextSecondary : SmritiTheme.deepSlate),
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
                          ? (isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage)
                          : (isDark ? AppColors.darkTextPrimary : SmritiTheme.deepSlate),
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isDark ? AppColors.darkTextSecondary : SmritiTheme.mutedText,
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
                  ? (isDark ? AppColors.darkPrimary : SmritiTheme.restorativeSage)
                  : (isDark ? AppColors.darkBorder : SmritiTheme.mutedText),
              size: 28.0,
            ),
          ],
        ),
      ),
    );
  }
}
