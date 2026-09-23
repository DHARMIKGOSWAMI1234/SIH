import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../core/widgets/smriti_icon_button.dart';
import '../../core/widgets/smriti_game_card.dart';
import '../../core/widgets/smriti_action_card.dart';
import '../../l10n/app_strings.dart';
import '../games/games_screen.dart';
import '../games/models/game_model.dart';
import '../games/memory_match/screens/memory_match_intro_screen.dart';
import '../games/pattern_recognition/screens/pattern_recognition_intro_screen.dart';
import '../games/daily_routine_recall/screens/routine_recall_intro_screen.dart';
import '../reminders/reminders_screen.dart';
import '../memory/memory_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../profile/profile_screen.dart';

/// Elderly-First Home Screen: Central friendly hub with strong visual hierarchy.
/// Follows the approved structure: Greeting -> Today -> Play & Exercise -> My Memory -> My Day -> Progress.
class HomeScreen extends StatelessWidget {
  final String currentLocale;
  final ValueChanged<int>? onNavigateTab;

  const HomeScreen({
    super.key,
    this.currentLocale = 'en',
    this.onNavigateTab,
  });

  void _launchGame(BuildContext context, CognitiveGameType gameType) {
    if (gameType == CognitiveGameType.memoryMatch) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const MemoryMatchIntroScreen()),
      );
    } else if (gameType == CognitiveGameType.patternRecognition) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const PatternRecognitionIntroScreen()),
      );
    } else if (gameType == CognitiveGameType.dailyRoutineRecall) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const RoutineRecallIntroScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEmbeddedInShell = onNavigateTab != null;

    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final warmPeach = isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent;
    final softGold = isDark ? AppColors.darkSoftGold : AppColors.lightHighlight;
    final iconBg = isDark ? AppColors.darkSoftBlue : const Color(0xFFEDE9DE);

    final content = ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      children: [
        // 1. GREETING BANNER
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18.0),
            border: Border.all(
              color: borderColor,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.wb_sunny_rounded, size: 44.0, color: warmPeach),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.get('goodMorning', locale: currentLocale),
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      AppStrings.get('readyPrompt', locale: currentLocale),
                      style: TextStyle(
                        fontSize: 16.0,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24.0),

        // 2. TODAY: Next Activity
        SmritiSectionHeader(
          title: AppStrings.get('todaySectionTitle', locale: currentLocale),
          subtitle: AppStrings.get('todaySectionSubtitle', locale: currentLocale),
          icon: Icons.today_rounded,
        ),
        const SizedBox(height: 10.0),
        Container(
          padding: const EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: primaryColor,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 12.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSoftBlue : AppColors.lightPrimary.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'NEXT ACTIVITY',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.checklist_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    size: 26.0,
                  ),
                ],
              ),
              const SizedBox(height: 12.0),
              Text(
                AppStrings.get('routineRecall', locale: currentLocale),
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 6.0),
              Text(
                'Arrange familiar daily steps in order.',
                style: TextStyle(
                  fontSize: 16.0,
                  color: textSecondary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '3 gentle questions • at a comfortable pace',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkSoftGold : const Color(0xFF96732B),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                height: 58.0,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.0),
                    ),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 28.0),
                  label: Text(
                    AppStrings.get('startExercise', locale: currentLocale),
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                  onPressed: () => _launchGame(context, CognitiveGameType.dailyRoutineRecall),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24.0),

        // 3. PLAY & EXERCISE
        SmritiSectionHeader(
          title: AppStrings.get('playExerciseTitle', locale: currentLocale),
          subtitle: AppStrings.get('playExerciseSubtitle', locale: currentLocale),
          icon: Icons.psychology_rounded,
          actionLabel: isEmbeddedInShell ? null : AppStrings.get('allGames', locale: currentLocale),
          onAction: isEmbeddedInShell
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const GamesScreen()),
                  ),
        ),
        const SizedBox(height: 12.0),

        // Game 1: Memory Match
        SmritiGameCard(
          title: AppStrings.get('memoryGame', locale: currentLocale),
          description: AppStrings.get('memoryGameDesc', locale: currentLocale),
          icon: Icons.extension_rounded,
          category: AppStrings.get('catVisualRecall', locale: currentLocale),
          difficultyLevel: 1,
          onTap: () => _launchGame(context, CognitiveGameType.memoryMatch),
        ),
        const SizedBox(height: 12.0),

        // Game 2: Pattern Recognition
        SmritiGameCard(
          title: AppStrings.get('patternGame', locale: currentLocale),
          description: AppStrings.get('patternGameDesc', locale: currentLocale),
          icon: Icons.pattern_rounded,
          category: AppStrings.get('catLogicalPatterns', locale: currentLocale),
          difficultyLevel: 1,
          onTap: () => _launchGame(context, CognitiveGameType.patternRecognition),
        ),
        const SizedBox(height: 12.0),

        // Game 3: Daily Routine Recall
        SmritiGameCard(
          title: AppStrings.get('routineRecall', locale: currentLocale),
          description: AppStrings.get('routineRecallDesc', locale: currentLocale),
          icon: Icons.checklist_rounded,
          category: AppStrings.get('catRoutineSteps', locale: currentLocale),
          difficultyLevel: 1,
          onTap: () => _launchGame(context, CognitiveGameType.dailyRoutineRecall),
        ),

        const SizedBox(height: 24.0),

        // 4. MY MEMORY
        SmritiSectionHeader(
          title: AppStrings.get('myMemoryTitle', locale: currentLocale),
          subtitle: AppStrings.get('myMemorySubtitle', locale: currentLocale),
          icon: Icons.photo_library_rounded,
        ),
        const SizedBox(height: 10.0),
        SmritiActionCard(
          title: AppStrings.get('memoryBankCardTitle', locale: currentLocale),
          subtitle: AppStrings.get('memoryBankCardSubtitle', locale: currentLocale),
          icon: Icons.photo_library_rounded,
          iconColor: softGold,
          iconBackgroundColor: iconBg,
          onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(2);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemoryScreen()),
              );
            }
          },
        ),
        const SizedBox(height: 12.0),
        SmritiActionCard(
          title: AppStrings.get('myLifeStoryCardTitle', locale: currentLocale),
          subtitle: AppStrings.get('myLifeStoryCardSubtitle', locale: currentLocale),
          icon: Icons.auto_stories_rounded,
          iconColor: primaryColor,
          iconBackgroundColor: iconBg,
          onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(2);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MemoryScreen()),
              );
            }
          },
        ),

        const SizedBox(height: 24.0),

        // 5. MY DAY
        SmritiSectionHeader(
          title: AppStrings.get('myDayTitle', locale: currentLocale),
          subtitle: AppStrings.get('myDaySubtitle', locale: currentLocale),
          icon: Icons.schedule_rounded,
        ),
        const SizedBox(height: 10.0),
        SmritiActionCard(
          title: AppStrings.get('todaysRoutineCardTitle', locale: currentLocale),
          subtitle: AppStrings.get('todaysRoutineCardSubtitle', locale: currentLocale),
          icon: Icons.fact_check_rounded,
          iconColor: primaryColor,
          iconBackgroundColor: iconBg,
          onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(3);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RemindersScreen()),
              );
            }
          },
        ),
        const SizedBox(height: 12.0),
        SmritiActionCard(
          title: AppStrings.get('scheduledRemindersCardTitle', locale: currentLocale),
          subtitle: AppStrings.get('scheduledRemindersCardSubtitle', locale: currentLocale),
          icon: Icons.notifications_active_rounded,
          iconColor: warmPeach,
          iconBackgroundColor: iconBg,
          onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(3);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RemindersScreen()),
              );
            }
          },
        ),

        const SizedBox(height: 24.0),

        // 6. PROGRESS
        SmritiSectionHeader(
          title: AppStrings.get('progressSectionTitle', locale: currentLocale),
          subtitle: AppStrings.get('progressSectionSubtitle', locale: currentLocale),
          icon: Icons.insights_rounded,
        ),
        const SizedBox(height: 10.0),
        SmritiActionCard(
          title: AppStrings.get('activityPerformanceTitle', locale: currentLocale),
          subtitle: AppStrings.get('progressSubtitle', locale: currentLocale),
          icon: Icons.show_chart_rounded,
          iconColor: primaryColor,
          iconBackgroundColor: iconBg,
          onTap: () {
            if (onNavigateTab != null) {
              onNavigateTab!(4);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            }
          },
        ),

        const SizedBox(height: 24.0),

        // 7. SYNC TRANSPARENCY BANNER
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_done_outlined,
                color: primaryColor,
                size: 22.0,
              ),
              const SizedBox(width: 10.0),
              Text(
                AppStrings.get('synced', locale: currentLocale),
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20.0),
      ],
    );

    if (isEmbeddedInShell) {
      return SafeArea(child: content);
    }

    // Standalone fallback
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        title: Text(
          AppStrings.get('appName', locale: currentLocale),
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          SmritiIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: AppStrings.get('profileTooltip', locale: currentLocale),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          SmritiIconButton(
            icon: Icons.settings_outlined,
            tooltip: AppStrings.get('settingsTooltip', locale: currentLocale),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(child: content),
    );
  }
}
