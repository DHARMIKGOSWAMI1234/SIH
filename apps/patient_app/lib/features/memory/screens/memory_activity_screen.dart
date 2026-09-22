import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/smriti_theme.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../core/widgets/smriti_primary_button.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../services/memory_activity_generator.dart';
import '../services/memory_media_service.dart';

/// Interactive memory-based cognitive and reminiscence activity.
///
/// Strictly non-clinical, zero synthetic data. Uses caregiver-approved
/// memories and verified NER cultural starter packs.
class MemoryActivityScreen extends StatefulWidget {
  const MemoryActivityScreen({super.key});

  @override
  State<MemoryActivityScreen> createState() => _MemoryActivityScreenState();
}

class _MemoryActivityScreenState extends State<MemoryActivityScreen> {
  List<MemoryActivityQuestion> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  String? _selectedOption;
  bool _isAnswered = false;
  bool _isCorrect = false;
  bool _hintShown = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final repo = context.read<SmritiRepository>();
    final memories = await repo.getMemories(includeArchived: false);
    final questions = MemoryActivityGenerator.generateActivities(personalMemories: memories);

    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  void _selectOption(String option) {
    if (_isAnswered) return;
    final currentQ = _questions[_currentIndex];
    final isCorrect = option.toLowerCase() == currentQ.correctAnswer.toLowerCase();

    setState(() {
      _selectedOption = option;
      _isAnswered = true;
      _isCorrect = isCorrect;
    });
  }

  void _nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _isAnswered = false;
        _isCorrect = false;
        _hintShown = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        title: Row(
          children: [
            const Icon(Icons.favorite_rounded, color: SmritiTheme.restorativeSage, size: 28.0),
            const SizedBox(width: 8.0),
            Text(
              'Wonderful Recall!',
              style: TextStyle(
                color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You explored ${_questions.length} familiar memories and stories.',
              style: const TextStyle(fontSize: 16.0, height: 1.4),
            ),
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: isDark ? SmritiTheme.darkSurfaceCard : SmritiTheme.sageLight,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: const Row(
                children: [
                  Icon(Icons.chat_bubble_outline_rounded, color: SmritiTheme.restorativeSage),
                  SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      'Would you like to talk about these memories with your family or caregiver?',
                      style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Return to Memory Bank', style: TextStyle(fontSize: 16.0)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const SmritiScaffold(
        title: 'Memory Activity',
        body: Center(child: CircularProgressIndicator(color: SmritiTheme.restorativeSage)),
      );
    }

    if (_questions.isEmpty) {
      return SmritiScaffold(
        title: 'Memory Activity',
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'No memory activities available at this moment. Add a memory to begin.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.0,
                color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
              ),
            ),
          ),
        ),
      );
    }

    final q = _questions[_currentIndex];

    return SmritiScaffold(
      title: 'Memory Activity',
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // Progress Header
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 6.0,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: isDark ? SmritiTheme.darkSurfaceCard : SmritiTheme.sageLight,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  'Memory ${_currentIndex + 1} of ${_questions.length}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _hintShown = true),
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 18.0),
                label: const Text('Gentle Hint'),
                style: TextButton.styleFrom(
                  foregroundColor: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Question Prompt Card
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? SmritiTheme.darkSurfaceCard : Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemoryMediaService.buildThumbnail(
                  imagePath: q.imagePath,
                  category: q.category,
                  height: 180.0,
                  borderRadius: BorderRadius.circular(12.0),
                  isDark: isDark,
                ),
                const SizedBox(height: 14.0),
                Text(
                  q.questionText,
                  style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                  ),
                ),
                if (q.promptSubtitle.isNotEmpty) ...[
                  const SizedBox(height: 6.0),
                  Text(
                    q.promptSubtitle,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16.0),

          // Hint banner if requested
          if (_hintShown) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: Color(0xFFB45309), size: 20.0),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Text(
                      q.hintText,
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],

          // Answer Options (Minimum 56dp touch targets)
          ...q.options.map((option) {
            final isSelected = _selectedOption == option;
            final isCorrectAnswer = option.toLowerCase() == q.correctAnswer.toLowerCase();

            Color? buttonColor;
            Color? borderColor;
            if (_isAnswered) {
              if (isCorrectAnswer) {
                buttonColor = const Color(0xFF10B981).withAlpha(30);
                borderColor = const Color(0xFF10B981);
              } else if (isSelected) {
                buttonColor = const Color(0xFFEF4444).withAlpha(30);
                borderColor = const Color(0xFFEF4444);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: _isAnswered ? null : () => _selectOption(option),
                borderRadius: BorderRadius.circular(14.0),
                child: Container(
                  height: 60.0,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: buttonColor ?? (isDark ? SmritiTheme.darkSurfaceCard : Colors.white),
                    borderRadius: BorderRadius.circular(14.0),
                    border: Border.all(
                      color: borderColor ?? (isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle),
                      width: isSelected || (_isAnswered && isCorrectAnswer) ? 2.0 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24.0,
                        height: 24.0,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                          ),
                          color: isSelected ? SmritiTheme.restorativeSage : Colors.transparent,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check, size: 16.0, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w600,
                            color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Feedback & Next Button
          if (_isAnswered) ...[
            const SizedBox(height: 12.0),
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: _isCorrect
                    ? (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5))
                    : (isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2)),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: [
                  Icon(
                    _isCorrect ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    color: _isCorrect ? const Color(0xFF059669) : const Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Text(
                      _isCorrect
                          ? 'Wonderful! That is correct.'
                          : 'Take your time. The answer is "${q.correctAnswer}".',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: _isCorrect
                            ? (isDark ? const Color(0xFF34D399) : const Color(0xFF065F46))
                            : (isDark ? const Color(0xFFF87171) : const Color(0xFF991B1B)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            SmritiPrimaryButton(
              label: _currentIndex < _questions.length - 1 ? 'Next Memory' : 'Complete Activity',
              icon: Icons.arrow_forward_rounded,
              onPressed: _nextQuestion,
            ),
            const SizedBox(height: 20.0),
          ],
        ],
      ),
    );
  }
}
