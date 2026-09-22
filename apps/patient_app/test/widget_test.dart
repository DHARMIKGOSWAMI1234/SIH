import 'package:flutter_test/flutter_test.dart';
import 'package:patient_app/main.dart';

void main() {
  testWidgets('SmritiApp initial load renders splash screen branding', (WidgetTester tester) async {
    await tester.pumpWidget(const SmritiApp());

    // Verify SMRITI branding and subtitle are present
    expect(find.text('SMRITI'), findsOneWidget);
    expect(find.text('AI Cognitive Care Companion'), findsOneWidget);
    expect(find.text('North Eastern Region (NER)'), findsOneWidget);

    // Pump frames to advance past splash timer safely
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify navigation proceeds to Login / Registration screen
    expect(find.text('Patient Sign In'), findsOneWidget);
    expect(find.text('Welcome Back'), findsOneWidget);
  });
}
