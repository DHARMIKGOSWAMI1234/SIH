import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_card.dart';
import '../../../../core/widgets/smriti_primary_button.dart';
import '../../../../core/widgets/smriti_bottom_action_bar.dart';
import '../../../../core/widgets/smriti_confirmation_dialog.dart';
import '../../../../l10n/app_strings.dart';
import '../models/routine_item.dart';
import '../models/routine_question.dart';
import '../models/routine_recall_state.dart';
import '../widgets/routine_step_slot.dart';
import '../widgets/routine_card_button.dart';
import 'routine_recall_result_screen.dart';

/// Full interactive gameplay screen for Daily Routine Recall.
/// Elderly-first, high-contrast, large touch targets, calm reassurance.
class RoutineRecallGameScreen extends StatefulWidget {
  final RoutineRecallDifficulty difficulty;

  const RoutineRecallGameScreen({
    super.key,
    this.difficulty = RoutineRecallDifficulty.easy,
  });

  @override
  State<RoutineRecallGameScreen> createState() =>
      _RoutineRecallGameScreenState();
}

class _RoutineRecallGameScreenState extends State<RoutineRecallGameScreen> {
  late List<RoutineQuestion> _questions;
  int _currentIndex = 0;
  int _correctCount = 0;
  int _mistakeCount = 0;
  int _hintCount = 0;

  final List<RoutineItem> _userSequence = [];
  final Set<RoutineItem> _eliminatedDistractors = {};
  RoutineItem? _highlightedItem;

  bool _isTurnLocked = false;
  bool _isVerified = false;
  bool _isSequenceCorrect = false;
  String? _feedbackMessage;

  late DateTime _startedAt;
  Timer? _advanceTimer;

  @override
  void initState() {
    super.initState();
    _startedAt = DateTime.now();
    _questions = RoutineQuestionGenerator.generateQuestions(
      count: widget.difficulty.questionCount,
      difficultyLevel: widget.difficulty.levelNumber,
    );
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  RoutineQuestion get _currentQuestion => _questions[_currentIndex];

  void _onCardSelected(RoutineItem item) {
    if (_isTurnLocked ||
        _eliminatedDistractors.contains(item) ||
        _userSequence.contains(item)) {
      return;
    }

    if (_userSequence.length >= _currentQuestion.stepCount) {
      return;
    }

    setState(() {
      _userSequence.add(item);
      if (_highlightedItem == item) {
        _highlightedItem = null;
      }
      _isVerified = false;
      _feedbackMessage = null;
    });
  }

  void _onSlotRemoved(int index) {
    if (_isTurnLocked || index >= _userSequence.length) return;

    setState(() {
      _userSequence.removeAt(index);
      _isVerified = false;
      _feedbackMessage = null;
    });
  }

  void _clearSequence() {
    if (_isTurnLocked || _userSequence.isEmpty) return;

    setState(() {
      _userSequence.clear();
      _isVerified = false;
      _feedbackMessage = null;
    });
  }

  void _checkSequence() {
    if (_isTurnLocked || _userSequence.isEmpty) return;

    final target = _currentQuestion.correctSequence;
    bool isMatch = true;

    if (_userSequence.length != target.length) {
      isMatch = false;
    } else {
      for (int i = 0; i < target.length; i++) {
        if (_userSequence[i] != target[i]) {
          isMatch = false;
          break;
        }
      }
    }

    if (isMatch) {
      // Correct sequence!
      setState(() {
        _isTurnLocked = true;
        _isVerified = true;
        _isSequenceCorrect = true;
        _correctCount++;
        _feedbackMessage = AppStrings.get('wellDoneRoutine');
      });

      _advanceTimer = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        _advanceToNextOrFinish();
      });
    } else {
      // Gentle mismatch feedback
      setState(() {
        _mistakeCount++;
        _isVerified = true;
        _isSequenceCorrect = false;
        _feedbackMessage = AppStrings.get('tryRoutineAgain');
      });
    }
  }

  void _advanceToNextOrFinish() {
    if (_currentIndex + 1 < _questions.length) {
      setState(() {
        _currentIndex++;
        _userSequence.clear();
        _eliminatedDistractors.clear();
        _highlightedItem = null;
        _isTurnLocked = false;
        _isVerified = false;
        _isSequenceCorrect = false;
        _feedbackMessage = null;
      });
    } else {
      _finishGame();
    }
  }

  void _finishGame() {
    final completedAt = DateTime.now();
    final metrics = RoutineRecallMetrics.calculate(
      difficulty: widget.difficulty,
      totalQuestions: _questions.length,
      correctAnswers: _correctCount,
      mistakes: _mistakeCount,
      hintCount: _hintCount,
      startedAt: _startedAt,
      completedAt: completedAt,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => RoutineRecallResultScreen(metrics: metrics),
      ),
    );
  }

  void _useHint() {
    if (_isTurnLocked) return;

    // Hint Step 1: Remove an incorrect distractor if present
    final remainingDistractors = _currentQuestion.distractors
        .where((item) => !_eliminatedDistractors.contains(item))
        .toList();

    if (remainingDistractors.isNotEmpty) {
      setState(() {
        _hintCount++;
        final distractor = remainingDistractors.first;
        _eliminatedDistractors.add(distractor);
        _userSequence.remove(distractor);
        _feedbackMessage = AppStrings.get('hintRoutineDistractorHelp');
      });
      return;
    }

    // Hint Step 2: Highlight the next correct activity in chronological order
    final target = _currentQuestion.correctSequence;
    final nextIndex = _userSequence.length;

    if (nextIndex < target.length) {
      final nextRequiredItem = target[nextIndex];
      setState(() {
        _hintCount++;
        _highlightedItem = nextRequiredItem;
        _feedbackMessage =
            '${AppStrings.get('hintRoutineHelp')}: ${nextRequiredItem.getLocalizedLabel('en')}';
      });
    } else {
      setState(() {
        _feedbackMessage = 'All slots filled! Tap "Check Sequence" to submit.';
      });
    }
  }

  void _showPauseDialog() async {
    final shouldResume = await SmritiConfirmationDialog.show(
      context,
      title: AppStrings.get('pauseExercise'),
      message: 'Would you like to resume your routine recall or return to the main menu?',
      positiveLabel: AppStrings.get('resume'),
      negativeLabel: AppStrings.get('leaveExercise'),
      icon: Icons.pause_circle_outline_rounded,
    );

    if (shouldResume == false && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _currentQuestion;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: AppStrings.get('routineRecallTitle'),
      actions: [
        IconButton(
          icon: Icon(
            Icons.pause_circle_outline_rounded,
            color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
            size: 32.0,
          ),
          tooltip: AppStrings.get('pauseExercise'),
          onPressed: _showPauseDialog,
        ),
      ],
      bottomNavigationBar: SmritiBottomActionBar(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 360;
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SmritiPrimaryButton(
                      label: AppStrings.get('checkSequence'),
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: (_isTurnLocked ||
                              _userSequence.length != question.stepCount)
                          ? null
                          : _checkSequence,
                    ),
                    const SizedBox(height: 8.0),
                    OutlinedButton.icon(
                      icon: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFFD97706),
                        size: 22.0,
                      ),
                      label: Text(
                        '${AppStrings.get('hints')} ($_hintCount)',
                        style: const TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? SmritiTheme.darkSurfaceCard : const Color(0xFFFEF3C7),
                        side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      onPressed: _isTurnLocked ? null : _useHint,
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  // Hint Button
                  Expanded(
                    flex: 2,
                    child: OutlinedButton.icon(
                      icon: const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: Color(0xFFD97706),
                        size: 24.0,
                      ),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '${AppStrings.get('hints')} ($_hintCount)',
                          style: const TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isDark ? SmritiTheme.darkSurfaceCard : const Color(0xFFFEF3C7),
                        side: const BorderSide(color: Color(0xFFF59E0B), width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                      ),
                      onPressed: _isTurnLocked ? null : _useHint,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  // Check Sequence Button
                  Expanded(
                    flex: 3,
                    child: SmritiPrimaryButton(
                      label: AppStrings.get('checkSequence'),
                      icon: Icons.check_circle_outline_rounded,
                      onPressed: (_isTurnLocked ||
                              _userSequence.length != question.stepCount)
                          ? null
                          : _checkSequence,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // 1. HEADER PROGRESS BAR
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: isDark ? SmritiTheme.darkSurfaceCard : SmritiTheme.sageLight,
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '${AppStrings.get('questionProgress')} ${_currentIndex + 1} of ${_questions.length}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: isDark ? SmritiTheme.darkSurfaceCard : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Gentle • Level ${widget.difficulty.levelNumber}',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16.0),

          // 2. INSTRUCTION BANNER
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: isDark ? SmritiTheme.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(
                color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle,
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.format_list_numbered_rounded,
                      color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
                      size: 28.0,
                    ),
                    const SizedBox(width: 10.0),
                    Expanded(
                      child: Text(
                        'Put these activities in the order they happen.',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6.0),
                Text(
                  question.scenarioDescription,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16.0),

          // 3. FEEDBACK MESSAGE BANNER (if any)
          if (_feedbackMessage != null) ...[
            SmritiCard(
              backgroundColor: _isSequenceCorrect
                  ? (isDark ? const Color(0xFF064E3B) : SmritiTheme.sageLight)
                  : (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7)),
              borderColor: _isSequenceCorrect
                  ? SmritiTheme.restorativeSage
                  : const Color(0xFFD97706),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Icon(
                    _isSequenceCorrect
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    color: _isSequenceCorrect
                        ? SmritiTheme.restorativeSage
                        : const Color(0xFFD97706),
                    size: 26.0,
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Text(
                      _feedbackMessage!,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: _isSequenceCorrect
                            ? (isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate)
                            : (isDark ? const Color(0xFFFBBF24) : const Color(0xFF92400E)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
          ],

          // 4. YOUR ROUTINE SLOTS
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              Text(
                'Your Routine Order',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                ),
              ),
              if (_userSequence.isNotEmpty && !_isTurnLocked)
                TextButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 20.0),
                  label: Text(
                    AppStrings.get('clearSequence'),
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: _clearSequence,
                ),
            ],
          ),
          const SizedBox(height: 10.0),

          // Numbered Slots (1..4)
          for (int i = 0; i < question.stepCount; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: RoutineStepSlot(
                stepNumber: i + 1,
                item: i < _userSequence.length ? _userSequence[i] : null,
                onTapRemove: () => _onSlotRemoved(i),
                isVerified: _isVerified,
                isSequenceCorrect: _isSequenceCorrect,
              ),
            ),
          ],

          const SizedBox(height: 18.0),

          // 5. AVAILABLE ACTIVITIES POOL
          Text(
            'Available Activities',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
            ),
          ),
          const SizedBox(height: 10.0),

          // Available Activity Option Cards
          for (final option in question.availableOptions) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: RoutineCardButton(
                item: option,
                state: _getCardState(option),
                onTap: () => _onCardSelected(option),
              ),
            ),
          ],

          const SizedBox(height: 20.0),
        ],
      ),
    );
  }

  RoutineCardState _getCardState(RoutineItem item) {
    if (_eliminatedDistractors.contains(item)) {
      return RoutineCardState.eliminatedByHint;
    }
    if (_userSequence.contains(item)) {
      return RoutineCardState.selectedInSequence;
    }
    if (_highlightedItem == item) {
      return RoutineCardState.highlightedByHint;
    }
    return RoutineCardState.available;
  }
}
