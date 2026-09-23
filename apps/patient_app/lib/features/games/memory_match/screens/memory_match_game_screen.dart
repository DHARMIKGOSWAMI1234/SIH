import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/smriti_theme.dart';
import '../../../../core/widgets/smriti_scaffold.dart';
import '../../../../core/widgets/smriti_icon_button.dart';
import '../models/memory_card_item.dart';
import '../models/memory_match_state.dart';
import '../widgets/memory_card_widget.dart';
import 'memory_match_result_screen.dart';
import '../../../help/models/help_screen_id.dart';
import '../../../help/services/stuck_detection_service.dart';
import '../../../help/services/help_context_service.dart';
import '../../../help/widgets/gentle_help_prompt.dart';
import '../../../help/widgets/bandhu_help_sheet.dart';
import '../../models/game_model.dart';
import '../../models/game_context.dart';

/// Interactive gameplay screen for SMRITI Memory Match.
class MemoryMatchGameScreen extends StatefulWidget {
  final MemoryMatchDifficulty difficulty;

  const MemoryMatchGameScreen({
    super.key,
    this.difficulty = MemoryMatchDifficulty.easy,
  });

  @override
  State<MemoryMatchGameScreen> createState() => _MemoryMatchGameScreenState();
}

class _MemoryMatchGameScreenState extends State<MemoryMatchGameScreen> {
  late List<MemoryCardTile> _cards;
  MemoryCardTile? _firstCard;
  MemoryCardTile? _secondCard;
  MemoryMatchStatus _status = MemoryMatchStatus.playing;

  int _matchedPairs = 0;
  int _totalAttempts = 0;
  int _mistakes = 0;
  int _hintCount = 0;
  late DateTime _startedAt;
  String _feedbackMessage = 'Tap any card to begin.';
  Timer? _hintTimer;

  final StuckDetectionService _stuckService = StuckDetectionService();
  int _lastCrossAxisCount = 3;

  @override
  void initState() {
    super.initState();
    _startNewGame();
    _stuckService.recordGameStarted();
    _stuckService.shouldShowPrompt.addListener(_onStuckPromptChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateHelpContext());
  }

  void _onStuckPromptChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _hintTimer?.cancel();
    _stuckService.shouldShowPrompt.removeListener(_onStuckPromptChanged);
    _stuckService.dispose();
    super.dispose();
  }

  void _startNewGame() {
    _cards = MemoryCardGenerator.generateCards(widget.difficulty);
    _firstCard = null;
    _secondCard = null;
    _status = MemoryMatchStatus.playing;
    _matchedPairs = 0;
    _totalAttempts = 0;
    _mistakes = 0;
    _hintCount = 0;
    _startedAt = DateTime.now();
    _feedbackMessage = 'Find the pairs at your own pace.';
  }

  void _onCardTapped(MemoryCardTile tile) {
    // Prevent interaction if resolving match, completed, or already face up
    if (_status != MemoryMatchStatus.playing) return;
    if (tile.isMatched || tile.isFaceUp) return;

    _stuckService.recordUserAction();

    if (_firstCard == null) {
      // First card tapped
      setState(() {
        tile.isFaceUp = true;
        _firstCard = tile;
        _feedbackMessage = 'Now find the matching picture.';
      });
      _updateHelpContext();
    } else if (_secondCard == null && tile.instanceId != _firstCard!.instanceId) {
      // Second card tapped
      setState(() {
        tile.isFaceUp = true;
        _secondCard = tile;
        _totalAttempts++;
        _status = MemoryMatchStatus.checkingMatch;
      });
      _updateHelpContext();

      _resolveMatch();
    }
  }

  Future<void> _resolveMatch() async {
    final first = _firstCard!;
    final second = _secondCard!;

    if (first.item.key == second.item.key) {
      // MATCH
      await Future.delayed(const Duration(milliseconds: 250));
      if (!mounted) return;

      _stuckService.recordProgress();

      setState(() {
        first.isMatched = true;
        second.isMatched = true;
        _matchedPairs++;
        _firstCard = null;
        _secondCard = null;
        _feedbackMessage = 'You found a pair!';
        _status = MemoryMatchStatus.playing;
      });
      _updateHelpContext();

      // Check for completion
      if (_matchedPairs == widget.difficulty.pairCount) {
        _onGameCompleted();
      }
    } else {
      // MISMATCH
      _stuckService.recordMistake();

      setState(() {
        _mistakes++;
        _feedbackMessage = 'Not a match yet. Take your time.';
      });
      _updateHelpContext();

      await Future.delayed(widget.difficulty.mismatchDisplayDuration);
      if (!mounted) return;

      setState(() {
        first.isFaceUp = false;
        second.isFaceUp = false;
        _firstCard = null;
        _secondCard = null;
        _status = MemoryMatchStatus.playing;
      });
      _updateHelpContext();
    }
  }

  void _triggerHint() {
    if (_status != MemoryMatchStatus.playing) return;
    _stuckService.recordUserAction();

    MemoryCardTile? hint1;
    MemoryCardTile? hint2;

    if (_firstCard != null) {
      hint1 = _firstCard;
      for (final c in _cards) {
        if (!c.isMatched &&
            c.instanceId != _firstCard!.instanceId &&
            c.item.key == _firstCard!.item.key) {
          hint2 = c;
          break;
        }
      }
    } else {
      for (final c1 in _cards) {
        if (!c1.isMatched && !c1.isFaceUp) {
          for (final c2 in _cards) {
            if (!c2.isMatched &&
                !c2.isFaceUp &&
                c1.instanceId != c2.instanceId &&
                c1.item.key == c2.item.key) {
              hint1 = c1;
              hint2 = c2;
              break;
            }
          }
          if (hint1 != null && hint2 != null) break;
        }
      }
    }

    if (hint1 != null && hint2 != null) {
      setState(() {
        _hintCount++;
        hint1!.isHighlighted = true;
        hint2!.isHighlighted = true;
        _feedbackMessage = 'Notice the highlighted cards!';
      });

      _hintTimer?.cancel();
      _hintTimer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) {
          setState(() {
            hint1?.isHighlighted = false;
            hint2?.isHighlighted = false;
          });
        }
      });
    }
  }

  void _onGameCompleted() {
    _stuckService.recordGameCompleted();
    _updateHelpContext();
    final completedAt = DateTime.now();
    final metrics = MemoryMatchMetrics.calculate(
      difficulty: widget.difficulty,
      matchedPairs: _matchedPairs,
      totalAttempts: _totalAttempts,
      mistakes: _mistakes,
      hintCount: _hintCount,
      startedAt: _startedAt,
      completedAt: completedAt,
    );

    setState(() {
      _status = MemoryMatchStatus.completed;
      _feedbackMessage = 'All pairs found!';
    });

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MemoryMatchResultScreen(metrics: metrics),
        ),
      );
    });
  }

  GameContext _buildGameContext(int crossAxisCount) {
    MemoryMatchGameHint? hint;

    if (_status == MemoryMatchStatus.playing) {
      if (_firstCard != null) {
        final i1 = _cards.indexOf(_firstCard!);
        final i2 = _cards.indexWhere(
          (c) =>
              !c.isMatched &&
              c.instanceId != _firstCard!.instanceId &&
              c.item.key == _firstCard!.item.key,
        );
        if (i1 != -1 && i2 != -1) {
          final fRow = (i1 ~/ crossAxisCount) + 1;
          final fCol = (i1 % crossAxisCount) + 1;
          final mRow = (i2 ~/ crossAxisCount) + 1;
          final mCol = (i2 % crossAxisCount) + 1;
          hint = MemoryMatchGameHint(
            card1Row: fRow,
            card1Col: fCol,
            card1Label: _firstCard!.item.label,
            card2Row: mRow,
            card2Col: mCol,
            card2Label: _cards[i2].item.label,
            hasFaceUpCard: true,
            faceUpRow: fRow,
            faceUpCol: fCol,
            faceUpLabel: _firstCard!.item.label,
            targetMatchingRow: mRow,
            targetMatchingCol: mCol,
          );
        }
      } else {
        for (int i = 0; i < _cards.length; i++) {
          final c1 = _cards[i];
          if (c1.isMatched || c1.isFaceUp) continue;
          for (int j = i + 1; j < _cards.length; j++) {
            final c2 = _cards[j];
            if (!c2.isMatched && !c2.isFaceUp && c1.item.key == c2.item.key) {
              hint = MemoryMatchGameHint(
                card1Row: (i ~/ crossAxisCount) + 1,
                card1Col: (i % crossAxisCount) + 1,
                card1Label: c1.item.label,
                card2Row: (j ~/ crossAxisCount) + 1,
                card2Col: (j % crossAxisCount) + 1,
                card2Label: c2.item.label,
                hasFaceUpCard: false,
              );
              break;
            }
          }
          if (hint != null) break;
        }
      }
    }

    final totalPairs = widget.difficulty.pairCount;
    final progress = totalPairs > 0 ? (_matchedPairs / totalPairs).clamp(0.0, 1.0) : 0.0;
    final elapsed = DateTime.now().difference(_startedAt);

    return GameContext(
      gameType: CognitiveGameType.memoryMatch,
      gamePhase: _status == MemoryMatchStatus.completed
          ? 'completed'
          : (_firstCard != null ? 'first_card_selected' : 'playing'),
      difficulty: widget.difficulty.index + 1,
      score: _matchedPairs * 10,
      mistakes: _mistakes,
      hintsUsed: _hintCount,
      elapsedTime: elapsed,
      progress: progress,
      isActive: _status == MemoryMatchStatus.playing,
      isComplete: _status == MemoryMatchStatus.completed,
      availableHints: 3,
      memoryMatchHint: hint,
    );
  }

  void _updateHelpContext() {
    if (!mounted) return;
    final gameContext = _buildGameContext(_lastCrossAxisCount);
    HelpContextService.instance.updateFromScreenId(
      HelpScreenId.memoryMatch,
      gameContext: gameContext,
    );
  }

  Future<bool> _confirmExit() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
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
        title: Text(
          'Leave Activity?',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        content: Text(
          'Would you like to pause and return to the main screen?',
          style: TextStyle(
            fontSize: 17.0,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            child: Text(
              'Stay Here',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
            ),
            child: const Text('Exit Activity', style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold)),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _confirmExit();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: SmritiScaffold(
        title: 'Memory Match',
        helpScreenId: HelpScreenId.memoryMatch,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: SmritiIconButton(
              icon: Icons.lightbulb_outline_rounded,
              tooltip: 'Get a gentle hint',
              backgroundColor: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.2),
              color: isDark ? AppColors.darkSoftGold : AppColors.lightHighlight,
              onPressed: _status == MemoryMatchStatus.playing ? _triggerHint : null,
            ),
          ),
        ],
        body: LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = _calculateCrossAxisCount(widget.difficulty, constraints.maxWidth);
            if (_lastCrossAxisCount != crossAxisCount) {
              _lastCrossAxisCount = crossAxisCount;
              WidgetsBinding.instance.addPostFrameCallback((_) => _updateHelpContext());
            }
            final cardDimensions = _calculateCardSize(crossAxisCount, constraints);

            return Column(
              children: [
                // Top Progress and Metrics Bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 8.0),
                  child: Row(
                    children: [
                      // Matched Counter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                color: isDark ? AppColors.darkPrimary : SmritiTheme.successGreen,
                                size: 20.0,
                              ),
                              const SizedBox(width: 6.0),
                              Flexible(
                                child: Text(
                                  'Pairs: $_matchedPairs / ${widget.difficulty.pairCount}',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10.0),
                      // Attempts Counter
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : AppColors.lightCard,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                size: 20.0,
                              ),
                              const SizedBox(width: 6.0),
                              Flexible(
                                child: Text(
                                  'Flips: $_totalAttempts',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Feedback Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSoftBlue : AppColors.lightWarmAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: isDark ? AppColors.darkBorder : AppColors.lightWarmAccent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _feedbackMessage,
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                // Gentle Help Prompt (Non-intrusive stuck assistance)
                if (_stuckService.shouldShowPrompt.value && _status == MemoryMatchStatus.playing)
                  GentleHelpPrompt(
                    onHelpMe: () {
                      _stuckService.dismiss();
                      BandhuHelpSheet.show(context);
                    },
                    onNotNow: () {
                      _stuckService.dismiss();
                    },
                  ),

                const SizedBox(height: 8.0),

                // Cards Grid Area
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Wrap(
                        spacing: 12.0,
                        runSpacing: 12.0,
                        alignment: WrapAlignment.center,
                        children: _cards.map((tile) {
                          return MemoryCardWidget(
                            tile: tile,
                            cardWidth: cardDimensions.width,
                            cardHeight: cardDimensions.height,
                            onTap: () => _onCardTapped(tile),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  int _calculateCrossAxisCount(MemoryMatchDifficulty diff, double maxWidth) {
    if (maxWidth > 650) return 4;
    switch (diff) {
      case MemoryMatchDifficulty.easy:
        return 3;
      case MemoryMatchDifficulty.medium:
        return maxWidth > 400 ? 4 : 2;
      case MemoryMatchDifficulty.hard:
        return maxWidth > 400 ? 4 : 3;
    }
  }

  Size _calculateCardSize(int crossAxisCount, BoxConstraints constraints) {
    if (constraints.maxWidth > 600) {
      return const Size(120.0, 145.0);
    } else if (constraints.maxWidth > 380) {
      return widget.difficulty == MemoryMatchDifficulty.easy
          ? const Size(100.0, 125.0)
          : const Size(82.0, 108.0);
    } else {
      return const Size(76.0, 98.0);
    }
  }
}
