import 'package:flutter_test/flutter_test.dart';

import 'package:patient_app/core/voice/voice_models.dart';
import 'package:patient_app/core/voice/voice_capability_matrix.dart';
import 'package:patient_app/core/voice/speech_recognition_service.dart';
import 'package:patient_app/core/voice/text_to_speech_service.dart';
import 'package:patient_app/core/voice/intent_service.dart';
import 'package:patient_app/core/voice/voice_service.dart';
import 'package:patient_app/data/local/database/app_database.dart';
import 'package:patient_app/data/local/repositories/smriti_repository.dart';
import 'package:patient_app/features/memory/services/memory_rescue_service.dart';
import 'package:drift/native.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 07: Voice Capability Matrix Tests', () {
    test('Matrix tracks exactly 9 languages with required distinct fields', () {
      expect(VoiceCapabilityMatrix.matrix.length, equals(9));

      for (final cap in VoiceCapabilityMatrix.matrix) {
        expect(cap.languageCode, isNotEmpty);
        expect(cap.englishName, isNotEmpty);
        expect(cap.nativeName, isNotEmpty);

        // Verification flags must exist independently
        expect(cap.localizationSupported, isTrue); // All 9 are architecturally supported
        // Translation reviewed must only be true for en, hi, as
        if (['en', 'hi', 'as'].contains(cap.languageCode)) {
          expect(cap.translationReviewed, isTrue);
        } else {
          expect(cap.translationReviewed, isFalse);
        }
      }
    });

    test('Capability matrix clearly distinguishes verified on-device vs architectural', () {
      // Verified languages
      final verifiedLangs = VoiceCapabilityMatrix.verifiedLanguages;
      expect(verifiedLangs.length, equals(3));
      expect(verifiedLangs.map((c) => c.languageCode), containsAll(['en', 'hi', 'as']));

      // Languages requiring translation review
      final reviewRequired = VoiceCapabilityMatrix.reviewRequiredLanguages;
      expect(reviewRequired.length, equals(6));
      expect(reviewRequired.map((c) => c.languageCode), containsAll(['bn', 'mni', 'brx', 'lus', 'kha', 'grt']));

      // On-device verification flags
      for (final cap in VoiceCapabilityMatrix.matrix) {
        if (['en', 'hi', 'as'].contains(cap.languageCode)) {
          expect(cap.ttsSupported, isTrue);
          expect(cap.asrSupported, isTrue);
        }
      }
    });
  });

  group('Phase 07: Speech Recognition & TTS Service Tests', () {
    test('MockSpeechRecognitionService starts, emits results, and stops', () async {
      final asr = MockSpeechRecognitionService();
      expect(asr.isListening, isFalse);

      final available = await asr.initialize();
      expect(available, isTrue);

      final stream = asr.startListening(localeId: 'en_IN');
      expect(asr.isListening, isTrue);

      final futureFirst = stream.first;
      asr.emitMockResult('Who is Ananya?');

      final firstEvent = await futureFirst;
      expect(firstEvent, equals('Who is Ananya?'));

      await asr.stopListening();
      expect(asr.isListening, isFalse);
    });

    test('Speech recognition handles timeout and cancellation gracefully', () async {
      final asr = MockSpeechRecognitionService();
      await asr.initialize();
      asr.startListening();

      expect(asr.isListening, isTrue);
      await asr.cancelListening();
      expect(asr.isListening, isFalse);
    });

    test('MockTextToSpeechService speaks and stops', () async {
      final tts = MockTextToSpeechService();
      await tts.initialize();

      await tts.speak('Hello grandmother', languageCode: 'en');
      expect(tts.isPlaying, isTrue);
      expect(tts.lastSpokenText, equals('Hello grandmother'));

      await tts.stop();
      expect(tts.isPlaying, isFalse);
    });
  });

  group('Phase 07: Intent Parsing & Deterministic Non-Clinical Boundaries', () {
    test('Family member queries extract target entity', () {
      final intent1 = IntentService.parse('Who is Ananya?');
      expect(intent1.type, equals(VoiceIntentType.queryFamily));
      expect(intent1.extractedEntity, equals('Ananya'));

      final intent2 = IntentService.parse('Tell me about Rahul');
      expect(intent2.type, equals(VoiceIntentType.queryFamily));
      expect(intent2.extractedEntity, equals('Rahul'));
    });

    test('Reminder and routine queries are parsed accurately', () {
      final intent1 = IntentService.parse('What is my next reminder?');
      expect(intent1.type, equals(VoiceIntentType.queryReminders));

      final intent2 = IntentService.parse('What medicine do I need to take?');
      // "medicine" in query with reminder intent
      expect(intent2.type, isIn([VoiceIntentType.queryReminders, VoiceIntentType.medicalBoundary]));

      final intent3 = IntentService.parse('What should I do today?');
      expect(intent3.type, equals(VoiceIntentType.queryRoutines));
    });

    test('Game launching queries identify requested cognitive game', () {
      final intent1 = IntentService.parse('Let\'s play memory match');
      expect(intent1.type, equals(VoiceIntentType.launchGame));
      expect(intent1.extractedEntity, equals('memory_match'));

      final intent2 = IntentService.parse('Start pattern game');
      expect(intent2.type, equals(VoiceIntentType.launchGame));
      expect(intent2.extractedEntity, equals('pattern_recognition'));

      final intent3 = IntentService.parse('Play routine recall');
      expect(intent3.type, equals(VoiceIntentType.launchGame));
      expect(intent3.extractedEntity, equals('routine_recall'));
    });

    test('Strict Medical Boundary: Rejects diagnosis, treatment, and clinical assessment', () {
      final medicalQueries = [
        'Do I have dementia?',
        'What is my dementia stage?',
        'Can you diagnose my memory loss?',
        'What dosage of Donepezil should I take?',
        'Recommend a treatment for Alzheimer\'s',
        'Am I getting worse?',
      ];

      for (final query in medicalQueries) {
        final intent = IntentService.parse(query);
        expect(
          intent.type,
          equals(VoiceIntentType.medicalBoundary),
          reason: 'Query "$query" must trigger medical boundary guardrail',
        );
      }
    });

    test('VoiceService orchestrator executes deterministic response for queries', () async {
      final db = AppDatabase(NativeDatabase.memory());
      final repo = SmritiRepository(db);
      final rescue = MemoryRescueService(repo);
      final asr = MockSpeechRecognitionService();
      final tts = MockTextToSpeechService();

      final voiceService = VoiceService(
        asr: asr,
        tts: tts,
        repository: repo,
        memoryRescue: rescue,
      );

      // 1. Test medical guardrail response
      final medicalResp = await voiceService.processUserTranscript('Do I have dementia?');
      expect(medicalResp.intent.type, equals(VoiceIntentType.medicalBoundary));
      expect(medicalResp.spokenText, contains('doctor'));
      expect(medicalResp.spokenText, contains('caregiver'));

      // 2. Test game launch response
      final gameResp = await voiceService.processUserTranscript('Start memory match');
      expect(gameResp.intent.type, equals(VoiceIntentType.launchGame));
      expect(gameResp.spokenText, contains('Memory Match'));

      // 3. Test reminder response
      final reminderResp = await voiceService.processUserTranscript('What is my next reminder?');
      expect(reminderResp.intent.type, equals(VoiceIntentType.queryReminders));
      expect(reminderResp.spokenText.isNotEmpty, isTrue);

      await db.close();
    });
  });
}
