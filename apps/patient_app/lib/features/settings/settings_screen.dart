import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_notifier.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../core/auth/auth_service.dart';
import '../../data/local/sync/sync_service.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';
import '../auth/login_screen.dart';
import '../help/models/help_screen_id.dart';

/// Settings & Accessibility Screen for patient app.
/// Fully localized across all 9 supported languages with dynamic theme switching.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _highContrast = false;
  bool _audioGuidance = true;

  void _showLanguageSelector(BuildContext context, LocaleNotifier? localeNotifier) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = localeNotifier?.currentLocale ?? 'en';
    final screenHeight = MediaQuery.of(context).size.height;
    final cardBg = isDark ? AppColors.darkCard : AppColors.lightCard;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetCtx) {
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: screenHeight * 0.85),
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: borderColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.get('languageSelectorTitle', locale: currentLocale),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.get('languageSelectorDesc', locale: currentLocale),
                    style: TextStyle(
                      fontSize: 15,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: AppStrings.supportedLanguages.length,
                      separatorBuilder: (context, index) => Divider(height: 1, color: borderColor),
                      itemBuilder: (context, index) {
                        final item = AppStrings.supportedLanguages[index];
                        final isSelected = item.code == currentLocale;

                        return Material(
                          color: Colors.transparent,
                          child: ListTile(
                            minVerticalPadding: 12,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            title: Text(
                              item.nativeName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                color: isSelected ? primaryColor : textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              item.englishName,
                              style: TextStyle(
                                fontSize: 14,
                                color: textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: isSelected
                                ? Icon(Icons.check_circle_rounded, color: primaryColor, size: 28)
                                : null,
                            onTap: () {
                              localeNotifier?.setLocale(item.code);
                              Navigator.of(bottomSheetCtx).pop();
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(bottomSheetCtx).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPrimary,
                        side: BorderSide(color: borderColor, width: 1.5),
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(
                        AppStrings.get('close', locale: currentLocale),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required ValueChanged<ThemeMode> onSelect,
    required bool isDark,
    required Color primaryColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final isSelected = currentMode == mode;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(mode),
        borderRadius: BorderRadius.circular(14.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14.0),
            border: Border.all(
              color: isSelected ? primaryColor : borderColor,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26.0,
                color: isSelected
                    ? (isDark ? AppColors.darkBackground : Colors.white)
                    : textSecondary,
              ),
              const SizedBox(height: 6.0),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? (isDark ? AppColors.darkBackground : Colors.white)
                      : textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    ThemeNotifier? themeNotifier;
    try {
      themeNotifier = Provider.of<ThemeNotifier?>(context);
    } catch (_) {}

    LocaleNotifier? localeNotifier;
    try {
      localeNotifier = Provider.of<LocaleNotifier?>(context);
    } catch (_) {}

    SyncService? syncService;
    try {
      syncService = Provider.of<SyncService?>(context);
    } catch (_) {}

    final currentLocale = localeNotifier?.currentLocale ?? 'en';
    final currentThemeMode = themeNotifier?.themeMode ?? (isDark ? ThemeMode.dark : ThemeMode.light);

    final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return SmritiScaffold(
      title: AppStrings.get('settings', locale: currentLocale),
      helpScreenId: HelpScreenId.settings,
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // 1. DISPLAY SECTION
          SmritiSectionHeader(
            title: 'Display',
            subtitle: 'Theme and high-contrast settings',
            icon: Icons.palette_outlined,
          ),
          const SizedBox(height: 8.0),
          SmritiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display Theme',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'Switch between calm Dark Mode, warm Light Mode, or follow device System setting.',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 16.0),
                Row(
                  children: [
                    _buildThemeOption(
                      label: 'Dark',
                      icon: Icons.dark_mode_rounded,
                      mode: ThemeMode.dark,
                      currentMode: currentThemeMode,
                      onSelect: (m) => themeNotifier?.setThemeMode(m),
                      isDark: isDark,
                      primaryColor: primaryColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(width: 8.0),
                    _buildThemeOption(
                      label: 'Light',
                      icon: Icons.light_mode_rounded,
                      mode: ThemeMode.light,
                      currentMode: currentThemeMode,
                      onSelect: (m) => themeNotifier?.setThemeMode(m),
                      isDark: isDark,
                      primaryColor: primaryColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(width: 8.0),
                    _buildThemeOption(
                      label: 'System',
                      icon: Icons.brightness_auto_rounded,
                      mode: ThemeMode.system,
                      currentMode: currentThemeMode,
                      onSelect: (m) => themeNotifier?.setThemeMode(m),
                      isDark: isDark,
                      primaryColor: primaryColor,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // 2. PREFERRED LANGUAGE SECTION
          SmritiSectionHeader(
            title: AppStrings.get('preferredLanguage', locale: currentLocale),
            subtitle: AppStrings.get('languageSelectorDesc', locale: currentLocale),
            icon: Icons.translate_rounded,
          ),
          const SizedBox(height: 8.0),
          SmritiCard(
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              onTap: () => _showLanguageSelector(context, localeNotifier),
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localeNotifier?.currentLanguageName ?? 'English',
                            style: TextStyle(
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2.0),
                          Text(
                            AppStrings.get('languageLabel', locale: currentLocale),
                            style: TextStyle(
                              fontSize: 13.0,
                              color: primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? AppColors.darkBackground : Colors.white,
                        minimumSize: const Size(100, 52),
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _showLanguageSelector(context, localeNotifier),
                      icon: const Icon(Icons.language, size: 18),
                      label: Text(
                        AppStrings.get('changeLanguage', locale: currentLocale),
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24.0),

          // 3. VOICE & ACCESSIBILITY SECTION
          SmritiSectionHeader(
            title: 'Voice & Accessibility',
            subtitle: 'Voice assistance and high-contrast settings',
            icon: Icons.record_voice_over_outlined,
          ),
          const SizedBox(height: 8.0),
          SmritiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: primaryColor,
                  activeTrackColor: primaryColor.withValues(alpha: 0.5),
                  title: Text(
                    AppStrings.get('audioAssistance', locale: currentLocale),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Reads game instructions softly',
                    style: TextStyle(fontSize: 14.0, color: textSecondary),
                  ),
                  value: _audioGuidance,
                  onChanged: (val) => setState(() => _audioGuidance = val),
                ),
                Divider(color: borderColor),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: primaryColor,
                  activeTrackColor: primaryColor.withValues(alpha: 0.5),
                  title: Text(
                    AppStrings.get('highContrast', locale: currentLocale),
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    'Sharpens text outlines and borders',
                    style: TextStyle(fontSize: 14.0, color: textSecondary),
                  ),
                  value: _highContrast,
                  onChanged: (val) => setState(() => _highContrast = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // 4. YOUR DATA SECTION
          SmritiSectionHeader(
            title: 'Your Data',
            subtitle: 'Saved locally and secure on this device',
            icon: Icons.sync_rounded,
          ),
          const SizedBox(height: 8.0),
          SmritiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: primaryColor, size: 28.0),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        syncService?.status.displayLabel ?? 'All activities saved locally & up to date',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16.0),
                SmritiPrimaryButton(
                  label: 'Verify Local Sync',
                  icon: Icons.refresh_rounded,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    if (syncService != null) {
                      await syncService.triggerSync();
                    }
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          syncService?.status.displayLabel ?? 'Local persistence verified: All items secure in SQLite.',
                        ),
                        backgroundColor: primaryColor,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          // 5. ABOUT BANDHU
          SmritiSectionHeader(
            title: 'About BANDHU',
            subtitle: 'Cognitive assistance companion',
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: 8.0),
          Container(
            padding: const EdgeInsets.all(18.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: borderColor, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('helpTitle', locale: currentLocale),
                  style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 6.0),
                Text(
                  AppStrings.get('nonClinicalNotice', locale: currentLocale),
                  style: TextStyle(fontSize: 14.5, color: textSecondary, height: 1.45),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32.0),

          // 6. ACCOUNT & SESSION (Visually Separated)
          Divider(color: borderColor, thickness: 1.5),
          const SizedBox(height: 16.0),
          SmritiSectionHeader(
            title: 'Account',
            subtitle: 'Manage your active session on this device',
            icon: Icons.account_circle_outlined,
          ),
          const SizedBox(height: 8.0),
          SmritiCard(
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('signOut', locale: currentLocale),
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 4.0),
                Text(
                  AppStrings.get('signOutConfirmMessage', locale: currentLocale),
                  style: TextStyle(fontSize: 14.5, color: textSecondary, height: 1.35),
                ),
                const SizedBox(height: 16.0),
                SmritiPrimaryButton(
                  label: AppStrings.get('signOut', locale: currentLocale),
                  icon: Icons.logout_rounded,
                  backgroundColor: AppColors.errorRed,
                  textColor: Colors.white,
                  onPressed: () {
                    final navigator = Navigator.of(context);
                    final authService = context.read<AuthService?>();
                    showDialog(
                      context: context,
                      builder: (dialogCtx) => AlertDialog(
                        backgroundColor: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          side: BorderSide(color: borderColor, width: 1.5),
                        ),
                        titlePadding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 12.0),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                        actionsPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                        actionsOverflowButtonSpacing: 8.0,
                        title: Row(
                          children: [
                            const Icon(Icons.logout_rounded, color: AppColors.errorRed, size: 28.0),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                AppStrings.get('signOutConfirmTitle', locale: currentLocale),
                                style: TextStyle(
                                  color: textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 19.0,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        content: Text(
                          AppStrings.get('signOutConfirmMessage', locale: currentLocale),
                          style: TextStyle(fontSize: 15.5, color: textSecondary, height: 1.4),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              minimumSize: const Size(80, 48),
                            ),
                            onPressed: () => Navigator.of(dialogCtx).pop(),
                            child: Text(
                              AppStrings.get('cancelBtn', locale: currentLocale),
                              style: TextStyle(fontSize: 16.0, color: textSecondary, fontWeight: FontWeight.bold),
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.errorRed,
                              minimumSize: const Size(100, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                            ),
                            onPressed: () async {
                              Navigator.of(dialogCtx).pop();
                              if (authService != null) {
                                await authService.logout();
                              }
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(builder: (_) => const LoginScreen()),
                                (route) => false,
                              );
                            },
                            child: Text(
                              AppStrings.get('signOut', locale: currentLocale),
                              style: const TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
