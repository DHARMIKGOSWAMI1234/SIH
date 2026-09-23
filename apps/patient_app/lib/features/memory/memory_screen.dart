import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/smriti_theme.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../data/local/database/app_database.dart';
import '../../data/local/repositories/smriti_repository.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';
import 'models/memory_categories.dart';
import 'services/memory_media_service.dart';
import 'screens/add_memory_screen.dart';
import 'screens/memory_detail_screen.dart';
import 'screens/life_story_screen.dart';
import 'screens/memory_activity_screen.dart';
import 'screens/familiar_world_screen.dart';
import 'screens/family_connect_screen.dart';
import 'screens/reminiscence_screen.dart';
import 'screens/music_memory_screen.dart';
import '../help/models/help_screen_id.dart';

/// Personal Memory Bank Screen.
///
/// Provides an elderly-first, personalized interface for browsing cherished
/// family memories, cultural traditions, and life milestones.
class MemoryScreen extends StatefulWidget {
  final bool isEmbedded;

  const MemoryScreen({
    super.key,
    this.isEmbedded = false,
  });

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  int _viewMode = 0; // 0 = Memory Bank, 1 = My Life Story
  String _selectedCategoryFilter = 'all';
  bool _onlyFavorites = false;
  List<Memory> _memories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemories();
  }

  Future<void> _loadMemories() async {
    setState(() => _isLoading = true);
    final repo = context.read<SmritiRepository>();
    final results = await repo.getMemories(
      category: _selectedCategoryFilter == 'all' ? null : _selectedCategoryFilter,
      isFavorite: _onlyFavorites ? true : null,
      includeArchived: false,
    );

    if (mounted) {
      setState(() {
        _memories = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _openAddMemory() async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AddMemoryScreen()),
    );
    if (added == true) {
      _loadMemories();
    }
  }

  Future<void> _toggleFavorite(Memory mem) async {
    final repo = context.read<SmritiRepository>();
    await repo.toggleFavorite(mem.localId, !mem.isFavorite);
    _loadMemories();
  }

  String _getLocale(BuildContext context) {
    try {
      final notifier = context.watch<LocaleNotifier?>();
      if (notifier != null) return notifier.currentLocale;
    } catch (_) {}
    return 'en';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = _getLocale(context);

    final bodyContent = Column(
      children: [
        // View Mode Toggle (Memory Bank vs My Life Story)
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
          child: Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightBorder,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _viewMode = 0),
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _viewMode == 0
                            ? (isDark ? AppColors.darkSoftBlue : AppColors.lightCard)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: _viewMode == 0
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          AppStrings.get('memoryBankCardTitle', locale: loc),
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: _viewMode == 0 ? FontWeight.bold : FontWeight.w500,
                            color: _viewMode == 0
                                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _viewMode = 1),
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10.0),
                      decoration: BoxDecoration(
                        color: _viewMode == 1
                            ? (isDark ? AppColors.darkSoftBlue : AppColors.lightCard)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.0),
                        boxShadow: _viewMode == 1
                            ? [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4.0,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          AppStrings.get('myLifeStoryCardTitle', locale: loc),
                          style: TextStyle(
                            fontSize: 15.0,
                            fontWeight: _viewMode == 1 ? FontWeight.bold : FontWeight.w500,
                            color: _viewMode == 1
                                ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Body Content
        Expanded(
          child: _viewMode == 1
              ? const LifeStoryScreen(isEmbedded: true)
              : _buildMemoryBankContent(isDark, loc),
        ),
      ],
    );

    if (widget.isEmbedded) {
      return SafeArea(child: bodyContent);
    }

    return SmritiScaffold(
      title: AppStrings.get('memoryBankCardTitle', locale: loc),
      helpScreenId: _viewMode == 1 ? HelpScreenId.lifeStory : HelpScreenId.personalMemory,
      actions: [
        IconButton(
          icon: const Icon(Icons.psychology_rounded, size: 28.0),
          tooltip: AppStrings.get('startMemoryActivity', locale: loc),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MemoryActivityScreen()),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline_rounded, size: 28.0),
          tooltip: AppStrings.get('addMemory', locale: loc),
          onPressed: _openAddMemory,
        ),
      ],
      body: bodyContent,
    );
  }

  Widget _buildQuickExploreCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return SmritiCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44.0,
            height: 44.0,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Icon(icon, color: color, size: 24.0),
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
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
          const SizedBox(width: 6.0),
          Icon(Icons.chevron_right_rounded, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ],
      ),
    );
  }

  Widget _buildMemoryBankContent(bool isDark, String loc) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      children: [
        SmritiSectionHeader(
          title: AppStrings.get('memoriesThatMatter', locale: loc),
          subtitle: AppStrings.get('memoriesThatMatterSubtitle', locale: loc),
          icon: Icons.auto_stories_rounded,
        ),
        const SizedBox(height: 12.0),

        // Action Buttons Row (Add Memory + Play Memory Activity)
        LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 360;
            if (isNarrow) {
              return Column(
                children: [
                  SmritiPrimaryButton(
                    label: AppStrings.get('addMemory', locale: loc),
                    icon: Icons.add_rounded,
                    onPressed: _openAddMemory,
                  ),
                  const SizedBox(height: 8.0),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MemoryActivityScreen()),
                      );
                    },
                    icon: const Icon(Icons.psychology_rounded, size: 20.0),
                    label: Text(AppStrings.get('startMemoryActivity', locale: loc), style: const TextStyle(fontSize: 15.0)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50.0),
                      foregroundColor: SmritiTheme.restorativeSage,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: SmritiPrimaryButton(
                    label: AppStrings.get('addMemory', locale: loc),
                    icon: Icons.add_rounded,
                    onPressed: _openAddMemory,
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MemoryActivityScreen()),
                      );
                    },
                    icon: const Icon(Icons.psychology_rounded, size: 20.0),
                    label: Text(AppStrings.get('startMemoryActivity', locale: loc), style: const TextStyle(fontSize: 15.0)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52.0),
                      foregroundColor: SmritiTheme.restorativeSage,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12.0),

        // Filter Chips (All, Favorites, Family, Places, Childhood, Festivals, etc.)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              // All Filter
              FilterChip(
                label: Text(AppStrings.get('allMemories', locale: loc)),
                selected: _selectedCategoryFilter == 'all' && !_onlyFavorites,
                onSelected: (sel) {
                  setState(() {
                    _selectedCategoryFilter = 'all';
                    _onlyFavorites = false;
                  });
                  _loadMemories();
                },
              ),
              const SizedBox(width: 8.0),

              // Favorites Filter
              FilterChip(
                avatar: const Icon(Icons.star_rounded, size: 16.0, color: Colors.amber),
                label: Text(AppStrings.get('favorites', locale: loc)),
                selected: _onlyFavorites,
                onSelected: (sel) {
                  setState(() {
                    _onlyFavorites = sel;
                    if (sel) _selectedCategoryFilter = 'all';
                  });
                  _loadMemories();
                },
              ),
              const SizedBox(width: 8.0),

              // Categories
              ...MemoryCategory.values.map((cat) {
                final isSelected = _selectedCategoryFilter == cat.id && !_onlyFavorites;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    avatar: Icon(cat.icon, size: 16.0, color: cat.color),
                    label: Text(AppStrings.get(cat.localizationKey, locale: loc)),
                    selected: isSelected,
                    onSelected: (sel) {
                      setState(() {
                        _selectedCategoryFilter = sel ? cat.id : 'all';
                        _onlyFavorites = false;
                      });
                      _loadMemories();
                    },
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16.0),

        // Quick Explore Modules Grid / Column
        _buildQuickExploreCard(
          icon: Icons.travel_explore_rounded,
          title: 'Familiar World',
          subtitle: 'Identify cultural items & traditions from Assam and the North East',
          color: AppColors.primaryGreen,
          isDark: isDark,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FamiliarWorldScreen()),
          ),
        ),
        const SizedBox(height: 8.0),
        _buildQuickExploreCard(
          icon: Icons.wb_twilight_rounded,
          title: 'Reminiscence Mode',
          subtitle: 'Peaceful photo reflections & gentle conversations',
          color: AppColors.softBlue,
          isDark: isDark,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReminiscenceScreen()),
          ),
        ),
        const SizedBox(height: 8.0),
        _buildQuickExploreCard(
          icon: Icons.library_music_rounded,
          title: 'Memory Through Music',
          subtitle: 'Calming melodies, familiar songs, and festival tunes',
          color: AppColors.terracotta,
          isDark: isDark,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MusicMemoryScreen()),
          ),
        ),
        const SizedBox(height: 8.0),
        _buildQuickExploreCard(
          icon: Icons.family_restroom_rounded,
          title: 'Family Connect',
          subtitle: 'Contributions & loving notes added by your family',
          color: AppColors.accentGold,
          isDark: isDark,
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FamilyConnectScreen()),
          ),
        ),
        const SizedBox(height: 16.0),

        // Memories List or Empty State
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: SmritiTheme.restorativeSage),
            ),
          )
        else if (_memories.isEmpty)
          _buildEmptyState(isDark, loc)
        else
          ..._memories.map((mem) => _buildMemoryCard(mem, isDark, loc)),
      ],
    );
  }

  Widget _buildEmptyState(bool isDark, String loc) {
    return Container(
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 56.0,
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          ),
          const SizedBox(height: 14.0),
          Text(
            _onlyFavorites
                ? AppStrings.get('noFavoritesYet', locale: loc)
                : 'No memories yet',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            _onlyFavorites
                ? AppStrings.get('favoriteHint', locale: loc)
                : 'Add a family photo or a familiar story to keep it close.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton.icon(
            onPressed: _openAddMemory,
            icon: const Icon(Icons.add_rounded),
            label: Text(AppStrings.get('addMemory', locale: loc), style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemoryCard(Memory mem, bool isDark, String loc) {
    final cat = MemoryCategory.fromId(mem.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: SmritiCard(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => MemoryDetailScreen(memory: mem)),
          );
          _loadMemories();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail / Fallback Visual
            MemoryMediaService.buildThumbnail(
              imagePath: mem.imagePath ?? mem.mediaUri,
              category: cat,
              height: 150.0,
              borderRadius: BorderRadius.circular(12.0),
              isDark: isDark,
            ),
            const SizedBox(height: 14.0),

            // Category & Favorite Row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8.0,
              runSpacing: 6.0,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: cat.color.withAlpha(isDark ? 40 : 25),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(color: cat.color.withAlpha(60)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.icon, size: 14.0, color: cat.color),
                      const SizedBox(width: 4.0),
                      Text(
                        AppStrings.get(cat.localizationKey, locale: loc),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: cat.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (mem.audioPath != null && mem.audioPath!.isNotEmpty) ...[
                      const Icon(Icons.mic_rounded, size: 18.0, color: SmritiTheme.restorativeSage),
                      const SizedBox(width: 8.0),
                    ],
                    IconButton(
                      icon: Icon(
                        mem.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: mem.isFavorite
                            ? (isDark ? AppColors.darkSoftGold : AppColors.lightHighlight)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        size: 24.0,
                      ),
                      onPressed: () => _toggleFavorite(mem),
                      constraints: const BoxConstraints(minWidth: 36.0, minHeight: 36.0),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6.0),

            // Title
            Text(
              mem.title,
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),

            // Person / Relationship / Location
            if (mem.personName != null || mem.location != null) ...[
              const SizedBox(height: 4.0),
              Wrap(
                spacing: 12.0,
                runSpacing: 4.0,
                children: [
                  if (mem.personName != null && mem.personName!.isNotEmpty)
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
                  if (mem.location != null && mem.location!.isNotEmpty)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_outlined, size: 14.0, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        const SizedBox(width: 2.0),
                        Text(
                          mem.location!,
                          style: TextStyle(
                            fontSize: 13.0,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ],
            const SizedBox(height: 8.0),

            // Description
            Text(
              mem.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.0,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
