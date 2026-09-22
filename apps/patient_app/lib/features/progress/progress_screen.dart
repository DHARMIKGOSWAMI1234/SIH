import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/smriti_theme.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../core/widgets/smriti_progress_card.dart';
import '../../core/widgets/smriti_empty_state.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/repositories/smriti_repository.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';

/// Progress Screen: Displays real local SQLite session history and non-clinical engagement trends.
/// Strictly non-diagnostic, non-medical, and designed for elderly readability.
class ProgressScreen extends StatefulWidget {
  final bool isEmbedded;

  const ProgressScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  List<GameSession> _dbSessions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final repository = Provider.of<SmritiRepository>(context, listen: false);
      final sessions = await repository.getRecentSessions(limit: 15);
      if (mounted) {
        setState(() {
          _dbSessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = _getLocale(context);
    final totalCompleted = _dbSessions.length;
    final playedDates = _dbSessions
        .map((s) => DateTime(s.completedAt.year, s.completedAt.month, s.completedAt.day))
        .toSet();
    final activeDays = playedDates.length;

    final now = DateTime.now();
    final pastWeekDays = List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return DateTime(day.year, day.month, day.day);
    });

    final content = RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          SmritiSectionHeader(
            title: AppStrings.get('activityPerformanceTitle', locale: loc),
          subtitle: AppStrings.get('progressSubtitle', locale: loc),
          icon: Icons.insights_rounded,
        ),
        const SizedBox(height: 12.0),

        // 1. Top KPI Summary Grid
        Row(
          children: [
            Expanded(
              child: SmritiProgressCard(
                label: AppStrings.get('activeStreak', locale: loc),
                value: '$activeDays ${activeDays == 1 ? "Day" : "Days"}',
                icon: Icons.local_fire_department_rounded,
                color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                subtitle: AppStrings.get('daysConsistent', locale: loc),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: SmritiProgressCard(
                label: AppStrings.get('completedActivities', locale: loc),
                value: '$totalCompleted',
                icon: Icons.check_circle_rounded,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                subtitle: AppStrings.get('completed', locale: loc),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12.0),

        // 2. Weekly Engagement Trend
        SmritiCard(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  Text(
                    AppStrings.get('recentEngagement', locale: loc),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Text(
                    AppStrings.get('past7Days', locale: loc),
                    style: TextStyle(
                      fontSize: 14.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: pastWeekDays.map((day) {
                  final dayLabel = DateFormat('E').format(day);
                  final isDone = playedDates.contains(day);
                  return Expanded(
                    child: Center(
                      child: _buildDayPill(dayLabel, isCompleted: isDone, isDark: isDark),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20.0),

        // 3. Caregiver Transparency Notice
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
                    size: 26.0,
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      AppStrings.get('caregiverNoteTitle', locale: loc),
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10.0),
              Text(
                AppStrings.get('caregiverNoteDesc', locale: loc),
                style: TextStyle(
                  fontSize: 16.0,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24.0),

        // 4. Recent Completed Activities Log
        SmritiSectionHeader(
          title: AppStrings.get('recentCompletedActivities', locale: loc),
          subtitle: AppStrings.get('savedOffline', locale: loc),
          icon: Icons.history_rounded,
        ),
        const SizedBox(height: 8.0),

        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_dbSessions.isNotEmpty) ...[
          ..._dbSessions.map((session) {
            final dateStr = DateFormat('MMM dd, hh:mm a').format(session.completedAt);
            final accuracyPct = (session.accuracy * 100).round();
            final diffLabel = _getDiffName(session.difficulty);

            final String gameName;
            final IconData icon;
            if (session.gameType == 'routine_recall') {
              gameName = AppStrings.get('routineRecall', locale: loc);
              icon = Icons.checklist_rounded;
            } else if (session.gameType == 'pattern_recognition') {
              gameName = AppStrings.get('patternGame', locale: loc);
              icon = Icons.pattern_rounded;
            } else {
              gameName = AppStrings.get('memoryGame', locale: loc);
              icon = Icons.extension_rounded;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: _buildActivityRow(
                title: '$gameName ($diffLabel)',
                date: dateStr,
                accuracy: '$accuracyPct% ${AppStrings.get('accuracy', locale: loc)}',
                icon: icon,
                isDark: isDark,
              ),
            );
          }),
        ] else
          SmritiEmptyState(
            icon: Icons.history_rounded,
            title: AppStrings.get('recentCompletedActivities', locale: loc),
            message: AppStrings.get('savedOffline', locale: loc),
          ),
      ],
    ),
  );

    if (widget.isEmbedded) {
      return SafeArea(child: content);
    }

    return SmritiScaffold(
      title: AppStrings.get('progressTitle', locale: loc),
      actions: [
        IconButton(
          icon: Icon(
            Icons.refresh_rounded,
            color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
          ),
          tooltip: AppStrings.get('refreshHistory', locale: loc),
          onPressed: _loadHistory,
        ),
      ],
      body: content,
    );
  }

  Widget _buildDayPill(String day, {required bool isCompleted, required bool isDark}) {
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final inactiveColor = isDark ? AppColors.darkSoftBlue : AppColors.lightBorder;

    return Column(
      children: [
        Container(
          width: 32.0,
          height: 32.0,
          decoration: BoxDecoration(
            color: isCompleted ? activeColor : inactiveColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              isCompleted ? Icons.check_rounded : Icons.remove_rounded,
              size: 18.0,
              color: isCompleted
                  ? (isDark ? AppColors.darkBackground : Colors.white)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
        ),
        const SizedBox(height: 6.0),
        Text(
          day,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  String _getDiffName(int level) {
    switch (level) {
      case 1:
        return 'Easy';
      case 2:
        return 'Medium';
      case 3:
        return 'Hard';
      default:
        return 'Level $level';
    }
  }

  static Widget _buildActivityRow({
    required String title,
    required String date,
    required String accuracy,
    required IconData icon,
    required bool isDark,
  }) {
    return SmritiCard(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
            size: 30.0,
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
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2.0),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            accuracy,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkSoftGold : AppColors.lightHighlight,
            ),
          ),
        ],
      ),
    );
  }
}
