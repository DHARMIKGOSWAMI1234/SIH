import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../core/widgets/smriti_card.dart';
import '../../../core/widgets/smriti_primary_button.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../../help/models/help_screen_id.dart';

class ReminiscencePrompt {
  final String question;
  final String category;

  const ReminiscencePrompt({required this.question, required this.category});
}

/// Reminiscence Mode Screen: Gentle reflection and photo conversation.
///
/// State: DEMO FOUNDATION
/// Working local prompts/text flow, speak/type/save actions.
class ReminiscenceScreen extends StatefulWidget {
  final Memory? initialMemory;

  const ReminiscenceScreen({super.key, this.initialMemory});

  @override
  State<ReminiscenceScreen> createState() => _ReminiscenceScreenState();
}

class _ReminiscenceScreenState extends State<ReminiscenceScreen> {
  final _reflectionController = TextEditingController();
  int _currentPromptIndex = 0;
  bool _isSpeakingDemo = false;
  bool _isTyping = false;
  bool _isSaved = false;
  Memory? _activeMemory;
  bool _isLoading = true;

  final List<ReminiscencePrompt> _prompts = const [
    ReminiscencePrompt(
      question: 'Who was with you on that cherished day?',
      category: 'People & Family',
    ),
    ReminiscencePrompt(
      question: 'What sounds or special music do you remember?',
      category: 'Sounds & Music',
    ),
    ReminiscencePrompt(
      question: 'What delicious food or sweets were being shared?',
      category: 'Food & Flavors',
    ),
    ReminiscencePrompt(
      question: 'What made you feel happy and peaceful in this moment?',
      category: 'Feelings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    if (widget.initialMemory != null) {
      setState(() {
        _activeMemory = widget.initialMemory;
        _isLoading = false;
      });
      return;
    }

    final repo = context.read<SmritiRepository>();
    final all = await repo.getMemories(includeArchived: false);
    if (mounted) {
      setState(() {
        _activeMemory = all.isNotEmpty ? all.first : null;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _reflectionController.dispose();
    super.dispose();
  }

  void _nextPrompt() {
    setState(() {
      _currentPromptIndex = (_currentPromptIndex + 1) % _prompts.length;
      _isSaved = false;
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
          _reflectionController.text =
              'We were all gathered on the verandah sharing hot Assam tea and homemade pitha while listening to the flute.';
          _isTyping = true;
        });
      }
    });
  }

  Future<void> _saveReflection(Memory? memory) async {
    final text = _reflectionController.text.trim();
    if (text.isEmpty) return;

    final repo = Provider.of<SmritiRepository>(context, listen: false);
    if (memory != null) {
      await repo.updateMemory(
        localId: memory.localId,
        title: memory.title,
        description: '${memory.description}\n\n[Reflection]: $text',
        category: memory.category,
        relationship: memory.relationship,
        personName: memory.personName,
        location: memory.location,
        eventDate: memory.eventDate,
        imagePath: memory.imagePath,
      );
    } else {
      await repo.insertMemory(
        title: 'Reminiscence: ${_prompts[_currentPromptIndex].category}',
        description: text,
        category: 'traditions',
        source: 'reminiscence',
        tags: 'reminiscence,reflection',
      );
    }

    if (mounted) {
      setState(() => _isSaved = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your reflection has been gently saved.'),
          backgroundColor: AppColors.primaryGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prompt = _prompts[_currentPromptIndex];

    return SmritiScaffold(
      title: 'Reminiscence Mode',
      helpScreenId: HelpScreenId.reminiscence,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Demo Foundation Banner
            Container(
              padding: const EdgeInsets.all(14.0),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(16.0),
                border: Border.all(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.wb_twilight_rounded, color: AppColors.primaryGreen, size: 28.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminiscence Foundation (Local Demo)',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Gentle conversational prompts to spark comforting personal stories. Works entirely offline.',
                          style: TextStyle(
                            fontSize: 12.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),

            // Cherished Memory Feature Card
            if (_isLoading)
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ))
            else
              SmritiCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Memory Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: AppColors.accentGold.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.photo_library_rounded, color: AppColors.accentGold, size: 24.0),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeMemory != null ? _activeMemory!.title : 'Courtyard Tea with Family',
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _activeMemory != null
                                    ? (_activeMemory!.personName ?? 'Cherished Memory')
                                    : 'Warm family gathering',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),

                    // Memory Description Preview
                    Container(
                      padding: const EdgeInsets.all(14.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.warmCream.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        _activeMemory != null
                            ? _activeMemory!.description
                            : 'Sitting together on the verandah in the pleasant evening breeze, enjoying tea and singing old traditional songs.',
                        style: const TextStyle(fontSize: 15.0, height: 1.4),
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Prompt Box
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(14.0),
                        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prompt.category,
                                style: const TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                              InkWell(
                                onTap: _nextPrompt,
                                child: const Row(
                                  children: [
                                    Text(
                                      'Next Prompt',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: AppColors.primaryGreen,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_rounded, size: 16.0, color: AppColors.primaryGreen),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8.0),
                          Text(
                            prompt.question,
                            style: const TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),

                    // Input Selection: Speak or Type
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 56.0,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _isSpeakingDemo ? AppColors.error : AppColors.primaryGreen,
                                  width: 2.0,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                              ),
                              icon: Icon(
                                _isSpeakingDemo ? Icons.mic_rounded : Icons.mic_none_rounded,
                                color: _isSpeakingDemo ? AppColors.error : AppColors.primaryGreen,
                                size: 26.0,
                              ),
                              label: Text(
                                _isSpeakingDemo ? 'Listening...' : 'Speak Reflection',
                                style: TextStyle(
                                  color: _isSpeakingDemo ? AppColors.error : AppColors.primaryGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15.0,
                                ),
                              ),
                              onPressed: _simulateSpeechInput,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: SizedBox(
                            height: 56.0,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(
                                  color: _isTyping ? AppColors.primaryGreen : AppColors.warmGrey,
                                  width: _isTyping ? 2.0 : 1.0,
                                ),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                              ),
                              icon: const Icon(Icons.edit_note_rounded, size: 26.0),
                              label: const Text(
                                'Write Reflection',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.0),
                              ),
                              onPressed: () => setState(() => _isTyping = !_isTyping),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Text Field if typing or speech captured
                    if (_isTyping || _reflectionController.text.isNotEmpty) ...[
                      const SizedBox(height: 16.0),
                      TextField(
                        controller: _reflectionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Your Reflection',
                          hintText: 'Share what you recall or how it made you feel...',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 14.0),
                      SmritiPrimaryButton(
                        label: _isSaved ? 'Saved to Memory' : 'Save Reflection',
                        icon: _isSaved ? Icons.check_circle_rounded : Icons.bookmark_add_rounded,
                        onPressed: _isSaved ? null : () => _saveReflection(_activeMemory),
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
