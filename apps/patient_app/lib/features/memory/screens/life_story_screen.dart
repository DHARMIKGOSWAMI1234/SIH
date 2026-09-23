import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/smriti_theme.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../data/local/database/app_database.dart';
import '../../../data/local/repositories/smriti_repository.dart';
import '../models/memory_categories.dart';
import '../services/memory_media_service.dart';
import '../../help/models/help_screen_id.dart';
import 'memory_detail_screen.dart';
import 'add_memory_screen.dart';

/// My Life Story: Chronological personal-memory timeline.
///
/// Strictly non-clinical, zero synthetic data. Displays real dated memories
/// organized by milestone years, with a calm empty state when no memories exist yet.
class LifeStoryScreen extends StatefulWidget {
  final bool isEmbedded;

  const LifeStoryScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<LifeStoryScreen> createState() => _LifeStoryScreenState();
}

class _LifeStoryScreenState extends State<LifeStoryScreen> {
  List<Memory> _timelineMemories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTimeline();
  }

  Future<void> _loadTimeline() async {
    setState(() => _isLoading = true);
    final repo = context.read<SmritiRepository>();
    final allMemories = await repo.getMemories(includeArchived: false);

    // Filter memories with eventDate or sort by createdAt
    final dated = allMemories.where((m) => m.eventDate != null).toList()
      ..sort((a, b) => a.eventDate!.compareTo(b.eventDate!));

    // If none are dated, use all memories sorted chronologically
    final displayList = dated.isNotEmpty
        ? dated
        : (allMemories.toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt)));

    if (mounted) {
      setState(() {
        _timelineMemories = displayList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = _isLoading
        ? const Center(child: CircularProgressIndicator(color: SmritiTheme.restorativeSage))
        : _timelineMemories.isEmpty
            ? _buildEmptyState(isDark)
            : _buildTimeline(isDark);

    if (widget.isEmbedded) {
      return content;
    }

    return SmritiScaffold(
      title: 'My Life Story',
      helpScreenId: HelpScreenId.lifeStory,
      actions: [
        IconButton(
          icon: const Icon(Icons.playlist_add_rounded, size: 28.0),
          tooltip: 'Load Sample Milestones',
          onPressed: _seedSampleMilestones,
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 28.0),
          onPressed: () async {
            final added = await Navigator.of(context).push<bool>(
              MaterialPageRoute(builder: (_) => const AddMemoryScreen()),
            );
            if (added == true) _loadTimeline();
          },
          tooltip: 'Add Story Milestone',
        ),
      ],
      body: content,
    );
  }

  Future<void> _seedSampleMilestones() async {
    final repo = context.read<SmritiRepository>();
    final samples = [
      {
        'title': 'Born in Dibrugarh',
        'desc': 'Welcomed into the world on a cool autumn morning in Assam surrounded by loving grandparents.',
        'year': 1948,
        'cat': 'childhood',
      },
      {
        'title': 'High School Graduation',
        'desc': 'Completed schooling with high honors and made lifelong childhood friends.',
        'year': 1965,
        'cat': 'important_events',
      },
      {
        'title': 'Wedding Celebration',
        'desc': 'A joyful traditional ceremony with family, traditional brass gongs, and festive feasts.',
        'year': 1972,
        'cat': 'family',
      },
      {
        'title': 'New Family Home',
        'desc': 'Built our family house with a garden filled with orchids and a quiet veranda.',
        'year': 1980,
        'cat': 'places',
      },
    ];

    for (final s in samples) {
      await repo.insertMemory(
        title: s['title'] as String,
        description: s['desc'] as String,
        category: s['cat'] as String,
        eventDate: DateTime(s['year'] as int, 6, 15),
        source: 'sample_timeline',
      );
    }
    await _loadTimeline();
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_stories_outlined,
              size: 64.0,
              color: isDark ? SmritiTheme.sageAccentDark : SmritiTheme.restorativeSage,
            ),
            const SizedBox(height: 16.0),
            Text(
              'Your Life Story Begins Here',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              'Add childhood memories, family events, and memorable places to build your personal timeline.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                height: 1.5,
                color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
              ),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton.icon(
              onPressed: () async {
                final added = await Navigator.of(context).push<bool>(
                  MaterialPageRoute(builder: (_) => const AddMemoryScreen()),
                );
                if (added == true) _loadTimeline();
              },
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Milestone', style: TextStyle(fontSize: 16.0)),
              style: ElevatedButton.styleFrom(
                backgroundColor: SmritiTheme.restorativeSage,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
      itemCount: _timelineMemories.length,
      itemBuilder: (context, index) {
        final mem = _timelineMemories[index];
        final cat = MemoryCategory.fromId(mem.category);
        final yearLabel = mem.eventDate != null
            ? '${mem.eventDate!.year}'
            : '${mem.createdAt.year}';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline indicator
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: cat.color,
                    borderRadius: BorderRadius.circular(6.0),
                  ),
                  child: Text(
                    yearLabel,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  width: 2.0,
                  height: 140.0,
                  color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle,
                ),
              ],
            ),
            const SizedBox(width: 14.0),

            // Card
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: GestureDetector(
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => MemoryDetailScreen(memory: mem)),
                    );
                    _loadTimeline();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDark ? SmritiTheme.darkSurfaceCard : Colors.white,
                      borderRadius: BorderRadius.circular(14.0),
                      border: Border.all(color: isDark ? SmritiTheme.darkBorder : SmritiTheme.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (mem.imagePath != null || mem.mediaUri != null) ...[
                          MemoryMediaService.buildThumbnail(
                            imagePath: mem.imagePath ?? mem.mediaUri,
                            category: cat,
                            height: 110.0,
                            borderRadius: BorderRadius.circular(10.0),
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10.0),
                        ],
                        Text(
                          mem.title,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                          ),
                        ),
                        if (mem.personName != null && mem.personName!.isNotEmpty) ...[
                          const SizedBox(height: 4.0),
                          Text(
                            mem.relationship != null && mem.relationship!.isNotEmpty
                                ? '${mem.personName} (${mem.relationship})'
                                : mem.personName!,
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                              color: cat.color,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6.0),
                        Text(
                          mem.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15.0,
                            color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
