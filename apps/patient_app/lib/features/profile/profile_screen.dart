import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/smriti_theme.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../core/auth/auth_service.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';

/// Patient Profile & Caregiver Connection Screen.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  final String _region = 'Assam (NER)';
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final session = context.read<AuthService?>()?.session;
      _nameController = TextEditingController(
        text: session?.anonymousAlias ?? session?.fullName ?? 'Patient',
      );
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
    final session = context.watch<AuthService?>()?.session;
    final email = session?.email ?? 'patient@example.com';
    final loc = _getLocale(context);

    return SmritiScaffold(
      title: AppStrings.get('profileTooltip', locale: loc),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          SmritiSectionHeader(
            title: AppStrings.get('patientPreferences', locale: loc),
            subtitle: AppStrings.get('patientPreferencesSubtitle', locale: loc),
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 8.0),
          SmritiCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.get('preferredName', locale: loc),
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: SmritiTheme.deepSlate),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                ),
                const SizedBox(height: 18.0),

                Text(
                  AppStrings.get('signedInEmail', locale: loc),
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: SmritiTheme.deepSlate),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: SmritiTheme.sageLight,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: SmritiTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, color: SmritiTheme.restorativeSage),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          email,
                          style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: SmritiTheme.deepSlate),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18.0),
                Text(
                  AppStrings.get('culturalRegion', locale: loc),
                  style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: SmritiTheme.deepSlate),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: SmritiTheme.sageLight,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: SmritiTheme.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: SmritiTheme.restorativeSage),
                      const SizedBox(width: 10.0),
                      Text(
                        _region,
                        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: SmritiTheme.deepSlate),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24.0),

          SmritiSectionHeader(
            title: AppStrings.get('linkedCaregiver', locale: loc),
            subtitle: AppStrings.get('linkedCaregiverSubtitle', locale: loc),
            icon: Icons.family_restroom_rounded,
          ),
          const SizedBox(height: 8.0),
          SmritiCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14.0),
                  decoration: const BoxDecoration(
                    color: SmritiTheme.sageLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_rounded, color: SmritiTheme.restorativeSage, size: 30.0),
                ),
                const SizedBox(width: 16.0),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Family Caregiver',
                        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        'Connected via Caregiver Dashboard',
                        style: TextStyle(fontSize: 15.0, color: SmritiTheme.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32.0),

          SmritiPrimaryButton(
            label: AppStrings.get('savePreferences', locale: loc),
            icon: Icons.check_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(AppStrings.get('savePreferences', locale: loc)),
                  backgroundColor: SmritiTheme.deepSlate,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
