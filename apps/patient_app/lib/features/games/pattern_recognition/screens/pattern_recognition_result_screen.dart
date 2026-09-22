import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../core/widgets/smriti_primary_button.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_secondary_button.dart';
import '../../../../data/local/repositories/smriti_repository.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../l10n/locale_notifier.dart';
import '../../adaptive/client_adaptive_engine.dart';
import '../models/pattern_recognition_state.dart';
import 'pattern_recognition_intro_screen.dart';

/// Patient-facing completion screen for Pattern Recognition.
class PatternRecognitionResultScreen extends StatefulWidget {
  final PatternDifficulty difficulty;
  final int correctAnswers;
  final int totalQuestions;
  final int mistakes;
  final int hintsUsed;
  final int avgResponseTimeMs;
  final DateTime startedAt;
  final DateTime completedAt;
  final int score;

  PatternRecognitionResultScreen({
    super.key,
    PatternRecognitionMetrics? metrics,
    PatternDifficulty? difficulty,
    int? correctAnswers,
    int? totalQuestions,
    int? mistakes,
    int? hintsUsed,
    int? avgResponseTimeMs,
    DateTime? startedAt,
    DateTime? completedAt,
    int? score,
  })  : difficulty = difficulty ?? metrics?.difficulty ?? PatternDifficulty.easy,
        correctAnswers = correctAnswers ?? metrics?.correctAnswers ?? 0,
        totalQuestions = totalQuestions ?? metrics?.totalQuestions ?? 0,
        mistakes = mistakes ?? metrics?.mistakes ?? 0,
        hintsUsed = hintsUsed ?? metrics?.hintCount ?? 0,
        avgResponseTimeMs = avgResponseTimeMs ?? (metrics?.averageResponseTimeMs ?? 0.0).round(),
        startedAt = startedAt ?? metrics?.startedAt ?? DateTime.now(),
        completedAt = completedAt ?? metrics?.completedAt ?? DateTime.now(),
        score = score ?? metrics?.score ?? 0;

  PatternRecognitionMetrics get metrics => PatternRecognitionMetrics(
        difficulty: difficulty,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        mistakes: mistakes,
        hintCount: hintsUsed,
        accuracy: totalQuestions > 0 ? (correctAnswers / totalQuestions).clamp(0.0, 1.0) : 1.0,
        score: score,
        startedAt: startedAt,
        completedAt: completedAt,
        averageResponseTimeMs: avgResponseTimeMs.toDouble(),
      );

  @override
  State<PatternRecognitionResultScreen> createState() =>
      _PatternRecognitionResultScreenState();
}

class _PatternRecognitionResultScreenState
    extends State<PatternRecognitionResultScreen> {
  late AdaptiveEvaluationResult _adaptiveResult;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _adaptiveResult = ClientAdaptiveEngine.evaluate(
      currentDifficulty: widget.difficulty.levelNumber,
      accuracy: widget.metrics.accuracy,
      mistakes: widget.mistakes,
      hintsUsed: widget.hintsUsed,
      responseTimeMs: widget.avgResponseTimeMs.toDouble(),
      completed: true,
    );
    _saveSession();
  }

  Future<void> _saveSession() async {
    try {
      final repository =
          Provider.of<SmritiRepository>(context, listen: false);
      await repository.recordGameSession(
        gameType: 'pattern_recognition',
        score: widget.score,
        accuracy: widget.metrics.accuracy,
        mistakes: widget.mistakes,
        responseTimeMs: widget.avgResponseTimeMs.toDouble(),
        difficulty: widget.difficulty.levelNumber,
        hintCount: widget.hintsUsed,
        startedAt: widget.startedAt,
        completedAt: widget.completedAt,
      );
      if (mounted) {
        setState(() => _isSaved = true);
      }
    } catch (e) {
      debugPrint('[PatternRecognition] Error saving session: $e');
    }
  }

  PatternDifficulty _getNextDifficulty() {
    switch (_adaptiveResult.nextDifficulty) {
      case 1:
        return PatternDifficulty.easy;
      case 2:
        return PatternDifficulty.medium;
      case 3:
      default:
        return PatternDifficulty.hard;
    }
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
    final loc = _getLocale(context);
    final nextDiff = _getNextDifficulty();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: AppStrings.get('exerciseCompleted', locale: loc),
      showBackButton: false,
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Section 1: Calm Celebration Header
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
            child: Column(
              children: [
                Icon(
                  Icons.stars_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: 64.0,
                ),
                const SizedBox(height: 12.0),
                Text(
                  AppStrings.get('greatWork', locale: loc),
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  AppStrings.get('patternCompleted', locale: loc),
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSaved
                          ? Icons.check_circle_rounded
                          : Icons.cloud_done_rounded,
                      color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen,
                      size: 20.0,
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        _isSaved
                            ? AppStrings.get('savedToHistory', locale: loc)
                            : AppStrings.get('savingToSqlite', locale: loc),
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Section 2: Metrics Summary Grid
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  label: AppStrings.get('accuracy', locale: loc),
                  value: '${widget.metrics.accuracyPercentage}%',
                  icon: Icons.track_changes_rounded,
                  color: isDark ? AppColors.darkSoftGold : AppColors.lightHighlight,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: _buildMetricCard(
                  label: AppStrings.get('score', locale: loc),
                  value: '${widget.score}',
                  icon: Icons.emoji_events_rounded,
                  color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          _buildWideMetricCard(
            label: AppStrings.get('correctAnswers', locale: loc),
            value: '${widget.correctAnswers} / ${widget.totalQuestions}',
            icon: Icons.check_circle_outline_rounded,
            color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen,
            isDark: isDark,
          ),
          const SizedBox(height: 12.0),

          _buildWideMetricCard(
            label: AppStrings.get('hintsUsed', locale: loc),
            value: '${widget.hintsUsed}',
            icon: Icons.lightbulb_outline_rounded,
            color: isDark ? AppColors.darkSoftGold : const Color(0xFFD97706),
            isDark: isDark,
          ),
          const SizedBox(height: 20.0),

          // Section 3: Adaptive Recommendation Card
          SmritiCard(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.tune_rounded,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      size: 24.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'Next Activity Suggestion',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Text(
                  _adaptiveResult.patientFeedback,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightWarmAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${AppStrings.get('recommendedLevel', locale: loc)}: ',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        nextDiff.displayName,
                        style: TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // Section 4: Caregiver Transparency Note
          SmritiCard(
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightWarmAccent.withValues(alpha: 0.1),
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightWarmAccent.withValues(alpha: 0.4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                      size: 22.0,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        AppStrings.get('caregiverRecord', locale: loc),
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  _adaptiveResult.caregiverExplanation,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24.0),

          // Section 5: Navigation Actions
          SmritiPrimaryButton(
            label: '${AppStrings.get('playAgain', locale: loc)} (${nextDiff.displayName})',
            icon: Icons.replay_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => PatternRecognitionIntroScreen(
                    initialDifficulty: nextDiff,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),
          SmritiSecondaryButton(
            label: AppStrings.get('backToGames', locale: loc),
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12.0),
          Center(
            child: TextButton(
              child: Text(
                AppStrings.get('returnToHome', locale: loc),
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              ),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return SmritiCard(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Icon(icon, size: 30.0, color: color),
          const SizedBox(height: 8.0),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.0,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideMetricCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return SmritiCard(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(icon, size: 26.0, color: color),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
