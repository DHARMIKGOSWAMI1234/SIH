import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../core/widgets/smriti_primary_button.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../../help/models/help_screen_id.dart';
import '../models/cultural_memory_item.dart';

/// "Familiar World" Screen: Culturally familiar object and tradition recognition for the NER.
///
/// Features large touch targets, comforting feedback, authentic NER demo content,
/// and local session recording.
class FamiliarWorldScreen extends StatefulWidget {
  const FamiliarWorldScreen({super.key});

  @override
  State<FamiliarWorldScreen> createState() => _FamiliarWorldScreenState();
}

class _FamiliarWorldScreenState extends State<FamiliarWorldScreen> {
  final List<CulturalMemoryItem> _items = CulturalMemoryItem.demoItems;
  int _currentIndex = 0;
  String? _selectedOption;
  bool _hasAnswered = false;
  bool _isCorrect = false;
  int _score = 0;
  late DateTime _startedAt;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
  }

  void _chooseOption(String option) {
    if (_hasAnswered) return;
    final item = _items[_currentIndex];
    final correct = option == item.correctAnswer;
    setState(() {
      _selectedOption = option;
      _hasAnswered = true;
      _isCorrect = correct;
      if (correct) _score++;
    });
  }

  void _nextItem() {
    if (_currentIndex < _items.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _hasAnswered = false;
        _isCorrect = false;
      });
    } else {
      _finishActivity();
    }
  }

  Future<void> _finishActivity() async {
    final repo = context.read<SmritiRepository?>();
    if (repo != null) {
      try {
        await repo.recordGameSession(
          gameType: 'cultural_familiar_world',
          score: _score * 10,
          accuracy: _items.isNotEmpty ? (_score / _items.length) : 1.0,
          mistakes: _items.length - _score,
          responseTimeMs: 3000.0,
          difficulty: 1,
          hintCount: 0,
          startedAt: _startedAt,
          completedAt: DateTime.now(),
        );
      } catch (_) {}
    }

    if (!mounted) return;
    _showSummaryDialog();
  }

  void _showSummaryDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.successGreen, size: 30.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                'Wonderful Exploration!',
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You explored ${_items.length} cherished cultural items and traditions.',
              style: TextStyle(
                fontSize: 17.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                'All activities are saved privately on your device.',
                style: TextStyle(
                  fontSize: 14.0,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          SmritiPrimaryButton(
            label: 'Back to Memories',
            icon: Icons.check_rounded,
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final item = _items[_currentIndex];

    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderCol = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return SmritiScaffold(
      title: 'Familiar World',
      helpScreenId: HelpScreenId.familiarWorld,
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Header badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.public_rounded, size: 18.0, color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
                    const SizedBox(width: 6.0),
                    Text(
                      '${item.region} • ${item.category}',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                'Item ${_currentIndex + 1} of ${_items.length}',
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.w600,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Cultural Card
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(color: borderCol, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 100.0,
                    height: 100.0,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getCategoryIcon(item.category),
                      size: 54.0,
                      color: isDark ? AppColors.darkWarmPeach : AppColors.lightWarmAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 18.0),
                Center(
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  item.prompt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18.0,
                    height: 1.4,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Options List
          ...item.answerOptions.map((opt) {
            final isSelected = _selectedOption == opt;
            final isCorrectAnswer = opt == item.correctAnswer;

            Color tileBg = cardBg;
            Color tileBorder = borderCol;
            Color optionColor = textPrimary;

            if (_hasAnswered) {
              if (isCorrectAnswer) {
                tileBg = isDark ? const Color(0xFF1E3A2E) : const Color(0xFFE8F5E9);
                tileBorder = AppColors.successGreen;
                optionColor = AppColors.successGreen;
              } else if (isSelected) {
                tileBg = isDark ? const Color(0xFF3E2723) : const Color(0xFFFFEBEE);
                tileBorder = AppColors.errorRed;
                optionColor = AppColors.errorRed;
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Semantics(
                button: true,
                label: opt,
                child: InkWell(
                  onTap: _hasAnswered ? null : () => _chooseOption(opt),
                  borderRadius: BorderRadius.circular(16.0),
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 56.0),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    decoration: BoxDecoration(
                      color: tileBg,
                      borderRadius: BorderRadius.circular(16.0),
                      border: Border.all(color: tileBorder, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _hasAnswered && isCorrectAnswer
                              ? Icons.check_circle_rounded
                              : (_hasAnswered && isSelected
                                  ? Icons.cancel_rounded
                                  : Icons.radio_button_unchecked_rounded),
                          color: optionColor,
                          size: 26.0,
                        ),
                        const SizedBox(width: 14.0),
                        Expanded(
                          child: Text(
                            opt,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w600,
                              color: optionColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Reassurance & Next Action
          if (_hasAnswered) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? (isDark ? const Color(0xFF1E3A2E) : const Color(0xFFE8F5E9))
                    : (isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15)),
                borderRadius: BorderRadius.circular(14.0),
              ),
              child: Text(
                _isCorrect
                    ? 'Wonderful! ${item.description}'
                    : 'A lovely guess! This is indeed ${item.title}. ${item.description}',
                style: TextStyle(
                  fontSize: 16.0,
                  height: 1.4,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            SmritiPrimaryButton(
              label: _currentIndex < _items.length - 1 ? 'Next Tradition' : 'Finish Activity',
              icon: Icons.arrow_forward_rounded,
              onPressed: _nextItem,
            ),
          ],

          const SizedBox(height: 20.0),
          Center(
            child: Text(
              'Curated sample items for demo exploration',
              style: TextStyle(fontSize: 13.0, color: textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Festivals':
        return Icons.celebration_rounded;
      case 'Clothing':
        return Icons.checkroom_rounded;
      case 'Places':
        return Icons.landscape_rounded;
      case 'Music':
        return Icons.music_note_rounded;
      case 'Household Objects':
        return Icons.home_repair_service_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }
}
