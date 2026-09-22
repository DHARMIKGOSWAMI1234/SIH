import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:drift/native.dart';

import 'package:patient_app/core/theme/smriti_theme.dart';
import 'package:patient_app/core/auth/auth_storage.dart';
import 'package:patient_app/core/auth/auth_service.dart';
import 'package:patient_app/core/voice/voice_service.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/local/sync/sync_service.dart';
import 'package:patient_app/data/remote/sync_api_client.dart';
import 'package:patient_app/l10n/app_strings.dart';
import 'package:patient_app/l10n/framework_locale_mapper.dart';
import 'package:patient_app/l10n/locale_notifier.dart';
import 'package:patient_app/features/settings/settings_screen.dart';
import 'package:patient_app/core/widgets/smriti_app_shell.dart';

void main() {
  const all9Languages = [
    'en', // English
    'hi', // Hindi
    'as', // Assamese
    'bn', // Bengali
    'mni', // Meitei / Manipuri
    'brx', // Bodo
    'lus', // Mizo
    'kha', // Khasi
    'grt', // Garo
  ];

  group('FrameworkLocaleMapper Unit Tests', () {
    test('Maps natively supported Flutter Material locales directly', () {
      expect(FrameworkLocaleMapper.toFrameworkLocale('en'), const Locale('en'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('hi'), const Locale('hi'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('as'), const Locale('as'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('bn'), const Locale('bn'));
    });

    test('Safely maps regional North-East locales to fallback en without crashing', () {
      expect(FrameworkLocaleMapper.toFrameworkLocale('mni'), const Locale('en'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('brx'), const Locale('en'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('lus'), const Locale('en'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('kha'), const Locale('en'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('grt'), const Locale('en'));
      expect(FrameworkLocaleMapper.toFrameworkLocale('unknown'), const Locale('en'));
    });

    test('isFrameworkSupported identifies built-in vs regional locales', () {
      expect(FrameworkLocaleMapper.isFrameworkSupported('en'), isTrue);
      expect(FrameworkLocaleMapper.isFrameworkSupported('hi'), isTrue);
      expect(FrameworkLocaleMapper.isFrameworkSupported('as'), isTrue);
      expect(FrameworkLocaleMapper.isFrameworkSupported('bn'), isTrue);

      expect(FrameworkLocaleMapper.isFrameworkSupported('mni'), isFalse);
      expect(FrameworkLocaleMapper.isFrameworkSupported('brx'), isFalse);
      expect(FrameworkLocaleMapper.isFrameworkSupported('lus'), isFalse);
      expect(FrameworkLocaleMapper.isFrameworkSupported('kha'), isFalse);
      expect(FrameworkLocaleMapper.isFrameworkSupported('grt'), isFalse);
    });

    test('resolveLocale safely resolves unsupported or null locales to English', () {
      final supported = FrameworkLocaleMapper.supportedFrameworkLocales;
      expect(FrameworkLocaleMapper.resolveLocale(null, supported), const Locale('en'));
      expect(FrameworkLocaleMapper.resolveLocale(const Locale('kha'), supported), const Locale('en'));
      expect(FrameworkLocaleMapper.resolveLocale(const Locale('hi'), supported), const Locale('hi'));
      expect(FrameworkLocaleMapper.resolveLocale(const Locale('bn'), supported), const Locale('bn'));
      expect(FrameworkLocaleMapper.resolveLocale(const Locale('as'), supported), const Locale('as'));
    });
  });

  group('MaterialLocalizations Availability for All 9 SMRITI Languages', () {
    for (final langCode in all9Languages) {
      testWidgets('MaterialLocalizations is available in widget tree for $langCode', (tester) async {
        final storage = InMemoryAuthStorage();
        final notifier = LocaleNotifier(authStorage: storage, initialLocale: langCode);

        MaterialLocalizations? foundLocalizations;

        await tester.pumpWidget(
          ChangeNotifierProvider<LocaleNotifier>.value(
            value: notifier,
            child: Consumer<LocaleNotifier>(
              builder: (context, loc, _) {
                return MaterialApp(
                  locale: loc.frameworkLocale,
                  supportedLocales: FrameworkLocaleMapper.supportedFrameworkLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: FrameworkLocaleMapper.resolveLocale,
                  home: Builder(
                    builder: (ctx) {
                      foundLocalizations = MaterialLocalizations.of(ctx);
                      return Scaffold(
                        appBar: AppBar(title: const Text('Test')),
                        body: Text('Language: ${loc.currentLocale}'),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. MaterialLocalizations must be found
        expect(foundLocalizations, isNotNull, reason: 'MaterialLocalizations was null for $langCode');

        // 2. Zero errors or exceptions thrown
        expect(tester.takeException(), isNull);

        // 3. SMRITI application language is still the selected language
        expect(notifier.currentLocale, equals(langCode));
      });
    }
  });

  group('AppStrings Independence from Framework Locale', () {
    test('All 9 languages return their respective localized strings', () {
      for (final langCode in all9Languages) {
        final appName = AppStrings.get('appName', locale: langCode);
        expect(appName, isNotEmpty);
        expect(appName, contains('SMRITI'));

        final today = AppStrings.get('todaySectionTitle', locale: langCode);
        expect(today, isNotEmpty);

        final settings = AppStrings.get('settings', locale: langCode);
        expect(settings, isNotEmpty);
      }
    });

    test('Khasi (kha) specifically renders distinct language strings', () {
      expect(AppStrings.get('goodMorning', locale: 'kha'), equals('Khublei step'));
      expect(AppStrings.get('navGames', locale: 'kha'), equals('Ki Jingialehkai'));
      expect(AppStrings.get('navReminders', locale: 'kha'), equals('Ki Jingpynkynmaw'));
    });

    test('Meitei (mni) specifically renders distinct language strings', () {
      expect(AppStrings.get('navHome', locale: 'mni'), equals('য়ুম'));
      expect(AppStrings.get('navGames', locale: 'mni'), equals('শান্নবশিং'));
      expect(AppStrings.get('goodMorning', locale: 'mni'), equals('য়াহিপ ফারগে'));
    });
  });

  group('SettingsScreen Language Selector in All 9 Languages', () {
    for (final langCode in all9Languages) {
      testWidgets('SettingsScreen opens language selector cleanly for $langCode', (tester) async {
        final storage = InMemoryAuthStorage();
        final notifier = LocaleNotifier(authStorage: storage, initialLocale: langCode);

        await tester.pumpWidget(
          ChangeNotifierProvider<LocaleNotifier>.value(
            value: notifier,
            child: Consumer<LocaleNotifier>(
              builder: (context, loc, _) {
                return MaterialApp(
                  theme: SmritiTheme.lightTheme,
                  locale: loc.frameworkLocale,
                  supportedLocales: FrameworkLocaleMapper.supportedFrameworkLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: FrameworkLocaleMapper.resolveLocale,
                  home: const SettingsScreen(),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Verify no crash on initial display
        expect(tester.takeException(), isNull);

        // Find the "Change Language" button or language card
        final changeLangBtn = find.text(AppStrings.get('changeLanguage', locale: langCode));
        expect(changeLangBtn, findsOneWidget);

        // Tap to open bottom sheet
        await tester.tap(changeLangBtn);
        await tester.pumpAndSettle();

        // Verify bottom sheet opened
        expect(find.byType(ListView), findsWidgets);
        expect(find.text(AppStrings.get('languageSelectorTitle', locale: langCode)), findsOneWidget);

        // Verify language list tiles are rendered
        expect(find.byType(ListTile), findsWidgets);
        expect(find.text('English'), findsWidgets);

        // Verify checkmark is present (scroll if necessary)
        await tester.scrollUntilVisible(
          find.byIcon(Icons.check_circle_rounded),
          50.0,
          scrollable: find.byType(Scrollable).last,
        );
        expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

        // Close bottom sheet
        final closeBtn = find.text(AppStrings.get('close', locale: langCode));
        expect(closeBtn, findsOneWidget);
        await tester.tap(closeBtn);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
      });
    }
  });

  group('SmritiAppShell Zero Crash & Zero Overflow in All 9 Languages', () {
    late AppDatabase db;
    late SmritiRepository repo;
    late InMemoryAuthStorage storage;
    late SyncApiClient apiClient;
    late AuthService authService;
    late SyncService syncService;
    late VoiceService voiceService;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = SmritiRepository(db);
      storage = InMemoryAuthStorage();
      apiClient = SyncApiClient();
      authService = AuthService(storage: storage, apiClient: apiClient, repository: repo);
      syncService = SyncService();
      voiceService = VoiceService();
    });

    tearDown(() async {
      await db.close();
    });

    for (final langCode in all9Languages) {
      testWidgets('SmritiAppShell renders cleanly in $langCode with zero errors', (tester) async {
        final locNotifier = LocaleNotifier(authStorage: storage, initialLocale: langCode);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppDatabase>.value(value: db),
              Provider<SmritiRepository>.value(value: repo),
              Provider<AuthStorage>.value(value: storage),
              Provider<SyncApiClient>.value(value: apiClient),
              ChangeNotifierProvider<AuthService>.value(value: authService),
              ChangeNotifierProvider<SyncService>.value(value: syncService),
              ChangeNotifierProvider<LocaleNotifier>.value(value: locNotifier),
              ChangeNotifierProvider<VoiceService>.value(value: voiceService),
            ],
            child: Consumer<LocaleNotifier>(
              builder: (context, loc, _) {
                return MaterialApp(
                  theme: SmritiTheme.lightTheme,
                  locale: loc.frameworkLocale,
                  supportedLocales: FrameworkLocaleMapper.supportedFrameworkLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: FrameworkLocaleMapper.resolveLocale,
                  home: SmritiAppShell(currentLocale: loc.currentLocale),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // 1. Zero MaterialLocalizations exception
        expect(tester.takeException(), isNull);

        // 2. AppBar is rendered cleanly
        expect(find.byType(AppBar), findsOneWidget);

        // 3. Settings button is present in AppBar
        expect(find.byIcon(Icons.settings_outlined), findsOneWidget);

        // 4. Verify switching language dynamically updates UI
        final targetLang = langCode == 'kha' ? 'hi' : 'kha';
        await locNotifier.setLocale(targetLang);
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(locNotifier.currentLocale, equals(targetLang));
      });
    }
  });

  group('Responsive Viewport Tests (320dp - 430dp) with Language Selector', () {
    const viewports = [320.0, 360.0, 390.0, 412.0, 430.0];

    for (final width in viewports) {
      testWidgets('SettingsScreen language bottom sheet renders with zero overflow at ${width.toInt()}dp', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final storage = InMemoryAuthStorage();
        final notifier = LocaleNotifier(authStorage: storage, initialLocale: 'kha');

        await tester.pumpWidget(
          ChangeNotifierProvider<LocaleNotifier>.value(
            value: notifier,
            child: Consumer<LocaleNotifier>(
              builder: (context, loc, _) {
                return MaterialApp(
                  theme: SmritiTheme.lightTheme,
                  locale: loc.frameworkLocale,
                  supportedLocales: FrameworkLocaleMapper.supportedFrameworkLocales,
                  localizationsDelegates: const [
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],
                  localeResolutionCallback: FrameworkLocaleMapper.resolveLocale,
                  home: const SettingsScreen(),
                );
              },
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Open language selector
        final changeLangBtn = find.text(AppStrings.get('changeLanguage', locale: 'kha'));
        await tester.tap(changeLangBtn);
        await tester.pumpAndSettle();

        // Zero overflow
        expect(tester.takeException(), isNull);
      });
    }
  });
}
