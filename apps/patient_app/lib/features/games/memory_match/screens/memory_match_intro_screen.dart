import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../core/widgets/smriti_section_header.dart';
import '../../../../core/widgets/smriti_primary_button.dart';
import '../../../../core/widgets/smriti_secondary_button.dart';
import '../models/memory_match_state.dart';
import 'memory_match_game_screen.dart';

/// Introductory screen for Memory Match.
/// Allows difficulty selection with high readability and zero anxiety.
class MemoryMatchIntroScreen extends StatefulWidget {
  final MemoryMatchDifficulty initialDifficulty;

  const MemoryMatchIntroScreen({
    super.key,
    this.initialDifficulty = MemoryMatchDifficulty.easy,
  });

  @override
  State<MemoryMatchIntroScreen> createState() => _MemoryMatchIntroScreenState();
}

class _MemoryMatchIntroScreenState extends State<MemoryMatchIntroScreen> {
  late MemoryMatchDifficulty _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.initialDifficulty;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: 'Memory Match',
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightWarmAccent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightWarmAccent.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoftBlue : AppColors.lightCard,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.extension_rounded,
                    size: 44.0,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
                const SizedBox(width: 18.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Memory Match',
                        style: TextStyle(
                          fontSize: 26.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Familiar Pictures & Routine Items',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Simple Instructions
          const SmritiSectionHeader(
            title: 'How to Play',
            subtitle: 'Gentle instructions for comfortable enjoyment',
            icon: Icons.lightbulb_outline_rounded,
          ),
          SmritiCard(
            child: Column(
              children: [
                _buildInstructionRow(
                  number: '1',
                  text: 'Tap on any card to reveal its picture.',
                  isDark: isDark,
                ),
                const SizedBox(height: 14.0),
                _buildInstructionRow(
                  number: '2',
                  text: 'Tap a second card to find the matching picture.',
                  isDark: isDark,
                ),
                const SizedBox(height: 14.0),
                _buildInstructionRow(
                  number: '3',
                  text: 'Take all the time you need. There is no hurry.',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Difficulty Selector
          const SmritiSectionHeader(
            title: 'Choose Activity Level',
            icon: Icons.tune_rounded,
          ),
          Row(
            children: MemoryMatchDifficulty.values.map((diff) {
              final isSelected = _selectedDifficulty == diff;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SmritiCard(
                    padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
                    backgroundColor: isSelected
                        ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderColor: isSelected
                        ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    onTap: () => setState(() => _selectedDifficulty = diff),
                    child: Column(
                      children: [
                        Text(
                          diff.displayName,
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? (isDark ? AppColors.darkBg : Colors.white)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Text(
                          '${diff.pairCount} Pairs',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: isSelected
                                ? (isDark ? AppColors.darkBg.withValues(alpha: 0.8) : Colors.white70)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 36.0),

          // Actions
          SmritiPrimaryButton(
            label: 'Start Game',
            icon: Icons.play_arrow_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MemoryMatchGameScreen(difficulty: _selectedDifficulty),
                ),
              );
            },
          ),
          const SizedBox(height: 14.0),
          SmritiSecondaryButton(
            label: 'Back to Games',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  static Widget _buildInstructionRow({
    required String number,
    required String text,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14.0),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 17.0,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
