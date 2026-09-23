import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../core/widgets/smriti_card.dart';
import '../../help/models/help_screen_id.dart';
import '../models/mood_check_in_model.dart';
import '../widgets/mood_check_in_widget.dart';

class MyDayTimelineItem {
  final String id;
  final String title;
  final String time;
  final String category;
  final IconData icon;
  bool isCompleted;

  MyDayTimelineItem({
    required this.id,
    required this.title,
    required this.time,
    required this.category,
    required this.icon,
    this.isCompleted = false,
  });
}

/// "My Day": Daily Routine Companion Screen.
///
/// State: FULLY WORKING
/// Combines time-of-day greeting, interactive daily mood check-in,
/// and responsive daily routine timeline with toggleable completion states.
class MyDayScreen extends StatefulWidget {
  final bool isEmbedded;

  const MyDayScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<MyDayScreen> createState() => _MyDayScreenState();
}

class _MyDayScreenState extends State<MyDayScreen> {
  final MoodCheckInStorage _moodStorage = MoodCheckInStorage();
  MoodCheckIn? _todayCheckIn;

  final List<MyDayTimelineItem> _schedule = [
    MyDayTimelineItem(
      id: 'item_1',
      title: 'Morning Tea & Peaceful Start',
      time: '08:00 AM',
      category: 'Morning Routine',
      icon: Icons.coffee_rounded,
      isCompleted: true,
    ),
    MyDayTimelineItem(
      id: 'item_2',
      title: 'Hydration: Glass of Water',
      time: '10:00 AM',
      category: 'Hydration',
      icon: Icons.water_drop_rounded,
      isCompleted: false,
    ),
    MyDayTimelineItem(
      id: 'item_3',
      title: 'Gentle Memory Match Game',
      time: '11:30 AM',
      category: 'Cognitive Activity',
      icon: Icons.extension_rounded,
      isCompleted: false,
    ),
    MyDayTimelineItem(
      id: 'item_4',
      title: 'Afternoon Rest & Quiet Time',
      time: '02:00 PM',
      category: 'Rest',
      icon: Icons.bedtime_rounded,
      isCompleted: false,
    ),
    MyDayTimelineItem(
      id: 'item_5',
      title: 'Evening Courtyard Walk',
      time: '05:30 PM',
      category: 'Exercise',
      icon: Icons.directions_walk_rounded,
      isCompleted: false,
    ),
    MyDayTimelineItem(
      id: 'item_6',
      title: 'Nightly Reflection & Sleep',
      time: '08:30 PM',
      category: 'Night Routine',
      icon: Icons.nights_stay_rounded,
      isCompleted: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadTodayMood();
  }

  Future<void> _loadTodayMood() async {
    try {
      final checkIn = await _moodStorage.getTodayCheckIn();
      if (mounted) {
        setState(() {
          _todayCheckIn = checkIn;
        });
      }
    } catch (_) {}
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  void _toggleItem(MyDayTimelineItem item) {
    setState(() {
      item.isCompleted = !item.isCompleted;
    });

    try {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(item.isCompleted
              ? 'Marked as completed: ${item.title}'
              : 'Marked as upcoming: ${item.title}'),
          backgroundColor: item.isCompleted ? AppColors.primaryGreen : AppColors.warmGrey,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (_) {
      // Ignored if embedded without a Scaffold ancestor
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedCount = _schedule.where((i) => i.isCompleted).length;
    final totalCount = _schedule.length;
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d, y').format(now);

    final content = SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Greeting & Date Card
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.primaryGreen.withValues(alpha: 0.3),
                        AppColors.darkSurface,
                      ]
                    : [
                        AppColors.primaryGreen.withValues(alpha: 0.12),
                        AppColors.warmCream.withValues(alpha: 0.8),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getGreeting(),
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const Icon(Icons.favorite_rounded, color: AppColors.primaryGreen, size: 28.0),
                  ],
                ),
                const SizedBox(height: 4.0),
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 12.0),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        '$completedCount of $totalCount Completed',
                        style: const TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Mood Check-In Widget
          MoodCheckInWidget(
            initialCheckIn: _todayCheckIn,
            onCheckInSaved: (c) => setState(() => _todayCheckIn = c),
          ),

          const SizedBox(height: 24.0),

          // Daily Timeline Section Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s Routine Timeline',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                'Tap to toggle',
                style: TextStyle(
                  fontSize: 12.0,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Interactive Timeline Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _schedule.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10.0),
            itemBuilder: (context, index) {
              final item = _schedule[index];
              return _buildTimelineCard(item, isDark);
            },
          ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return content;
    }

    return SmritiScaffold(
      title: 'My Day',
      helpScreenId: HelpScreenId.myDay,
      body: content,
    );
  }

  Widget _buildTimelineCard(MyDayTimelineItem item, bool isDark) {
    return SmritiCard(
      onTap: () => _toggleItem(item),
      child: Row(
        children: [
          // Time badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.warmCream,
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
            ),
            child: Column(
              children: [
                Icon(item.icon, size: 20.0, color: item.isCompleted ? AppColors.primaryGreen : AppColors.warmGrey),
                const SizedBox(height: 4.0),
                Text(
                  item.time,
                  style: const TextStyle(fontSize: 11.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14.0),

          // Item details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                    color: item.isCompleted
                        ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  item.category,
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Large Touch Target Checkbox (Min 56dp hit area)
          Semantics(
            button: true,
            label: '${item.title} ${item.isCompleted ? "completed" : "not completed"}',
            child: InkWell(
              onTap: () => _toggleItem(item),
              borderRadius: BorderRadius.circular(28.0),
              child: Container(
                width: 56.0,
                height: 56.0,
                alignment: Alignment.center,
                child: Container(
                  width: 32.0,
                  height: 32.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: item.isCompleted ? AppColors.primaryGreen : Colors.transparent,
                    border: Border.all(
                      color: item.isCompleted ? AppColors.primaryGreen : AppColors.warmGrey,
                      width: 2.0,
                    ),
                  ),
                  child: item.isCompleted
                      ? const Icon(Icons.check_rounded, color: Colors.white, size: 20.0)
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
