import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/smriti_theme.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../../../l10n/app_strings.dart';
import '../models/memory_categories.dart';
import '../services/memory_media_service.dart';

/// Polished, accessible Memory Detail screen.
///
/// Features large, high-contrast imagery, readable typography (18sp+),
/// voice note player foundation, and favorite/archive actions.
class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  late Memory _memory;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _memory = widget.memory;
  }

  Future<void> _toggleFavorite() async {
    final repo = context.read<SmritiRepository>();
    final newFav = !_memory.isFavorite;
    await repo.toggleFavorite(_memory.localId, newFav);
    setState(() {
      _memory = _memory.copyWith(isFavorite: newFav);
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newFav ? 'Added to your Favorites' : 'Removed from Favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _archiveMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Archive Memory?'),
        content: const Text('This memory will be stored in your archive. You can restore it anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: SmritiTheme.restorativeSage),
            child: const Text('Archive', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final repo = context.read<SmritiRepository>();
      await repo.archiveMemory(_memory.localId, true);
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cat = MemoryCategory.fromId(_memory.category);

    return SmritiScaffold(
      title: _memory.title,
      actions: [
        IconButton(
          icon: Icon(
            _memory.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            color: _memory.isFavorite ? Colors.amber : (isDark ? Colors.white : SmritiTheme.deepSlate),
            size: 28.0,
          ),
          onPressed: _toggleFavorite,
          tooltip: 'Toggle Favorite',
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        children: [
          // Photo / Fallback Visual
          MemoryMediaService.buildThumbnail(
            imagePath: _memory.imagePath ?? _memory.mediaUri,
            category: cat,
            height: 240.0,
            borderRadius: BorderRadius.circular(16.0),
            isDark: isDark,
          ),
          const SizedBox(height: 20.0),

          // Title & Category Badges
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: cat.color.withAlpha(isDark ? 50 : 30),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: cat.color.withAlpha(80)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(cat.icon, size: 16.0, color: cat.color),
                    const SizedBox(width: 6.0),
                    Text(
                      AppStrings.get(cat.localizationKey),
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: cat.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (_memory.relationship != null && _memory.relationship!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    color: isDark ? SmritiTheme.darkSurfaceCard : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: const Color(0xFF93C5FD)),
                  ),
                  child: Text(
                    _memory.relationship!,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Person Name / Memory Title
          if (_memory.personName != null && _memory.personName!.isNotEmpty) ...[
            Text(
              _memory.personName!,
              style: TextStyle(
                fontSize: 28.0,
                fontWeight: FontWeight.bold,
                color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              _memory.title,
              style: TextStyle(
                fontSize: 18.0,
                color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
              ),
            ),
          ] else ...[
            Text(
              _memory.title,
              style: TextStyle(
                fontSize: 26.0,
                fontWeight: FontWeight.bold,
                color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
              ),
            ),
          ],
          const SizedBox(height: 12.0),

          // Location & Date
          if ((_memory.location != null && _memory.location!.isNotEmpty) || _memory.eventDate != null)
            Wrap(
              spacing: 16.0,
              runSpacing: 6.0,
              children: [
                if (_memory.location != null && _memory.location!.isNotEmpty)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.place_outlined, size: 18.0, color: cat.color),
                      const SizedBox(width: 4.0),
                      Text(
                        _memory.location!,
                        style: TextStyle(
                          fontSize: 15.0,
                          color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
                if (_memory.eventDate != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 16.0, color: cat.color),
                      const SizedBox(width: 4.0),
                      Text(
                        '${_memory.eventDate!.year}',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          const SizedBox(height: 20.0),

          // Description Card (Elderly 18sp+ body text)
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: isDark ? SmritiTheme.darkSurfaceCard : Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle),
            ),
            child: Text(
              _memory.description,
              style: TextStyle(
                fontSize: 18.0,
                height: 1.6,
                color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
              ),
            ),
          ),
          const SizedBox(height: 20.0),

          // Audio Note Player Bar (if audio exists)
          if (_memory.audioPath != null && _memory.audioPath!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: isDark ? SmritiTheme.darkSurfaceCard : SmritiTheme.sageLight,
                borderRadius: BorderRadius.circular(14.0),
                border: Border.all(color: isDark ? SmritiTheme.darkBorder : SmritiTheme.restorativeSage.withAlpha(60)),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() => _isPlayingAudio = !_isPlayingAudio);
                    },
                    icon: Icon(
                      _isPlayingAudio ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                      color: SmritiTheme.restorativeSage,
                      size: 40.0,
                    ),
                  ),
                  const SizedBox(width: 10.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isPlayingAudio ? 'Playing voice note...' : 'Personal Voice Note',
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                          ),
                        ),
                        Text(
                          'Recorded with family',
                          style: TextStyle(
                            fontSize: 13.0,
                            color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
          ],

          // Archive Button
          OutlinedButton.icon(
            onPressed: _archiveMemory,
            icon: const Icon(Icons.archive_outlined, size: 20.0),
            label: const Text('Archive Memory', style: TextStyle(fontSize: 16.0)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              minimumSize: const Size(double.infinity, 52.0),
              foregroundColor: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
            ),
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
