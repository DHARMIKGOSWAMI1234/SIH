import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_game_card.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';
import 'models/game_model.dart';
import 'memory_match/screens/memory_match_intro_screen.dart';
import 'pattern_recognition/screens/pattern_recognition_intro_screen.dart';
import 'daily_routine_recall/screens/routine_recall_intro_screen.dart';

/// Cognitive Games Screen: Unified presentation of Memory Match, Pattern Recognition, and Routine Recall.
class GamesScreen extends StatefulWidget {
  final bool isEmbedded;
  final String? currentLocale;

  const GamesScreen({
    super.key,
    this.isEmbedded = false,
    this.currentLocale,
  });

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  final int _currentDifficulty = 1;

  final List<CognitiveGameType> _availableGames = const [
    CognitiveGameType.memoryMatch,
    CognitiveGameType.patternRecognition,
    CognitiveGameType.dailyRoutineRecall,
  ];

  String _getLocale(BuildContext context) {
    if (widget.currentLocale != null) return widget.currentLocale!;
    try {
      final notifier = context.watch<LocaleNotifier?>();
      if (notifier != null) return notifier.currentLocale;
    } catch (_) {}
    return 'en';
  }

  void _launchGameSession(CognitiveGameType gameType, String loc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.darkCard
          : AppColors.lightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _getGameTitle(gameType, loc),
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                _getGameDescription(gameType, loc),
                style: TextStyle(
                  fontSize: 18.0,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
              const SizedBox(height: 20.0),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14.0),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                      size: 28.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        '${AppStrings.get('gentleDifficultyPrefix', locale: loc)}: $_currentDifficulty of 5\n${AppStrings.get('gentleDifficultySuffix', locale: loc)}',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),
              SmritiPrimaryButton(
                label: AppStrings.get('beginExercise', locale: loc),
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  if (gameType == CognitiveGameType.memoryMatch) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const MemoryMatchIntroScreen(),
                      ),
                    );
                  } else if (gameType == CognitiveGameType.patternRecognition) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PatternRecognitionIntroScreen(),
                      ),
                    );
                  } else if (gameType == CognitiveGameType.dailyRoutineRecall) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RoutineRecallIntroScreen(),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = _getLocale(context);

    final list = ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        SmritiSectionHeader(
          title: AppStrings.get('cognitiveExercises', locale: loc),
          subtitle: AppStrings.get('cognitiveExercisesSubtitle', locale: loc),
          icon: Icons.psychology_rounded,
        ),
        const SizedBox(height: 12.0),
        ..._availableGames.map((game) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SmritiGameCard(
              title: _getGameTitle(game, loc),
              description: _getGameDescription(game, loc),
              icon: _getGameIcon(game),
              category: _getGameCategory(game, loc),
              difficultyLevel: _currentDifficulty,
              onTap: () => _launchGameSession(game, loc),
            ),
          );
        }),
      ],
    );

    if (widget.isEmbedded) {
      return SafeArea(child: list);
    }

    return SmritiScaffold(
      title: AppStrings.get('cognitiveExercises', locale: loc),
      body: list,
    );
  }

  String _getGameTitle(CognitiveGameType gameType, String loc) {
    switch (gameType) {
      case CognitiveGameType.memoryMatch:
        return AppStrings.get('memoryGame', locale: loc);
      case CognitiveGameType.patternRecognition:
        return AppStrings.get('patternGame', locale: loc);
      case CognitiveGameType.dailyRoutineRecall:
        return AppStrings.get('routineRecall', locale: loc);
    }
  }

  String _getGameDescription(CognitiveGameType gameType, String loc) {
    switch (gameType) {
      case CognitiveGameType.memoryMatch:
        return AppStrings.get('memoryGameDesc', locale: loc);
      case CognitiveGameType.patternRecognition:
        return AppStrings.get('patternGameDesc', locale: loc);
      case CognitiveGameType.dailyRoutineRecall:
        return AppStrings.get('routineRecallDesc', locale: loc);
    }
  }

  IconData _getGameIcon(CognitiveGameType gameType) {
    switch (gameType) {
      case CognitiveGameType.memoryMatch:
        return Icons.extension_rounded;
      case CognitiveGameType.patternRecognition:
        return Icons.pattern_rounded;
      case CognitiveGameType.dailyRoutineRecall:
        return Icons.checklist_rounded;
    }
  }

  String _getGameCategory(CognitiveGameType gameType, String loc) {
    switch (gameType) {
      case CognitiveGameType.memoryMatch:
        return AppStrings.get('catVisualRecall', locale: loc);
      case CognitiveGameType.patternRecognition:
        return AppStrings.get('catLogicalPatterns', locale: loc);
      case CognitiveGameType.dailyRoutineRecall:
        return AppStrings.get('catRoutineSteps', locale: loc);
    }
  }
}
