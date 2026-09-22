import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/smriti_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'core/auth/auth_storage.dart';
import 'core/auth/auth_service.dart';
import 'core/voice/voice_service.dart';
import 'data/remote/sync_api_client.dart';
import 'data/local/database/app_database.dart';
import 'data/local/repositories/smriti_repository.dart';
import 'data/local/sync/sync_manager.dart';
import 'data/local/sync/sync_service.dart';
import 'features/splash/splash_screen.dart';
import 'l10n/framework_locale_mapper.dart';
import 'l10n/locale_notifier.dart';
import 'core/config/api_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();
  final repository = SmritiRepository(database);
  final authStorage = SecureAuthStorage();
  final baseUrl = ApiConfig.defaultBaseUrl;
  final apiClient = SyncApiClient(baseUrl: baseUrl);
  final authService = AuthService(
    storage: authStorage,
    apiClient: apiClient,
    repository: repository,
    baseUrl: baseUrl,
  );
  final syncManager = SyncManager(
    repository: repository,
    apiClient: apiClient,
  );
  final syncService = SyncService(manager: syncManager);
  final localeNotifier = LocaleNotifier(
    authStorage: authStorage,
    authService: authService,
  );
  await localeNotifier.initialize();
  final themeNotifier = ThemeNotifier(storage: authStorage);
  await themeNotifier.initialize();
  final voiceService = VoiceService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: database),
        Provider<SmritiRepository>.value(value: repository),
        Provider<AuthStorage>.value(value: authStorage),
        Provider<SyncApiClient>.value(value: apiClient),
        ChangeNotifierProvider<SyncManager>.value(value: syncManager),
        ChangeNotifierProvider<AuthService>.value(value: authService),
        ChangeNotifierProvider<SyncService>.value(value: syncService),
        ChangeNotifierProvider<LocaleNotifier>.value(value: localeNotifier),
        ChangeNotifierProvider<ThemeNotifier>.value(value: themeNotifier),
        ChangeNotifierProvider<VoiceService>.value(value: voiceService),
      ],
      child: const SmritiApp(),
    ),
  );
}


class SmritiApp extends StatelessWidget {
  final AppDatabase? database;
  final SmritiRepository? repository;
  final AuthStorage? authStorage;
  final SyncApiClient? apiClient;
  final AuthService? authService;
  final SyncService? syncService;
  final LocaleNotifier? localeNotifier;
  final ThemeNotifier? themeNotifier;
  final VoiceService? voiceService;

  const SmritiApp({
    super.key,
    this.database,
    this.repository,
    this.authStorage,
    this.apiClient,
    this.authService,
    this.syncService,
    this.localeNotifier,
    this.themeNotifier,
    this.voiceService,
  });

  @override
  Widget build(BuildContext context) {
    Widget buildApp(BuildContext ctx) {
      final locNotifier = Provider.of<LocaleNotifier>(ctx);
      final thmNotifier = Provider.of<ThemeNotifier?>(ctx);

      return MaterialApp(
        title: 'SMRITI — AI Cognitive Care Companion',
        debugShowCheckedModeBanner: false,
        theme: SmritiTheme.lightTheme,
        darkTheme: SmritiTheme.darkTheme,
        themeMode: thmNotifier?.themeMode ?? ThemeMode.dark,
        locale: locNotifier.frameworkLocale,
        supportedLocales: FrameworkLocaleMapper.supportedFrameworkLocales,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        localeResolutionCallback: FrameworkLocaleMapper.resolveLocale,
        home: const SplashScreen(),
      );
    }

    // If providers already exist in context, build MaterialApp with existing providers
    try {
      Provider.of<AuthService>(context, listen: false);
      Provider.of<LocaleNotifier>(context, listen: false);
      return buildApp(context);
    } catch (_) {
      // Fallback for isolated widget tests or tests that mount SmritiApp directly
      final db = database ?? AppDatabase();
      final repo = repository ?? SmritiRepository(db);
      final storage = authStorage ?? InMemoryAuthStorage();
      final client = apiClient ?? SyncApiClient();
      final auth = authService ??
          AuthService(
            storage: storage,
            apiClient: client,
            repository: repo,
          );
      final sync = syncService ?? SyncService();
      final loc = localeNotifier ??
          LocaleNotifier(
            authStorage: storage,
            authService: auth,
          );
      final thm = themeNotifier ?? ThemeNotifier(storage: storage);
      final voice = voiceService ?? VoiceService();

      return MultiProvider(
        providers: [
          Provider<AppDatabase>.value(value: db),
          Provider<SmritiRepository>.value(value: repo),
          Provider<AuthStorage>.value(value: storage),
          Provider<SyncApiClient>.value(value: client),
          ChangeNotifierProvider<AuthService>.value(value: auth),
          ChangeNotifierProvider<SyncService>.value(value: sync),
          ChangeNotifierProvider<LocaleNotifier>.value(value: loc),
          ChangeNotifierProvider<ThemeNotifier>.value(value: thm),
          ChangeNotifierProvider<VoiceService>.value(value: voice),
        ],
        child: Builder(builder: buildApp),
      );
    }
  }
}

