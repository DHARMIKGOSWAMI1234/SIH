import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../help/models/help_screen_id.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// "Talk to Me" Screen: Deterministic local conversation companion.
///
/// State: DEMO FOUNDATION
/// Strictly non-clinical, clearly marked offline deterministic dialogue.
/// Never claims to have real-time AI reasoning or medical abilities.
class TalkToMeScreen extends StatefulWidget {
  const TalkToMeScreen({super.key});

  @override
  State<TalkToMeScreen> createState() => _TalkToMeScreenState();
}

class _TalkToMeScreenState extends State<TalkToMeScreen> {
  final _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSpeakingDemo = false;

  final List<ChatMessage> _messages = [
    ChatMessage(
      text: 'Namaskar! I am BANDHU, your friendly offline companion. We can chat about gentle memories, festivals, or daily routines. How are you feeling right now?',
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  final List<String> _topicChips = const [
    'Tell me about Bihu festival',
    'Morning tea memories',
    'Calm relaxation thought',
    'What games can I play?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _getDeterministicResponse(String query) {
    final lower = query.toLowerCase();

    if (lower.contains('bihu') || lower.contains('festival')) {
      return 'Bihu brings the sweet sound of the Pepa, fragrant Kopou flowers, and fresh Til Pitha shared with family on the courtyard. Celebrating traditions always brings warmth to the heart.';
    }

    if (lower.contains('tea') || lower.contains('morning')) {
      return 'There is nothing quite as comforting as a warm cup of Assam tea on the verandah in the early morning breeze. A steady routine helps the body and mind stay relaxed.';
    }

    if (lower.contains('calm') || lower.contains('relax') || lower.contains('peace')) {
      return 'Take a deep breath and let your shoulders drop. You are safe, loved, and in a familiar place. Take things one moment at a time.';
    }

    if (lower.contains('game') || lower.contains('play') || lower.contains('activity')) {
      return 'You can try the Memory Match game to flip matching cards, or explore Familiar World to revisit traditional items from Assam and the North East.';
    }

    if (lower.contains('feeling') || lower.contains('sad') || lower.contains('tired')) {
      return 'It is completely normal to have quiet or tired moments. You can take a gentle rest, drink a glass of fresh water, or listen to a soothing melody in the Music section.';
    }

    return 'Thank you for sharing that with me. Talking about our memories and daily experiences helps keep our hearts light and peaceful.';
  }

  void _sendMessage(String text) {
    final clean = text.trim();
    if (clean.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: clean, isUser: true, timestamp: DateTime.now()));
      _textController.clear();
    });
    _scrollToBottom();

    // Deterministic response after brief comfortable delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      final reply = _getDeterministicResponse(clean);
      setState(() {
        _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
      });
      _scrollToBottom();
    });
  }

  void _simulateSpeechInput() {
    if (_isSpeakingDemo) {
      setState(() => _isSpeakingDemo = false);
      return;
    }

    setState(() => _isSpeakingDemo = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && _isSpeakingDemo) {
        setState(() {
          _isSpeakingDemo = false;
        });
        _sendMessage('Tell me about Bihu festival');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmritiScaffold(
      title: 'Talk to Me',
      helpScreenId: HelpScreenId.talkToMe,
      body: Column(
        children: [
          // Non-Clinical & Offline Companion Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
            color: isDark ? AppColors.darkSurface : AppColors.warmCream,
            child: Row(
              children: [
                const Icon(Icons.record_voice_over_rounded, color: AppColors.primaryGreen, size: 22.0),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    'Deterministic Local Companion (Non-AI, Non-Medical)',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageBubble(msg, isDark);
              },
            ),
          ),

          // Quick Topic Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _topicChips.map((topic) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      avatar: const Icon(Icons.chat_bubble_outline_rounded, size: 16.0),
                      label: Text(topic),
                      labelStyle: const TextStyle(fontSize: 12.0),
                      onPressed: () => _sendMessage(topic),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Input Bar with large touch targets
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Speech simulation button (56dp target)
                  Semantics(
                    button: true,
                    label: _isSpeakingDemo ? 'Stop speaking' : 'Speak to companion',
                    child: IconButton(
                      iconSize: 28.0,
                      icon: Icon(
                        _isSpeakingDemo ? Icons.mic_rounded : Icons.mic_none_rounded,
                        color: _isSpeakingDemo ? AppColors.error : AppColors.primaryGreen,
                      ),
                      tooltip: 'Simulate Voice Input',
                      onPressed: _simulateSpeechInput,
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Text Input
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a question or message...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                        ),
                      ),
                      onSubmitted: _sendMessage,
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  // Send button (56dp target)
                  Semantics(
                    button: true,
                    label: 'Send message',
                    child: Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20.0),
                        onPressed: () => _sendMessage(_textController.text),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!msg.isUser) ...[
            Container(
              width: 36.0,
              height: 36.0,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen,
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 20.0),
            ),
            const SizedBox(width: 10.0),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: msg.isUser
                    ? AppColors.primaryGreen
                    : (isDark ? AppColors.darkSurface : AppColors.warmCream),
                borderRadius: BorderRadius.circular(18.0).copyWith(
                  bottomLeft: msg.isUser ? const Radius.circular(18.0) : const Radius.circular(4.0),
                  bottomRight: msg.isUser ? const Radius.circular(4.0) : const Radius.circular(18.0),
                ),
                border: msg.isUser
                    ? null
                    : Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              ),
              child: Text(
                msg.text,
                style: TextStyle(
                  fontSize: 15.0,
                  height: 1.4,
                  color: msg.isUser
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                ),
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 10.0),
        ],
      ),
    );
  }
}
