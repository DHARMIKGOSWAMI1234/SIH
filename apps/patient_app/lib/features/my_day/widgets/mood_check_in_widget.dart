import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_card.dart';
import '../models/mood_check_in_model.dart';

/// Interactive Mood Check-In Widget.
///
/// State: FULLY WORKING
/// Complies with:
/// - Minimum 56dp touch targets
/// - High contrast colors
/// - Immediate gentle feedback
/// - Explicit non-clinical disclaimer
class MoodCheckInWidget extends StatefulWidget {
  final ValueChanged<MoodCheckIn>? onCheckInSaved;
  final MoodCheckIn? initialCheckIn;
  final MoodCheckInStorage? storage;

  const MoodCheckInWidget({
    super.key,
    this.onCheckInSaved,
    this.initialCheckIn,
    this.storage,
  });

  @override
  State<MoodCheckInWidget> createState() => _MoodCheckInWidgetState();
}

class _MoodCheckInWidgetState extends State<MoodCheckInWidget> {
  MoodType? _selectedMood;
  bool _isSaved = false;
  late final MoodCheckInStorage _storage;

  @override
  void initState() {
    super.initState();
    _storage = widget.storage ?? MoodCheckInStorage();
    if (widget.initialCheckIn != null) {
      _selectedMood = widget.initialCheckIn!.mood;
      _isSaved = true;
    }
  }

  Future<void> _recordMood(MoodType mood) async {
    setState(() {
      _selectedMood = mood;
      _isSaved = true;
    });

    final checkIn = MoodCheckIn(
      id: 'mood_${DateTime.now().millisecondsSinceEpoch}',
      mood: mood,
      timestamp: DateTime.now(),
    );

    widget.onCheckInSaved?.call(checkIn);
    await _storage.saveCheckIn(checkIn);

    if (mounted) {
      try {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Thank you! Recorded as feeling ${mood.label.toLowerCase()}.'),
            backgroundColor: AppColors.primaryGreen,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } catch (_) {
        // Ignored if no Scaffold ancestor is mounted
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wb_sunny_rounded, color: AppColors.primaryGreen, size: 24.0),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling today?',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Gentle daily reflection',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isSaved && _selectedMood != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_selectedMood!.emoji, style: const TextStyle(fontSize: 16.0)),
                      const SizedBox(width: 4.0),
                      Text(
                        _selectedMood!.label,
                        style: const TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),

          // 4 Large Mood Options (56dp+ height)
          Row(
            children: MoodType.values.map((type) {
              final isSelected = _selectedMood == type;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Semantics(
                    button: true,
                    label: '${type.label} mood',
                    selected: isSelected,
                    child: InkWell(
                      onTap: () => _recordMood(type),
                      borderRadius: BorderRadius.circular(14.0),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        constraints: const BoxConstraints(minHeight: 64.0),
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withValues(alpha: isDark ? 0.35 : 0.18)
                              : (isDark ? AppColors.darkSurface : AppColors.lightBackground),
                          borderRadius: BorderRadius.circular(14.0),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : (isDark ? AppColors.darkDivider : AppColors.lightDivider),
                            width: isSelected ? 2.5 : 1.0,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              type.emoji,
                              style: const TextStyle(fontSize: 28.0),
                            ),
                            const SizedBox(height: 4.0),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                type.label,
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12.0),

          // Explicit Non-Clinical Disclaimer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface.withValues(alpha: 0.5) : AppColors.warmCream.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 14.0, color: AppColors.warmGrey),
                const SizedBox(width: 6.0),
                Expanded(
                  child: Text(
                    'Self-reported check-in only. Not a medical evaluation.',
                    style: TextStyle(
                      fontSize: 11.0,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
