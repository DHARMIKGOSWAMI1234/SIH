import 'package:flutter/material.dart';
import '../../../core/theme/smriti_theme.dart';
import '../../../data/local/database/app_database.dart';
import '../models/memory_categories.dart';
import '../services/memory_media_service.dart';

/// Reminiscence card foundation encouraging gentle reflection on cherished memories.
///
/// Strictly non-clinical, zero conversational LLMs. Provides warm,
/// open-ended conversation prompts for elderly patients and visiting caregivers.
class ReminiscenceView extends StatefulWidget {
  final Memory memory;
  final VoidCallback? onPlayVoiceNote;
  final ValueChanged<String>? onSaveNote;

  const ReminiscenceView({
    super.key,
    required this.memory,
    this.onPlayVoiceNote,
    this.onSaveNote,
  });

  @override
  State<ReminiscenceView> createState() => _ReminiscenceViewState();
}

class _ReminiscenceViewState extends State<ReminiscenceView> {
  final _noteController = TextEditingController();
  bool _isAddingNote = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = MemoryCategory.fromId(widget.memory.category);

    return Container(
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: isDark ? SmritiTheme.darkSurfaceCard : Colors.white,
        borderRadius: BorderRadius.circular(18.0),
        border: Border.all(color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo / Fallback Visual
          MemoryMediaService.buildThumbnail(
            imagePath: widget.memory.imagePath ?? widget.memory.mediaUri,
            category: cat,
            height: 160.0,
            borderRadius: BorderRadius.circular(12.0),
            isDark: isDark,
          ),
          const SizedBox(height: 14.0),

          // Warm Prompt
          Row(
            children: [
              const Icon(Icons.favorite_rounded, color: SmritiTheme.restorativeSage, size: 22.0),
              const SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  'Would you like to talk about this memory?',
                  style: TextStyle(
                    fontSize: 17.0,
                    fontWeight: FontWeight.bold,
                    color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8.0),
          Text(
            widget.memory.title,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
              color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            widget.memory.description,
            style: TextStyle(
              fontSize: 16.0,
              height: 1.4,
              color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
            ),
          ),
          const SizedBox(height: 16.0),

          // Gentle Reflection Prompts
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: isDark ? SmritiTheme.darkSurfaceCard : SmritiTheme.sageLight,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Caregiver & Family Prompts:',
                  style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold, color: SmritiTheme.restorativeSage),
                ),
                const SizedBox(height: 4.0),
                Text(
                  '• "What do you remember most about this day?"\n'
                  '• "Who was with us during this celebration?"\n'
                  '• "What sounds or aromas do you recall from this moment?"',
                  style: TextStyle(
                    fontSize: 14.0,
                    height: 1.5,
                    color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.deepSlate,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14.0),

          // Actions: Listen / Save Note
          Wrap(
            spacing: 10.0,
            runSpacing: 8.0,
            children: [
              if (widget.memory.audioPath != null && widget.memory.audioPath!.isNotEmpty)
                OutlinedButton.icon(
                  onPressed: widget.onPlayVoiceNote,
                  icon: const Icon(Icons.play_circle_fill_rounded, size: 20.0),
                  label: const Text('Play Voice Note'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SmritiTheme.restorativeSage,
                  ),
                ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() => _isAddingNote = !_isAddingNote);
                },
                icon: const Icon(Icons.edit_note_rounded, size: 20.0),
                label: Text(_isAddingNote ? 'Cancel Note' : 'Add Family Note'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                ),
              ),
            ],
          ),

          if (_isAddingNote) ...[
            const SizedBox(height: 12.0),
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Add a new thought or story from your conversation...',
                filled: true,
                fillColor: isDark ? SmritiTheme.darkSurfaceCard : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () {
                if (_noteController.text.trim().isNotEmpty) {
                  widget.onSaveNote?.call(_noteController.text.trim());
                  _noteController.clear();
                  setState(() => _isAddingNote = false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SmritiTheme.restorativeSage,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Note'),
            ),
          ],
        ],
      ),
    );
  }
}
