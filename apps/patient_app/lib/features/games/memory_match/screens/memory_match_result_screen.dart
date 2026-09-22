import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../core/widgets/smriti_primary_button.dart';
import '../../../../core/widgets/smriti_secondary_button.dart';
import '../../../../data/local/repositories/smriti_repository.dart';
import '../../adaptive/client_adaptive_engine.dart';
import '../models/memory_match_state.dart';
import 'memory_match_intro_screen.dart';

/// Gentle, non-anxiety summary screen displayed after Memory Match completion.
/// Highlights cognitive engagement and saves the session to SQLite for sync.
class MemoryMatchResultScreen extends StatefulWidget {
  final MemoryMatchMetrics metrics;

  const MemoryMatchResultScreen({
    super.key,
    required this.metrics,
  });

  @override
  State<MemoryMatchResultScreen> createState() => _MemoryMatchResultScreenState();
}

class _MemoryMatchResultScreenState extends State<MemoryMatchResultScreen> {
  late final AdaptiveEvaluationResult _adaptiveResult;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _adaptiveResult = ClientAdaptiveEngine.evaluate(
      currentDifficulty: widget.metrics.difficulty.levelNumber,
      accuracy: widget.metrics.accuracy,
      mistakes: widget.metrics.mistakes,
      hintsUsed: widget.metrics.hintCount,
      responseTimeMs: widget.metrics.responseTimeMs,
      completed: true,
    );
    _saveSession();
  }

  Future<void> _saveSession() async {
    try {
      final repository = Provider.of<SmritiRepository>(context, listen: false);
      await repository.recordGameSession(
        gameType: 'memory_match',
        score: widget.metrics.score,
        accuracy: widget.metrics.accuracy,
        mistakes: widget.metrics.mistakes,
        responseTimeMs: widget.metrics.responseTimeMs,
        difficulty: widget.metrics.difficulty.levelNumber,
        hintCount: widget.metrics.hintCount,
        startedAt: widget.metrics.startedAt,
        completedAt: widget.metrics.completedAt,
      );
      if (mounted) {
        setState(() => _isSaved = true);
      }
    } catch (e) {
      debugPrint('[MemoryMatch] Error persisting session: $e');
    }
  }

  MemoryMatchDifficulty _getNextDifficulty() {
    switch (_adaptiveResult.nextDifficulty) {
      case 1:
        return MemoryMatchDifficulty.easy;
      case 2:
        return MemoryMatchDifficulty.medium;
      case 3:
      default:
        return MemoryMatchDifficulty.hard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: 'Activity Complete',
      showBackButton: false,
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Gentle Celebration Header
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
                  Icons.check_circle_rounded,
                  size: 64.0,
                  color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen,
                ),
                const SizedBox(height: 12.0),
                Text(
                  'Great Work!',
                  style: TextStyle(
                    fontSize: 28.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Memory Match completed smoothly.',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // Core Metrics Summary Card
          SmritiCard(
            child: Column(
              children: [
                _buildMetricRow(
                  icon: Icons.check_box_rounded,
                  label: 'Pairs Found',
                  value: '${widget.metrics.matchedPairs} of ${widget.metrics.totalPairs}',
                  color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen,
                  isDark: isDark,
                ),
                Divider(height: 24.0, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildMetricRow(
                  icon: Icons.percent_rounded,
                  label: 'Exercise Accuracy',
                  value: '${widget.metrics.accuracyPercentage}%',
                  color: isDark ? AppColors.darkSoftGold : AppColors.lightHighlight,
                  isDark: isDark,
                ),
                Divider(height: 24.0, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                _buildMetricRow(
                  icon: Icons.touch_app_rounded,
                  label: 'Total Flips',
                  value: '${widget.metrics.totalAttempts}',
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  isDark: isDark,
                ),
                if (widget.metrics.hintCount > 0) ...[
                  Divider(height: 24.0, color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  _buildMetricRow(
                    icon: Icons.lightbulb_outline_rounded,
                    label: 'Supportive Hints',
                    value: '${widget.metrics.hintCount}',
                    color: isDark ? AppColors.darkWarmPeach : const Color(0xFFD97706),
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20.0),

          // Adaptive Engine Recommendation Card
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
                    Text(
                      'Next Activity Suggestion',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Text(
                  _adaptiveResult.patientFeedback,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // Caregiver Transparency Summary (Non-clinical)
          SmritiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caregiver Activity Record',
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 6.0),
                Text(
                  _adaptiveResult.caregiverExplanation,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Icon(Icons.save_rounded, size: 16.0, color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        _isSaved ? 'Preserved securely in local SQLite database' : 'Saving locally...',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen,
                          fontWeight: FontWeight.w600,
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

          const SizedBox(height: 32.0),

          // Actions
          SmritiPrimaryButton(
            label: 'Play Again',
            icon: Icons.replay_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MemoryMatchIntroScreen(initialDifficulty: _getNextDifficulty()),
                ),
              );
            },
          ),
          const SizedBox(height: 12.0),
          SmritiSecondaryButton(
            label: 'Back to Games',
            icon: Icons.extension_rounded,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(height: 12.0),
          Center(
            child: TextButton(
              child: Text(
                'Return to Home',
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
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Row(
      children: [
        Icon(icon, size: 24.0, color: color),
        const SizedBox(width: 12.0),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 17.0,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 19.0, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
