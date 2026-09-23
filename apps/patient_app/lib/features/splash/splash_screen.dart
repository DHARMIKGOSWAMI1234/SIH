import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/smriti_theme.dart';
import '../../core/auth/auth_service.dart';
import '../../core/widgets/smriti_app_shell.dart';
import '../auth/login_screen.dart';

/// Splash Screen: Warm, calm loading and initialization.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    final authService = context.read<AuthService?>();
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 1400)),
      if (authService != null) authService.checkSession(),
    ]);

    if (!mounted) return;

    if (authService != null && authService.isAuthenticated) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SmritiAppShell(
            currentLocale: authService.session?.preferredLanguage ?? 'en',
          ),
        ),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmritiTheme.warmCream,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.0,
                height: 120.0,
                decoration: BoxDecoration(
                  color: SmritiTheme.restorativeSage,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: SmritiTheme.restorativeSage.withValues(alpha: 0.25),
                      blurRadius: 24.0,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  size: 64.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32.0),
              const Text(
                'BANDHU',
                style: TextStyle(
                  fontSize: 38.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: SmritiTheme.deepSlate,
                ),
              ),
              const SizedBox(height: 12.0),
              const Text(
                'AI Cognitive Care Companion',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w500,
                  color: SmritiTheme.mutedText,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'North Eastern Region (NER)',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  color: SmritiTheme.restorativeSage,
                ),
              ),
              const SizedBox(height: 48.0),
              const SizedBox(
                width: 48.0,
                height: 48.0,
                child: CircularProgressIndicator(
                  strokeWidth: 4.0,
                  valueColor: AlwaysStoppedAnimation<Color>(SmritiTheme.restorativeSage),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
