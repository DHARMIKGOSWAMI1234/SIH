import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/smriti_scaffold.dart';
import '../../../core/widgets/smriti_card.dart';
import '../../help/models/help_screen_id.dart';

class MusicTrackItem {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final int durationSeconds;
  final IconData icon;

  const MusicTrackItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.durationSeconds,
    required this.icon,
  });
}

/// "Memory Through Music" Screen.
///
/// State: DEMO FOUNDATION
/// Working demo audio controls (play/pause/scrub), curated non-copyrighted soothing tracks,
/// and calm visualization without external streaming or copyrighted music.
class MusicMemoryScreen extends StatefulWidget {
  const MusicMemoryScreen({super.key});

  @override
  State<MusicMemoryScreen> createState() => _MusicMemoryScreenState();
}

class _MusicMemoryScreenState extends State<MusicMemoryScreen> {
  final List<MusicTrackItem> _tracks = const [
    MusicTrackItem(
      id: 'track_1',
      title: 'Peaceful Bamboo Flute Melody',
      subtitle: 'Gentle morning acoustic flute from the Brahmaputra valley',
      category: 'Calming Tunes',
      durationSeconds: 180,
      icon: Icons.music_note_rounded,
    ),
    MusicTrackItem(
      id: 'track_2',
      title: 'Grandmother\'s Courtyard Lullaby',
      subtitle: 'Soft traditional humming melody for gentle reminiscence',
      category: 'Family Memories',
      durationSeconds: 210,
      icon: Icons.favorite_rounded,
    ),
    MusicTrackItem(
      id: 'track_3',
      title: 'Traditional Bihu Dhol & Pepa Rhythm',
      subtitle: 'Joyful cultural festive rhythm of spring',
      category: 'Festivals',
      durationSeconds: 150,
      icon: Icons.celebration_rounded,
    ),
    MusicTrackItem(
      id: 'track_4',
      title: 'Evening Verandah Rain & Tanpura',
      subtitle: 'Soothing rain and ambient drone for peaceful rest',
      category: 'Relaxation',
      durationSeconds: 240,
      icon: Icons.water_drop_rounded,
    ),
  ];

  String _selectedCategory = 'All';
  int _activeTrackIndex = 0;
  bool _isPlaying = false;
  int _currentPositionSeconds = 0;
  Timer? _playbackTimer;
  double _volumeLevel = 0.8;

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _playbackTimer?.cancel();
      _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        final track = _tracks[_activeTrackIndex];
        setState(() {
          if (_currentPositionSeconds < track.durationSeconds) {
            _currentPositionSeconds++;
          } else {
            _currentPositionSeconds = 0;
            _isPlaying = false;
            timer.cancel();
          }
        });
      });
    } else {
      _playbackTimer?.cancel();
    }
  }

  void _selectTrack(int index) {
    setState(() {
      _activeTrackIndex = index;
      _currentPositionSeconds = 0;
      _isPlaying = true;
    });

    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      final track = _tracks[_activeTrackIndex];
      setState(() {
        if (_currentPositionSeconds < track.durationSeconds) {
          _currentPositionSeconds++;
        } else {
          _currentPositionSeconds = 0;
          _isPlaying = false;
          timer.cancel();
        }
      });
    });
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTrack = _tracks[_activeTrackIndex];

    final categories = ['All', 'Calming Tunes', 'Family Memories', 'Festivals', 'Relaxation'];
    final filteredTracks = _selectedCategory == 'All'
        ? _tracks
        : _tracks.where((t) => t.category == _selectedCategory).toList();

    return SmritiScaffold(
      title: 'Memory Through Music',
      helpScreenId: HelpScreenId.musicMemory,
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
                  const Icon(Icons.library_music_rounded, color: AppColors.primaryGreen, size: 28.0),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Music & Calming Sounds (Demo Foundation)',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Text(
                          'Working audio player demo with original soothing acoustic loops. Strictly non-copyrighted material.',
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

            // Active Player Card
            SmritiCard(
              child: Column(
                children: [
                  // Track Info
                  Row(
                    children: [
                      Container(
                        width: 56.0,
                        height: 56.0,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: Icon(
                          activeTrack.icon,
                          color: AppColors.primaryGreen,
                          size: 32.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activeTrack.title,
                              style: const TextStyle(
                                fontSize: 17.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              activeTrack.subtitle,
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
                  const SizedBox(height: 20.0),

                  // Animated Soundwave Visualizer Demo
                  Container(
                    height: 48.0,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(16, (i) {
                        final waveHeight = _isPlaying
                            ? (12.0 + ((i * 7 + _currentPositionSeconds * 5) % 32))
                            : 8.0;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 4.0,
                          height: waveHeight,
                          decoration: BoxDecoration(
                            color: _isPlaying ? AppColors.primaryGreen : AppColors.warmGrey,
                            borderRadius: BorderRadius.circular(2.0),
                          ),
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 12.0),

                  // Progress Bar & Scrub
                  Slider(
                    value: _currentPositionSeconds.toDouble().clamp(0.0, activeTrack.durationSeconds.toDouble()),
                    min: 0.0,
                    max: activeTrack.durationSeconds.toDouble(),
                    activeColor: AppColors.primaryGreen,
                    inactiveColor: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                    onChanged: (val) {
                      setState(() {
                        _currentPositionSeconds = val.toInt();
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_currentPositionSeconds),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          _formatDuration(activeTrack.durationSeconds),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  // Audio Control Buttons (Min 56dp Touch Targets)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Previous Track
                      IconButton(
                        iconSize: 36.0,
                        icon: const Icon(Icons.skip_previous_rounded),
                        onPressed: () {
                          final prev = (_activeTrackIndex - 1 + _tracks.length) % _tracks.length;
                          _selectTrack(prev);
                        },
                      ),
                      const SizedBox(width: 16.0),

                      // Large Play/Pause Toggle (64dp target)
                      Semantics(
                        button: true,
                        label: _isPlaying ? 'Pause music' : 'Play music',
                        child: InkWell(
                          onTap: _togglePlayback,
                          borderRadius: BorderRadius.circular(36.0),
                          child: Container(
                            width: 68.0,
                            height: 68.0,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryGreen,
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16.0),

                      // Next Track
                      IconButton(
                        iconSize: 36.0,
                        icon: const Icon(Icons.skip_next_rounded),
                        onPressed: () {
                          final next = (_activeTrackIndex + 1) % _tracks.length;
                          _selectTrack(next);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12.0),

                  // Volume / Calmness level slider
                  Row(
                    children: [
                      const Icon(Icons.volume_down_rounded, size: 20.0, color: AppColors.warmGrey),
                      Expanded(
                        child: Slider(
                          value: _volumeLevel,
                          min: 0.0,
                          max: 1.0,
                          activeColor: AppColors.accentGold,
                          onChanged: (val) => setState(() => _volumeLevel = val),
                        ),
                      ),
                      const Icon(Icons.volume_up_rounded, size: 20.0, color: AppColors.warmGrey),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),

            // Category Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen.withValues(alpha: 0.2),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.primaryGreen
                            : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16.0),

            // Track List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTracks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10.0),
              itemBuilder: (context, index) {
                final track = filteredTracks[index];
                final isCurrent = _tracks[_activeTrackIndex].id == track.id;

                return SmritiCard(
                  onTap: () {
                    final originalIndex = _tracks.indexWhere((t) => t.id == track.id);
                    if (originalIndex != -1) _selectTrack(originalIndex);
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 44.0,
                        height: 44.0,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primaryGreen.withValues(alpha: 0.2)
                              : (isDark ? AppColors.darkSurface : AppColors.warmCream),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Icon(
                          isCurrent && _isPlaying ? Icons.equalizer_rounded : track.icon,
                          color: isCurrent ? AppColors.primaryGreen : AppColors.warmGrey,
                          size: 24.0,
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title,
                              style: TextStyle(
                                fontSize: 15.0,
                                fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                                color: isCurrent ? AppColors.primaryGreen : null,
                              ),
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              track.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.0,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        _formatDuration(track.durationSeconds),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
