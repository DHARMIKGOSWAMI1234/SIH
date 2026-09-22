import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../l10n/app_strings.dart';
import '../../../../l10n/locale_notifier.dart';
import '../models/pattern_item.dart';
import '../models/pattern_question.dart';
import '../models/pattern_recognition_state.dart';
import '../widgets/pattern_sequence_display.dart';
import '../widgets/pattern_option_button.dart';
import 'pattern_recognition_result_screen.dart';

/// Full interactive gameplay screen for Pattern Recognition.
/// Offline-first, responsive, accessible, and non-clinical.
class PatternRecognitionGameScreen extends StatefulWidget {
  final PatternDifficulty difficulty;

  const PatternRecognitionGameScreen({
    super.key,
    this.difficulty = PatternDifficulty.easy,
  });

  @override
  State<PatternRecognitionGameScreen> createState() =>
      _PatternRecognitionGameScreenState();
}

class _PatternRecognitionGameScreenState
    extends State<PatternRecognitionGameScreen> {
  late List<PatternQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _mistakeCount = 0;
  int _hintCount = 0;

  int _roundMistakes = 0;
  int _roundHints = 0;
  final List<PatternRoundRecord> _roundRecords = [];

  final Set<PatternItem> _eliminatedOptions = {};
  PatternItem? _selectedOption;
  bool _isTurnLocked = false;
  bool _isAnswerRevealed = false;
  String? _feedbackMessage;
  bool _isFeedbackCorrect = false;

  late DateTime _startedAt;
  late DateTime _roundStartedAt;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _roundStartedAt = _startedAt;
    _questions = PatternQuestionGenerator.generateQuestions(
      count: widget.difficulty.questionCount,
      optionCount: widget.difficulty.optionCount,
      difficultyLevel: widget.difficulty.levelNumber,
      difficulty: widget.difficulty,
    );
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  String _getLocale(BuildContext context) {
    try {
      final notifier = context.watch<LocaleNotifier?>();
      if (notifier != null) return notifier.currentLocale;
    } catch (_) {}
    return 'en';
  }

  PatternQuestion get _currentQuestion => _questions[_currentIndex];

  void _onOptionSelected(PatternItem option) {
    if (_isTurnLocked || _eliminatedOptions.contains(option)) {
      return;
    }

    final loc = _getLocale(context);

    setState(() {
      _selectedOption = option;
    });

    if (option == _currentQuestion.correctAnswer) {
      // Correct Match
      final answerSelectedAt = DateTime.now();
      final responseTimeMs = answerSelectedAt
          .difference(_roundStartedAt)
          .inMilliseconds
          .toDouble();

      _roundRecords.add(
        PatternRoundRecord(
          roundNumber: _currentIndex + 1,
          patternType: _currentQuestion.patternType,
          roundStartedAt: _roundStartedAt,
          answerSelectedAt: answerSelectedAt,
          responseTimeMs: responseTimeMs,
          isCorrect: true,
          mistakesInRound: _roundMistakes,
          hintsUsedInRound: _roundHints,
        ),
      );

      setState(() {
        _isTurnLocked = true;
        _isAnswerRevealed = true;
        _correctCount++;
        _isFeedbackCorrect = true;
        _feedbackMessage = AppStrings.get('wellDonePattern', locale: loc);
      });

      _advanceTimer = Timer(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        _advanceToNextOrFinish();
      });
    } else {
      // Gentle Supportive Mismatch
      setState(() {
        _mistakeCount++;
        _roundMistakes++;
        _isFeedbackCorrect = false;
        _feedbackMessage = AppStrings.get('tryPatternAgain', locale: loc);
        // Dim the mistaken option so the user can choose again comfortably
        _eliminatedOptions.add(option);
      });
    }
  }

  void _advanceToNextOrFinish() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _selectedOption = null;
        _eliminatedOptions.clear();
        _isTurnLocked = false;
        _isAnswerRevealed = false;
        _feedbackMessage = null;
        _roundMistakes = 0;
        _roundHints = 0;
        _roundStartedAt = DateTime.now();
      });
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    final completedAt = DateTime.now();
    final metrics = PatternRecognitionMetrics.calculate(
      difficulty: widget.difficulty,
      totalQuestions: _questions.length,
      correctAnswers: _correctCount,
      mistakes: _mistakeCount,
      hintCount: _hintCount,
      startedAt: _startedAt,
      completedAt: completedAt,
      roundRecords: _roundRecords,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PatternRecognitionResultScreen(
          metrics: metrics,
        ),
      ),
    );
  }

  void _useHint() {
    if (_isTurnLocked) return;

    final incorrectRemaining = _currentQuestion.options
        .where((opt) =>
            opt != _currentQuestion.correctAnswer &&
            !_eliminatedOptions.contains(opt))
        .toList();

    if (incorrectRemaining.isNotEmpty) {
      final loc = _getLocale(context);
      setState(() {
        _hintCount++;
        _eliminatedOptions.add(incorrectRemaining.first);
        _roundHints++;
        final typeHint = AppStrings.get(
          _currentQuestion.patternType.hintKey,
          locale: loc,
        );
        _feedbackMessage = typeHint.isNotEmpty
            ? typeHint
            : _currentQuestion.hint;
        _isFeedbackCorrect = true;
      });
    } else {
      final loc = _getLocale(context);
      setState(() {
        _hintCount++;
        final typeHint = AppStrings.get(
          _currentQuestion.patternType.hintKey,
          locale: loc,
        );
        _feedbackMessage = typeHint.isNotEmpty
            ? typeHint
            : _currentQuestion.hint;
        _isFeedbackCorrect = true;
      });
    }
  }

  void _showPauseDialog() {
    final loc = _getLocale(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1.5,
          ),
        ),
        title: Row(
          children: [
            Icon(Icons.pause_circle_outline_rounded,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, size: 28.0),
            const SizedBox(width: 10.0),
            Text(
              AppStrings.get('pauseExercise', locale: loc),
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          AppStrings.get('pausePatternDialogContent', locale: loc),
          style: TextStyle(
            fontSize: 16.0,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              AppStrings.get('leaveExercise', locale: loc),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkWarmAccent : const Color(0xFFDC2626),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppStrings.get('resume', locale: loc),
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkBackground : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = _getLocale(context);
    final question = _currentQuestion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: AppStrings.get('patternGame', locale: loc),
      actions: [
        IconButton(
          icon: Icon(
            Icons.pause_circle_outline_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: 30.0,
          ),
          tooltip: AppStrings.get('pauseExercise', locale: loc),
          onPressed: _showPauseDialog,
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Header Bar: Question Tally and Hint Button
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              // Question Progress Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightWarmAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightWarmAccent.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${AppStrings.get('questionProgress', locale: loc)} ${_currentIndex + 1} of ${_questions.length}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
              ),

              // Hint Action Button
              OutlinedButton.icon(
                icon: Icon(
                  Icons.lightbulb_outline_rounded,
                  color: isDark ? AppColors.darkSoftGold : AppColors.lightHighlight,
                  size: 22.0,
                ),
                label: Text(
                  '${AppStrings.get('hint', locale: loc)} ($_hintCount)',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkSoftGold : AppColors.lightHighlight,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15),
                  side: BorderSide(
                    color: isDark ? AppColors.darkSoftGold : AppColors.lightHighlight,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14.0, vertical: 8.0),
                ),
                onPressed: _isTurnLocked ? null : _useHint,
              ),
            ],
          ),
          const SizedBox(height: 20.0),

          // Sequence Display
          PatternSequenceDisplay(
            sequence: question.sequence,
            isAnswerRevealed: _isAnswerRevealed,
            revealedAnswer:
                _isAnswerRevealed ? question.correctAnswer : null,
            locale: loc,
          ),
          const SizedBox(height: 20.0),

          // Feedback Notification Banner (if any)
          if (_feedbackMessage != null) ...[
            SmritiCard(
              backgroundColor: _isFeedbackCorrect
                  ? (isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15))
                  : (isDark ? const Color(0xFF2A281E) : const Color(0xFFFEF3C7)),
              borderColor: _isFeedbackCorrect
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkSoftGold : const Color(0xFFD97706)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Icon(
                    _isFeedbackCorrect
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    color: _isFeedbackCorrect
                        ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                        : (isDark ? AppColors.darkSoftGold : const Color(0xFFD97706)),
                    size: 26.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: _isFeedbackCorrect
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                            : (isDark ? AppColors.darkSoftGold : const Color(0xFF92400E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],

          // Prompt
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              AppStrings.get('whatComesNext', locale: loc),
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8.0),

          // Answer Option Buttons
          for (final option in question.options) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: PatternOptionButton(
                item: option,
                state: _getOptionState(option),
                onTap: () => _onOptionSelected(option),
                locale: loc,
              ),
            ),
          ],
        ],
      ),
    );
  }

  OptionButtonState _getOptionState(PatternItem option) {
    if (_eliminatedOptions.contains(option)) {
      return OptionButtonState.eliminatedByHint;
    }
    if (_selectedOption == option) {
      if (option == _currentQuestion.correctAnswer) {
        return OptionButtonState.selectedCorrect;
      } else {
        return OptionButtonState.selectedIncorrect;
      }
    }
    return OptionButtonState.normal;
  }
}
