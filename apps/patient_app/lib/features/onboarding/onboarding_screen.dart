import 'package:flutter/material.dart';
import '../../core/theme/smriti_theme.dart';
import '../../core/widgets/smriti_scaffold.dart';
import '../../core/widgets/smriti_card.dart';
import '../../core/widgets/smriti_primary_button.dart';
import '../../l10n/app_strings.dart';
import '../../core/widgets/smriti_app_shell.dart';

/// Elderly-Friendly Onboarding: Accessible preference selection.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String _selectedLanguage = 'en';
  String _fontSize = 'Large';
  bool _highContrast = false;
  bool _audioGuidance = true;

  final List<Map<String, String>> _languages = [
    {'code': 'en', 'label': 'English', 'native': 'English'},
    {'code': 'hi', 'label': 'Hindi', 'native': 'हिन्दी'},
    {'code': 'as', 'label': 'Assamese', 'native': 'অসমীয়া'},
  ];

  @override
  Widget build(BuildContext context) {
    return SmritiScaffold(
      title: 'Welcome to SMRITI',
      showBackButton: false,
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Let’s make this comfortable for you',
            style: TextStyle(
              fontSize: 26.0,
              fontWeight: FontWeight.bold,
              color: SmritiTheme.deepSlate,
            ),
          ),
          const SizedBox(height: 8.0),
          const Text(
            'Select your preferred language and reading preferences. You can change these anytime.',
            style: TextStyle(fontSize: 18.0, color: SmritiTheme.mutedText, height: 1.4),
          ),
          const SizedBox(height: 28.0),

          // Language Selection
          const Text(
            'Preferred Language',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: SmritiTheme.deepSlate),
          ),
          const SizedBox(height: 12.0),
          ..._languages.map((lang) {
            final isSelected = _selectedLanguage == lang['code'];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: SmritiCard(
                borderColor: isSelected ? SmritiTheme.restorativeSage : SmritiTheme.borderSubtle,
                backgroundColor: isSelected ? SmritiTheme.sageLight : Colors.white,
                onTap: () {
                  setState(() {
                    _selectedLanguage = lang['code']!;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                      size: 32.0,
                      color: isSelected ? SmritiTheme.restorativeSage : SmritiTheme.mutedText,
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang['native']!,
                            style: const TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            lang['label']!,
                            style: const TextStyle(fontSize: 16.0, color: SmritiTheme.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 24.0),

          // Reading Size
          const Text(
            'Text Display Size',
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: SmritiTheme.deepSlate),
          ),
          const SizedBox(height: 12.0),
          Row(
            children: ['Standard', 'Large', 'Extra Large'].map((size) {
              final isSelected = _fontSize == size;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: isSelected ? SmritiTheme.deepSlate : Colors.white,
                      foregroundColor: isSelected ? Colors.white : SmritiTheme.deepSlate,
                      side: BorderSide(
                        color: isSelected ? SmritiTheme.deepSlate : SmritiTheme.borderSubtle,
                        width: 2.0,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.0)),
                    ),
                    onPressed: () {
                      setState(() {
                        _fontSize = size;
                      });
                    },
                    child: Text(
                      size,
                      style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24.0),

          // Accessibility Toggles
          SmritiCard(
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: SmritiTheme.restorativeSage,
                  title: const Text(
                    'High Contrast Mode',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Enhances text and border sharpness',
                    style: TextStyle(fontSize: 15.0, color: SmritiTheme.mutedText),
                  ),
                  value: _highContrast,
                  onChanged: (val) => setState(() => _highContrast = val),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: SmritiTheme.restorativeSage,
                  title: const Text(
                    'Spoken Voice Guidance',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  subtitle: const Text(
                    'Speaks directions gently in your language',
                    style: TextStyle(fontSize: 15.0, color: SmritiTheme.mutedText),
                  ),
                  value: _audioGuidance,
                  onChanged: (val) => setState(() => _audioGuidance = val),
                ),
              ],
            ),
          ),

          const SizedBox(height: 36.0),

          SmritiPrimaryButton(
            label: AppStrings.get('continueBtn', locale: _selectedLanguage),
            icon: Icons.check_circle_outline_rounded,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => SmritiAppShell(currentLocale: _selectedLanguage),
                ),
              );
            },
          ),
          const SizedBox(height: 24.0),
        ],
      ),
    );
  }
}
