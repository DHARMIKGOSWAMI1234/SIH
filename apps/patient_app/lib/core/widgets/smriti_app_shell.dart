import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/smriti_theme.dart';
import '../theme/app_colors.dart';
import 'smriti_icon_button.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';
import '../../core/voice/voice_service.dart';
import '../../core/voice/widgets/voice_interaction_sheet.dart';
import '../../data/local/repositories/smriti_repository.dart';
import '../../features/memory/services/memory_rescue_service.dart';
import '../../features/home/home_screen.dart';
import '../../features/games/games_screen.dart';
import '../../features/memory/memory_screen.dart';
import '../../features/reminders/reminders_screen.dart';
import '../../features/progress/progress_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/profile/profile_screen.dart';

/// Unified application shell for SMRITI Patient Application.
/// Provides elderly-first navigation with large touch targets, clear icons,
/// dynamic multilingual localization across 9 languages, and "Talk to Me" voice interaction.
class SmritiAppShell extends StatefulWidget {
  final int initialIndex;
  final String currentLocale;

  const SmritiAppShell({
    super.key,
    this.initialIndex = 0,
    this.currentLocale = 'en',
  });

  @override
  State<SmritiAppShell> createState() => _SmritiAppShellState();
}

class _SmritiAppShellState extends State<SmritiAppShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onTabSelected(int index) {
    if (index == 5) {
      _showHelpDialog();
      return;
    }
    setState(() {
      _currentIndex = index;
    });
  }

  void _openVoiceSheet(BuildContext context, String currentLocale) {
    final voiceService = context.read<VoiceService?>();
    final repository = context.read<SmritiRepository?>();
    if (voiceService == null || repository == null) return;

    final memoryRescue = MemoryRescueService(repository);

    VoiceInteractionSheet.show(
      context: context,
      voiceService: voiceService,
      memoryRescue: memoryRescue,
      repository: repository,
      locale: Locale(currentLocale),
      onLaunchGame: (gameType) {
        setState(() {
          _currentIndex = 1; // Switch to Games tab
        });
      },
    );
  }

  void _showHelpDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = _getActiveLocale();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        title: Row(
          children: [
            Icon(Icons.help_outline_rounded,
                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary, size: 30.0),
            const SizedBox(width: 10.0),
            Expanded(
              child: Text(
                AppStrings.get('helpTitle', locale: loc),
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
            ),
          ],
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHelpItem(
                  icon: Icons.home_rounded,
                  title: AppStrings.get('navHome', locale: loc),
                  description: AppStrings.get('helpHomeDesc', locale: loc),
                  isDark: isDark,
                ),
                const SizedBox(height: 12.0),
                _buildHelpItem(
                  icon: Icons.psychology_rounded,
                  title: AppStrings.get('navGames', locale: loc),
                  description: AppStrings.get('helpGamesDesc', locale: loc),
                  isDark: isDark,
                ),
                const SizedBox(height: 12.0),
                _buildHelpItem(
                  icon: Icons.photo_library_rounded,
                  title: AppStrings.get('navMemories', locale: loc),
                  description: AppStrings.get('helpMemoriesDesc', locale: loc),
                  isDark: isDark,
                ),
                const SizedBox(height: 12.0),
                _buildHelpItem(
                  icon: Icons.schedule_rounded,
                  title: AppStrings.get('navReminders', locale: loc),
                  description: AppStrings.get('helpRemindersDesc', locale: loc),
                  isDark: isDark,
                ),
                const SizedBox(height: 12.0),
                _buildHelpItem(
                  icon: Icons.insights_rounded,
                  title: AppStrings.get('navProgress', locale: loc),
                  description: AppStrings.get('helpProgressDesc', locale: loc),
                  isDark: isDark,
                ),
                const SizedBox(height: 12.0),
                _buildHelpItem(
                  icon: Icons.mic_rounded,
                  title: AppStrings.get('talkToMe', locale: loc),
                  description: AppStrings.get('helpVoiceDesc', locale: loc),
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SmritiTheme.restorativeSage,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppStrings.get('done', locale: loc),
              style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 26.0, color: SmritiTheme.restorativeSage),
        const SizedBox(width: 12.0),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17.0,
                  fontWeight: FontWeight.bold,
                  color: isDark ? SmritiTheme.darkTextPrimary : SmritiTheme.deepSlate,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                description,
                style: TextStyle(
                  fontSize: 15.0,
                  color: isDark ? SmritiTheme.darkTextSecondary : SmritiTheme.mutedText,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getActiveLocale() {
    try {
      final locNotifier = context.watch<LocaleNotifier?>();
      if (locNotifier != null) return locNotifier.currentLocale;
    } catch (_) {}
    return widget.currentLocale;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = _getActiveLocale();

    final List<Widget> pages = [
      HomeScreen(
        currentLocale: currentLocale,
        onNavigateTab: (idx) => setState(() => _currentIndex = idx),
      ),
      const GamesScreen(isEmbedded: true),
      const MemoryScreen(isEmbedded: true),
      const RemindersScreen(isEmbedded: true),
      ProgressScreen(key: ValueKey('progress_$_currentIndex'), isEmbedded: true),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        titleSpacing: 12.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.get('appName', locale: currentLocale),
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.0,
                  height: 8.0,
                  decoration: const BoxDecoration(
                    color: AppColors.successGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    AppStrings.get('offlineReady', locale: currentLocale),
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // "Talk to Me" Voice Action
          SmritiIconButton(
            icon: Icons.mic_rounded,
            tooltip: AppStrings.get('talkToMe', locale: currentLocale),
            minSize: 44.0,
            iconSize: 26.0,
            onPressed: () => _openVoiceSheet(context, currentLocale),
          ),
          SmritiIconButton(
            icon: Icons.help_outline_rounded,
            tooltip: AppStrings.get('navHelp', locale: currentLocale),
            minSize: 44.0,
            iconSize: 26.0,
            onPressed: _showHelpDialog,
          ),
          SmritiIconButton(
            icon: Icons.person_outline_rounded,
            tooltip: AppStrings.get('navSettings', locale: currentLocale),
            minSize: 44.0,
            iconSize: 26.0,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
          SmritiIconButton(
            icon: Icons.settings_outlined,
            tooltip: AppStrings.get('navSettings', locale: currentLocale),
            minSize: 44.0,
            iconSize: 26.0,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 4.0),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2.0),
          child: Container(
            color: (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                .withValues(alpha: 0.6),
            height: 1.5,
          ),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex < pages.length ? _currentIndex : 0,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 8.0,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _buildNavItem(
                    index: 0,
                    label: AppStrings.get('navHome', locale: currentLocale),
                    icon: Icons.home_rounded,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 1,
                    label: AppStrings.get('navGames', locale: currentLocale),
                    icon: Icons.psychology_rounded,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 2,
                    label: AppStrings.get('navMemories', locale: currentLocale),
                    icon: Icons.photo_library_rounded,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 3,
                    label: AppStrings.get('navReminders', locale: currentLocale),
                    icon: Icons.schedule_rounded,
                    isDark: isDark,
                  ),
                ),
                Expanded(
                  child: _buildNavItem(
                    index: 4,
                    label: AppStrings.get('navProgress', locale: currentLocale),
                    icon: Icons.insights_rounded,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String label,
    required IconData icon,
    required bool isDark,
  }) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final inactiveColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return InkWell(
      onTap: () => _onTabSelected(index),
      borderRadius: BorderRadius.circular(12.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 26.0,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3.0),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 13.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

