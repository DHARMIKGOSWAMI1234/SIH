import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/features/profile/pairing_service.dart';
import 'package:patient_app/features/profile/caregiver_connection_screen.dart';

class MockPairingService extends PatientPairingService {
  bool validateCalled = false;
  bool confirmCalled = false;
  String? lastCode;
  String? lastQrPayload;

  @override
  Future<PairingValidationResult> validatePairing({
    String? shortCode,
    String? pairingToken,
    String? qrPayload,
    String? authToken,
  }) async {
    validateCalled = true;
    lastCode = shortCode;
    lastQrPayload = qrPayload;

    if (shortCode == '4827' || qrPayload?.contains('token=tok_demo') == true || pairingToken == 'tok_demo') {
      return const PairingValidationResult(
        valid: true,
        pairingToken: 'tok_demo',
        caregiverId: 'cg-123',
        caregiverName: 'Dr. Test Caregiver',
        relationship: 'Primary Caregiver',
        permissions: 'full',
      );
    }
    return const PairingValidationResult(
      valid: false,
      error: 'Invalid connection code. Please check with your caregiver.',
    );
  }

  @override
  Future<PairingConfirmationResult> confirmPairing({
    required String pairingToken,
    required String patientId,
    String? authToken,
  }) async {
    confirmCalled = true;
    return const PairingConfirmationResult(
      success: true,
      caregiverId: 'cg-123',
      caregiverName: 'Dr. Test Caregiver',
      relationship: 'Primary Caregiver',
    );
  }

  @override
  Future<LinkedCaregiverInfo> getPatientCaregiver({
    required String patientId,
    String? authToken,
  }) async {
    return const LinkedCaregiverInfo(
      connected: true,
      caregiverId: 'cg-123',
      caregiverName: 'Dr. Test Caregiver',
      relationship: 'Primary Caregiver',
    );
  }
}

void main() {
  group('PatientPairingService URI Parsing Tests', () {
    test('parses smriti:// custom URI with token and code', () {
      const uri = 'smriti://pair?token=test_token_abc123&code=4827';
      final params = PatientPairingService.parseQrPayload(uri);
      expect(params['token'], 'test_token_abc123');
      expect(params['code'], '4827');
    });

    test('parses raw 4-digit code as fallback', () {
      final params = PatientPairingService.parseQrPayload('9182');
      expect(params['code'], '9182');
    });

    test('parses raw token parameter substring', () {
      final params = PatientPairingService.parseQrPayload('random_text_token=secret_tok_456');
      expect(params['token'], 'secret_tok_456');
    });
  });

  group('CaregiverConnectionScreen Widget Tests', () {
    testWidgets('enters 4 digits and confirms connection dialog', (WidgetTester tester) async {
      final mockService = MockPairingService();

      await tester.pumpWidget(
        MaterialApp(
          home: CaregiverConnectionScreen(
            pairingService: mockService,
          ),
        ),
      );

      expect(find.text('Caregiver Pairing'), findsOneWidget);
      expect(find.text('4-Digit Code'), findsOneWidget);

      // Tap '4', '8', '2', '7'
      await tester.tap(find.text('4'));
      await tester.pump();
      await tester.tap(find.text('8'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('7'));
      await tester.pumpAndSettle();

      expect(mockService.validateCalled, isTrue);
      expect(mockService.lastCode, '4827');

      // Confirmation dialog appears
      expect(find.text('Confirm Caregiver'), findsOneWidget);
      expect(find.text('Dr. Test Caregiver'), findsOneWidget);

      // Tap Connect
      await tester.tap(find.text('Connect'));
      await tester.pumpAndSettle();

      expect(mockService.confirmCalled, isTrue);
      expect(find.text('Connected Successfully!'), findsOneWidget);
    });

    testWidgets('QR mode accepts payload and parses directly', (WidgetTester tester) async {
      final mockService = MockPairingService();

      await tester.pumpWidget(
        MaterialApp(
          home: CaregiverConnectionScreen(
            pairingService: mockService,
          ),
        ),
      );

      // Switch to QR mode
      await tester.tap(find.text('Scan QR Code'));
      await tester.pumpAndSettle();

      expect(find.text('Process Scanned Code'), findsOneWidget);

      // Enter QR payload
      await tester.enterText(
        find.byType(TextField),
        'smriti://pair?token=tok_demo&code=4827',
      );
      await tester.pump();

      await tester.ensureVisible(find.text('Process Scanned Code'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Process Scanned Code'));
      await tester.pumpAndSettle();

      expect(mockService.validateCalled, isTrue);
      expect(find.text('Confirm Caregiver'), findsOneWidget);
    });

    testWidgets('QR mode activates camera viewfinder when tapped', (WidgetTester tester) async {
      final mockService = MockPairingService();

      await tester.pumpWidget(
        MaterialApp(
          home: CaregiverConnectionScreen(
            pairingService: mockService,
          ),
        ),
      );

      // Switch to QR mode
      await tester.tap(find.text('Scan QR Code'));
      await tester.pumpAndSettle();

      expect(find.text('Open Camera & Scan QR'), findsOneWidget);

      // Tap Open Camera
      await tester.tap(find.text('Open Camera & Scan QR'));
      await tester.pumpAndSettle();

      // Verify camera viewfinder simulated active
      expect(find.text('Point camera at Caregiver Dashboard QR code'), findsOneWidget);
      expect(find.text('Simulated Camera View (Test Mode)'), findsOneWidget);

      // Close camera
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Open Camera & Scan QR'), findsOneWidget);
    });
  });
}

