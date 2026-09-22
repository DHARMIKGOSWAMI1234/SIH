import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:patient_app/l10n/app_strings.dart';
import 'package:patient_app/l10n/locale_notifier.dart';
import 'package:patient_app/core/auth/auth_storage.dart';
import 'package:patient_app/features/home/home_screen.dart';
import 'package:patient_app/features/settings/settings_screen.dart';
import 'package:patient_app/core/voice/widgets/voice_interaction_sheet.dart';
import 'package:patient_app/core/voice/voice_service.dart';
import 'package:patient_app/core/voice/speech_recognition_service.dart';
import 'package:patient_app/core/voice/text_to_speech_service.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/features/memory/services/memory_rescue_service.dart';
import 'package:drift/native.dart';

void main() {
  group('Phase 07: 9-Language Localization Specification Tests', () {
    test('Exactly 9 supported languages are defined (no more, no less)', () {
      expect(AppStrings.supportedLanguages.length, equals(9));

      final codes = AppStrings.supportedLanguages.map((l) => l.code).toList();
      expect(codes, containsAll([
        'en', // English
        'hi', // Hindi
        'as', // Assamese
        'bn', // Bengali
        'mni', // Meitei/Manipuri
        'brx', // Bodo
        'lus', // Mizo
        'kha', // Khasi
        'grt', // Garo
      ]));
    });

    test('Verification statuses match specification', () {
      // Fully translation-verified: English, Hindi, Assamese
      expect(AppStrings.isLanguageReviewed('en'), isTrue);
      expect(AppStrings.isLanguageReviewed('hi'), isTrue);
      expect(AppStrings.isLanguageReviewed('as'), isTrue);

      // Architecturally supported / requires translation review
      expect(AppStrings.isLanguageReviewed('bn'), isFalse);
      expect(AppStrings.isLanguageReviewed('mni'), isFalse);
      expect(AppStrings.isLanguageReviewed('brx'), isFalse);
      expect(AppStrings.isLanguageReviewed('lus'), isFalse);
      expect(AppStrings.isLanguageReviewed('kha'), isFalse);
      expect(AppStrings.isLanguageReviewed('grt'), isFalse);
    });

    test('Deterministic fallback to English for unreviewed or missing keys', () {
      // In 'kha' (Khasi), 'todaySectionTitle' falls back to English 'Today'
      final khasiToday = AppStrings.get('todaySectionTitle', locale: 'kha');
      expect(khasiToday, equals('Today'));

      // In 'mni' (Meitei), starter key 'navHome' exists
      final mniHome = AppStrings.get('navHome', locale: 'mni');
      expect(mniHome, equals('য়ুম'));

      // In 'hi' (Hindi), verified translation exists
      final hiGoodMorning = AppStrings.get('goodMorning', locale: 'hi');
      expect(hiGoodMorning, equals('शुभ प्रभात'));

      // In 'as' (Assamese), verified translation exists
      final asGoodMorning = AppStrings.get('goodMorning', locale: 'as');
      expect(asGoodMorning, equals('শুভ প্ৰভাত'));
    });

    test('All authentication UI strings resolve for all 9 languages without raw keys or blank values', () {
      final authKeys = [
        'loginTitle',
        'patientSignIn',
        'welcomeBack',
        'loginSubtitle',
        'registerTitle',
        'registerSubtitle',
        'emailLabel',
        'emailHint',
        'passwordLabel',
        'passwordHint',
        'confirmPasswordLabel',
        'confirmPasswordHint',
        'fullNameLabel',
        'fullNameHint',
        'roleLabel',
        'rolePatient',
        'roleCaregiver',
        'loginBtn',
        'registerBtn',
        'newPatient',
        'signInToSmriti',
        'completeRegistration',
        'noAccountPrompt',
        'hasAccountPrompt',
        'invalidCredentials',
        'emailRequired',
        'invalidEmail',
        'passwordRequired',
        'nameRequired',
        'registrationSuccess',
        'signOut',
        'signOutConfirmTitle',
        'signOutConfirmMessage',
        'cancelBtn',
        'confirmBtn',
        'internetRequiredForRegistration',
        'connectionFailed',
        'savedDataOffline',
        'reauthenticatePrompt',
        'registrationFailed',
        'accountAlreadyExists',
        'serverError',
        'somethingWentWrong',
        'forgotPassword',
        'passwordRequirements',
        'showPassword',
        'hidePassword',
        'preferredLanguage',
        'languageLabel',
        'offlineReady',
      ];

      for (final lang in AppStrings.supportedLanguages) {
        for (final key in authKeys) {
          final val = AppStrings.get(key, locale: lang.code);
          expect(val, isNotNull, reason: 'Key $key in ${lang.code} should not be null');
          expect(val.trim().isNotEmpty, isTrue, reason: 'Key $key in ${lang.code} should not be empty');
          expect(val, isNot(equals(key)), reason: 'Key $key in ${lang.code} should not return the raw key');
        }
      }
    });

    test('Non-English languages resolve localized authentication strings without English fallback', () {
      final nonEnglish = ['hi', 'as', 'bn', 'mni', 'brx', 'lus', 'kha', 'grt'];
      const key = 'registerTitle';
      final enVal = AppStrings.get(key, locale: 'en');

      for (final code in nonEnglish) {
        final val = AppStrings.get(key, locale: code);
        expect(val, isNot(equals(enVal)), reason: 'Language $code should have its own translation for $key');
      }
    });

    test('Never returns null, blank string, or broken placeholder', () {
      for (final lang in AppStrings.supportedLanguages) {
        final val = AppStrings.get('appName', locale: lang.code);
        expect(val, isNotNull);
        expect(val.trim().isNotEmpty, isTrue);
        expect(val, isNot(contains('null')));
        expect(val, isNot(contains('undefined')));
      }
    });

    test('Missing key returns key identifier itself as safe fallback', () {
      const nonExistentKey = 'non_existent_string_key_123';
      final result = AppStrings.get(nonExistentKey, locale: 'hi');
      expect(result, equals(nonExistentKey));
    });

    test('LocaleNotifier persists language selection in AuthStorage', () async {
      final storage = InMemoryAuthStorage();
      final notifier = LocaleNotifier(authStorage: storage);

      expect(notifier.currentLocale, equals('en'));

      await notifier.setLocale('hi');
      expect(notifier.currentLocale, equals('hi'));
      expect(await storage.getPreferredLanguage(), equals('hi'));

      await notifier.setLocale('as');
      expect(notifier.currentLocale, equals('as'));
      expect(await storage.getPreferredLanguage(), equals('as'));

      // Reject unsupported language
      await notifier.setLocale('es');
      expect(notifier.currentLocale, equals('as'));
    });
  });

  group('Phase 07: Responsive Layout & Zero Overflow Testing', () {
    final testWidths = [320.0, 360.0, 390.0, 412.0, 430.0];

    for (final width in testWidths) {
      testWidgets('HomeScreen in Hindi renders with zero overflow at ${width.toInt()}dp', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HomeScreen(currentLocale: 'hi'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('शुभ प्रभात'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('HomeScreen in Assamese renders with zero overflow at ${width.toInt()}dp', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: HomeScreen(currentLocale: 'as'),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('শুভ প্ৰভাত'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('SettingsScreen in Hindi renders with zero overflow at ${width.toInt()}dp', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final storage = InMemoryAuthStorage();
        final localeNotifier = LocaleNotifier(authStorage: storage, initialLocale: 'hi');

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<LocaleNotifier>.value(value: localeNotifier),
            ],
            child: const MaterialApp(
              home: SettingsScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('सेटिंग्स और सुगमता'), findsWidgets);
        expect(tester.takeException(), isNull);
      });

      testWidgets('VoiceInteractionSheet renders with zero overflow at ${width.toInt()}dp', (tester) async {
        tester.view.physicalSize = Size(width, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final mockAsr = MockSpeechRecognitionService();
        final mockTts = MockTextToSpeechService();
        final voiceService = VoiceService(asr: mockAsr, tts: mockTts);
        final db = AppDatabase(NativeDatabase.memory());
        final repo = SmritiRepository(db);
        final rescue = MemoryRescueService(repo);

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VoiceInteractionSheet(
                voiceService: voiceService,
                memoryRescue: rescue,
                repository: repo,
                locale: const Locale('hi'),
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);
        await db.close();
      });
    }
  });
}
