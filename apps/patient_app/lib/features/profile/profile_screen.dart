import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/smriti_theme.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../core/widgets/smriti_section_header.dart';
import '../../core/auth/auth_service.dart';
import '../../l10n/app_strings.dart';
import '../../l10n/locale_notifier.dart';
import 'pairing_service.dart';
import 'caregiver_connection_screen.dart';
import '../help/models/help_screen_id.dart';

/// Patient Profile & Caregiver Connection Screen.
class ProfileScreen extends StatefulWidget {
  final PatientPairingService? pairingService;

  const ProfileScreen({
    super.key,
    this.pairingService,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late final PatientPairingService _pairingService;
  final String _region = 'Assam (NER)';
  bool _initialized = false;
  LinkedCaregiverInfo _caregiverInfo = LinkedCaregiverInfo.empty();
  bool _loadingCaregiver = false;

  @override
  void initState() {
    super.initState();
    _pairingService = widget.pairingService ?? PatientPairingService();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final session = context.read<AuthService?>()?.session;
      _nameController = TextEditingController(
        text: session?.anonymousAlias ?? session?.fullName ?? 'Patient',
      );
      _initialized = true;
      _fetchCaregiverInfo();
    }
  }

  Future<void> _fetchCaregiverInfo() async {
    final session = context.read<AuthService?>()?.session;
    final patientId = session?.patientId ?? session?.userId ?? 'local-patient-demo';
    final token = session?.token;
    if (!mounted) return;
    setState(() {
      _loadingCaregiver = true;
    });

    final info = await _pairingService.getPatientCaregiver(
      patientId: patientId,
      authToken: token,
    );

    if (!mounted) return;
    setState(() {
      _caregiverInfo = info;
      _loadingCaregiver = false;
    });
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
    final isDark = SmritiTheme.isDarkMode(context);
    final textPrimary = SmritiTheme.textPrimaryColor(context);
    final textSecondary = SmritiTheme.textSecondaryColor(context);
    final subtleBg = isDark ? const Color(0xFF273239) : SmritiTheme.sageLight;
    final borderColor = isDark ? AppColors.darkBorder : SmritiTheme.borderSubtle;

    return SmritiScaffold(
      title: AppStrings.get('profileTooltip', locale: loc),
      helpScreenId: HelpScreenId.profile,
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
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 8.0),
                TextField(
                  controller: _nameController,
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: textPrimary),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  ),
                ),
                const SizedBox(height: 18.0),

                Text(
                  AppStrings.get('signedInEmail', locale: loc),
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: subtleBg,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email_outlined, color: SmritiTheme.restorativeSage),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Text(
                          email,
                          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600, color: textPrimary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18.0),
                Text(
                  AppStrings.get('culturalRegion', locale: loc),
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                const SizedBox(height: 8.0),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                  decoration: BoxDecoration(
                    color: subtleBg,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: SmritiTheme.restorativeSage),
                      const SizedBox(width: 10.0),
                      Text(
                        _region,
                        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: textPrimary),
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
            child: _loadingCaregiver
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Center(
                      child: CircularProgressIndicator(color: SmritiTheme.restorativeSage),
                    ),
                  )
                : _caregiverInfo.connected
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14.0),
                                decoration: BoxDecoration(
                                  color: subtleBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.favorite_rounded, color: SmritiTheme.restorativeSage, size: 30.0),
                              ),
                              const SizedBox(width: 16.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _caregiverInfo.caregiverName?.isNotEmpty == true
                                          ? _caregiverInfo.caregiverName!
                                          : 'Caregiver',
                                      style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: textPrimary),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      _caregiverInfo.relationship?.isNotEmpty == true
                                          ? _caregiverInfo.relationship!
                                          : 'Family Caregiver',
                                      style: TextStyle(fontSize: 14.5, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.green.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 14.0, color: Colors.green),
                                    SizedBox(width: 4.0),
                                    Text('Connected', style: TextStyle(color: Colors.green, fontSize: 12.0, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14.0),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: SmritiTheme.restorativeSage,
                              side: const BorderSide(color: SmritiTheme.restorativeSage),
                              minimumSize: const Size.fromHeight(44.0),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                            ),
                            icon: const Icon(Icons.sync_rounded, size: 18.0),
                            label: const Text('Pair New / Change Caregiver'),
                            onPressed: () async {
                              final changed = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => CaregiverConnectionScreen(pairingService: _pairingService),
                                ),
                              );
                              if (changed == true) {
                                _fetchCaregiverInfo();
                              }
                            },
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: subtleBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.link_off_rounded, color: SmritiTheme.restorativeSage, size: 28.0),
                              ),
                              const SizedBox(width: 14.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'No Caregiver Connected',
                                      style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: textPrimary),
                                    ),
                                    const SizedBox(height: 2.0),
                                    Text(
                                      'Connect your device to enable caregiver monitoring.',
                                      style: TextStyle(fontSize: 13.5, color: textSecondary),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16.0),
                          SmritiPrimaryButton(
                            label: 'Connect with Caregiver',
                            icon: Icons.qr_code_scanner_rounded,
                            onPressed: () async {
                              final changed = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (ctx) => CaregiverConnectionScreen(pairingService: _pairingService),
                                ),
                              );
                              if (changed == true) {
                                _fetchCaregiverInfo();
                              }
                            },
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
                  backgroundColor: isDark ? const Color(0xFF273239) : SmritiTheme.deepSlate,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

