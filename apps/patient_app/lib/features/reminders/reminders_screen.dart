import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';
import '../help/models/help_screen_id.dart';

class ReminderItemData {
  final String title;
  final String time;
  final String type;
  bool isCompleted;

  ReminderItemData({
    required this.title,
    required this.time,
    required this.type,
    this.isCompleted = false,
  });
}

/// Reminders Screen: High-contrast, large-button reminder list for routine, hydration, rest, and activity.
class RemindersScreen extends StatefulWidget {
  final bool isEmbedded;

  const RemindersScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  final List<ReminderItemData> _reminders = [
    ReminderItemData(title: 'Scheduled Morning Routine', time: '08:00 AM', type: 'Routine'),
    ReminderItemData(title: 'Hydration Reminder: Glass of Water', time: '11:00 AM', type: 'Hydration'),
    ReminderItemData(title: 'Quiet Rest & Relaxation', time: '02:00 PM', type: 'Rest'),
    ReminderItemData(title: 'Gentle Evening Walk', time: '05:30 PM', type: 'Activity'),
  ];

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

    final content = ListView(
      padding: const EdgeInsets.all(20.0),
      children: [
        SmritiSectionHeader(
          title: AppStrings.get('todaysGentleReminders', locale: loc),
          subtitle: AppStrings.get('todaysGentleRemindersSubtitle', locale: loc),
          icon: Icons.notifications_active_rounded,
        ),
        const SizedBox(height: 12.0),
        ..._reminders.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: SmritiCard(
              backgroundColor: item.isCompleted
                  ? (isDark ? const Color(0xFF1E2E2A) : const Color(0xFFF2F6F3))
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderColor: item.isCompleted
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightSage)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              child: Row(
                children: [
                  IconButton(
                    iconSize: 44.0,
                    icon: Icon(
                      item.isCompleted ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      color: item.isCompleted
                          ? (isDark ? AppColors.darkPrimary : AppColors.lightSage)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                    tooltip: item.isCompleted
                        ? AppStrings.get('completed', locale: loc)
                        : AppStrings.get('markDone', locale: loc),
                    onPressed: () {
                      setState(() {
                        _reminders[idx].isCompleted = !_reminders[idx].isCompleted;
                      });
                    },
                  ),
                  const SizedBox(width: 14.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                            color: item.isCompleted
                                ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                          ),
                        ),
                        const SizedBox(height: 4.0),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 18.0,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                                const SizedBox(width: 6.0),
                                Text(
                                  item.time,
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              child: Text(
                                item.type,
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );

    if (widget.isEmbedded) {
      return SafeArea(child: content);
    }

    return SmritiScaffold(
      title: AppStrings.get('dailyReminders', locale: loc),
      helpScreenId: HelpScreenId.reminders,
      body: content,
    );
  }
}
