import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../core/widgets/smriti_primary_button.dart';
import '../../../../core/widgets/smriti_secondary_button.dart';
import '../../../../core/widgets/smriti_progress_card.dart';
import '../../../../core/widgets/smriti_bottom_action_bar.dart';
import '../../../../core/widgets/smriti_app_shell.dart';
import '../../../../data/local/repositories/smriti_repository.dart';
import '../../../../l10n/app_strings.dart';
import '../../adaptive/client_adaptive_engine.dart';
import '../models/routine_recall_state.dart';
import 'routine_recall_game_screen.dart';

/// Calm, encouraging results screen for Daily Routine Recall with local Drift SQLite persistence.
class RoutineRecallResultScreen extends StatefulWidget {
  final RoutineRecallMetrics metrics;

  const RoutineRecallResultScreen({
    super.key,
    required this.metrics,
  });

  @override
  State<RoutineRecallResultScreen> createState() =>
      _RoutineRecallResultScreenState();
}

class _RoutineRecallResultScreenState extends State<RoutineRecallResultScreen> {
  late AdaptiveEvaluationResult _adaptiveResult;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _evaluateAndPersist();
  }

  void _evaluateAndPersist() {
    // 1. Evaluate with deterministic client adaptive engine
    _adaptiveResult = ClientAdaptiveEngine.evaluate(
      currentDifficulty: widget.metrics.difficulty.levelNumber,
      accuracy: widget.metrics.accuracy,
      mistakes: widget.metrics.mistakes,
      hintsUsed: widget.metrics.hintCount,
      responseTimeMs: widget.metrics.responseTimeMs,
      completed: true,
    );

    // 2. Persist locally to Drift SQLite via SmritiRepository
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final repository =
            Provider.of<SmritiRepository>(context, listen: false);
        await repository.recordGameSession(
          gameType: 'routine_recall',
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
        // Safe fallback in isolated widget tests without Provider
        debugPrint('Routine recall session save notice: $e');
      }
    });
  }

  RoutineRecallDifficulty _getNextDifficulty() {
    switch (_adaptiveResult.nextDifficulty) {
      case 1:
        return RoutineRecallDifficulty.easy;
      case 2:
        return RoutineRecallDifficulty.medium;
      case 3:
      default:
        return RoutineRecallDifficulty.hard;
    }
  }

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '${m}m ${s}s';
    }
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final nextDiff = _getNextDifficulty();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: 'Exercise Completed',
      showBackButton: false,
      bottomNavigationBar: SmritiBottomActionBar(
        children: [
          SmritiPrimaryButton(
            label: 'Play Again',
            icon: Icons.replay_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => RoutineRecallGameScreen(difficulty: nextDiff),
                ),
              );
            },
          ),
          const SizedBox(height: 10.0),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 360) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SmritiSecondaryButton(
                      label: 'Back to Games',
                      icon: Icons.psychology_rounded,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SmritiAppShell(initialIndex: 1),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8.0),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.home_rounded, size: 22.0),
                      label: const Text(
                        'Back Home',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        foregroundColor: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                        side: BorderSide(
                          color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SmritiAppShell(initialIndex: 0),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: SmritiSecondaryButton(
                      label: 'Back to Games',
                      icon: Icons.psychology_rounded,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SmritiAppShell(initialIndex: 1),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.home_rounded, size: 22.0),
                      label: const FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'Back Home',
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        foregroundColor: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                        side: BorderSide(
                          color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const SmritiAppShell(initialIndex: 0),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // 1. CALM CELEBRATION HEADER
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: isDark ? SmritiTheme.darkSurfaceCard : SmritiTheme.sageLight,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: isDark
                    ? SmritiTheme.sageAccentDark.withValues(alpha: 0.3)
                    : SmritiTheme.restorativeSage.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: (isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage)
                        .withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                    size: 52.0,
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  AppStrings.get('greatWork'),
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Well Done! ${AppStrings.get('routineCompleted')}',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isSaved ? Icons.check_circle_rounded : Icons.cloud_done_rounded,
                      color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                      size: 20.0,
                    ),
                    const SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        _isSaved ? 'Saved to Local Activity History' : 'Saving to SQLite...',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
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

          // 2. METRICS GRID (Accuracy, Score, Time, Hints)
          Row(
            children: [
              Expanded(
                child: SmritiProgressCard(
                  label: AppStrings.get('accuracy'),
                  value: '${widget.metrics.accuracyPercentage}%',
                  icon: Icons.track_changes_rounded,
                  color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: SmritiProgressCard(
                  label: 'Score',
                  value: '${widget.metrics.score}',
                  icon: Icons.military_tech_rounded,
                  color: const Color(0xFFD97706),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Expanded(
                child: SmritiProgressCard(
                  label: 'Time',
                  value: _formatDuration(widget.metrics.durationSeconds),
                  icon: Icons.timer_outlined,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: SmritiProgressCard(
                  label: AppStrings.get('hints'),
                  value: '${widget.metrics.hintCount}',
                  icon: Icons.lightbulb_outline_rounded,
                  color: const Color(0xFF9333EA),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20.0),

          // 3. NEXT ACTIVITY SUGGESTION & COMFORT ADJUSTMENT REASSURANCE
          SmritiCard(
            backgroundColor: isDark ? SmritiTheme.darkSurface : Colors.white,
            borderColor: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: [
                    Text(
                      'Next Activity Suggestion',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: isDark ? SmritiTheme.darkSurfaceCard : SmritiTheme.sageLight,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        'Caregiver Activity Record',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Icon(
                      Icons.favorite_rounded,
                      color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                      size: 28.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        'Your next activity will be adjusted to a comfortable level.',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
