import 'package:flutter/material.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../../../features/memory/services/memory_rescue_service.dart';
import '../../../l10n/app_strings.dart';
import '../../theme/smriti_theme.dart';
import '../voice_models.dart';
import '../voice_service.dart';

/// Elderly-first voice interaction bottom sheet.
/// Large microphone target (>= 64dp), calm visual feedback, clear transcripts, and touch fallback.
class VoiceInteractionSheet extends StatefulWidget {
  final VoiceService voiceService;
  final MemoryRescueService memoryRescue;
  final SmritiRepository repository;
  final Locale locale;
  final Function(String gameType)? onLaunchGame;

  const VoiceInteractionSheet({
    super.key,
    required this.voiceService,
    required this.memoryRescue,
    required this.repository,
    required this.locale,
    this.onLaunchGame,
  });

  static Future<void> show({
    required BuildContext context,
    required VoiceService voiceService,
    required MemoryRescueService memoryRescue,
    required SmritiRepository repository,
    required Locale locale,
    Function(String gameType)? onLaunchGame,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => VoiceInteractionSheet(
        voiceService: voiceService,
        memoryRescue: memoryRescue,
        repository: repository,
        locale: locale,
        onLaunchGame: onLaunchGame,
      ),
    );
  }

  @override
  State<VoiceInteractionSheet> createState() => _VoiceInteractionSheetState();
}

class _VoiceInteractionSheetState extends State<VoiceInteractionSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );

    // Automatically trigger initial listening on presentation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startVoiceInteraction();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    widget.voiceService.cancel();
    super.dispose();
  }

  Future<void> _startVoiceInteraction() async {
    await widget.voiceService.processVoiceInteraction(
      locale: widget.locale,
      memoryRescue: widget.memoryRescue,
      repository: widget.repository,
      onLaunchGame: widget.onLaunchGame,
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = widget.locale.languageCode;

    return ListenableBuilder(
      listenable: widget.voiceService,
      builder: (context, _) {
        final state = widget.voiceService.state;
        final transcript = widget.voiceService.transcript;
        final response = widget.voiceService.lastResponse;

        String statusText;
        IconData stateIcon;
        Color stateColor;

        switch (state) {
          case VoiceState.listening:
            statusText = AppStrings.get('voiceListening', locale: lang);
            stateIcon = Icons.mic;
            stateColor = SmritiTheme.restorativeSage;
            break;
          case VoiceState.processing:
            statusText = AppStrings.get('voiceProcessing', locale: lang);
            stateIcon = Icons.psychology;
            stateColor = const Color(0xFFD97706);
            break;
          case VoiceState.speaking:
            statusText = AppStrings.get('voiceSpeaking', locale: lang);
            stateIcon = Icons.volume_up;
            stateColor = SmritiTheme.restorativeSage;
            break;
          case VoiceState.error:
          case VoiceState.idle:
            statusText = response != null
                ? (response.isSuccess ? 'Completed' : 'Please try again')
                : AppStrings.get('voiceTapToSpeak', locale: lang);
            stateIcon = Icons.mic;
            stateColor = SmritiTheme.deepSlate;
            break;
        }

        return Container(
          decoration: const BoxDecoration(
            color: SmritiTheme.warmCream,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 16,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Text(
                    AppStrings.get('voiceTitle', locale: lang),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: SmritiTheme.deepSlate,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.get('voiceSubtitle', locale: lang),
                    style: const TextStyle(
                      fontSize: 16,
                      color: SmritiTheme.mutedText,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Big Microphone Control (>= 64dp, elderly-first)
                  ScaleTransition(
                    scale: state == VoiceState.listening ? _pulseAnimation : const AlwaysStoppedAnimation(1.0),
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: stateColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: stateColor, width: 3),
                      ),
                      child: IconButton(
                        iconSize: 44,
                        icon: Icon(stateIcon, color: stateColor),
                        tooltip: AppStrings.get('voiceTapToSpeak', locale: lang),
                        onPressed: state == VoiceState.listening
                            ? () => widget.voiceService.cancel()
                            : _startVoiceInteraction,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Status Text
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: stateColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Transcript Display (if available)
                  if (transcript != null && transcript.isNotEmpty) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.get('voiceTranscriptLabel', locale: lang),
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '"$transcript"',
                            style: const TextStyle(
                              fontSize: 18,
                              fontStyle: FontStyle.italic,
                              color: SmritiTheme.deepSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Response Display (if available)
                  if (response != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: SmritiTheme.restorativeSage.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: SmritiTheme.restorativeSage.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'SMRITI',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: SmritiTheme.restorativeSage,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            response.visualText,
                            style: const TextStyle(
                              fontSize: 18,
                              height: 1.4,
                              color: SmritiTheme.deepSlate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Action Buttons (Elderly-First: Touch Fallback & Cancel)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (constraints.maxWidth < 340) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {
                                widget.voiceService.cancel();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.touch_app, size: 20),
                              label: Text(
                                AppStrings.get('voiceTouchFallback', locale: lang),
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                                foregroundColor: SmritiTheme.deepSlate,
                                side: const BorderSide(color: SmritiTheme.deepSlate),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              onPressed: () {
                                widget.voiceService.cancel();
                                Navigator.of(context).pop();
                              },
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 48),
                                foregroundColor: Colors.grey.shade700,
                                side: BorderSide(color: Colors.grey.shade400),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                AppStrings.get('voiceCancel', locale: lang),
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                          ],
                        );
                      }
                      return Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                widget.voiceService.cancel();
                                Navigator.of(context).pop();
                              },
                              icon: const Icon(Icons.touch_app, size: 20),
                              label: Text(
                                AppStrings.get('voiceTouchFallback', locale: lang),
                                style: const TextStyle(fontSize: 15),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 56),
                                foregroundColor: SmritiTheme.deepSlate,
                                side: const BorderSide(color: SmritiTheme.deepSlate),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              widget.voiceService.cancel();
                              Navigator.of(context).pop();
                            },
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(72, 56),
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              AppStrings.get('voiceCancel', locale: lang),
                              style: const TextStyle(fontSize: 15),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
