import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:firebase_auth_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Railway Parts Demo Integration Test', () {
    
    testWidgets('Complete demo flow: Login → Manual QR entry → View results',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // In demo mode, should go directly to HomeScreen
      expect(find.text('Railway Parts QR Scanner'), findsOneWidget);

      // Tap on QR Scanner button
      final scannerButton = find.byIcon(Icons.qr_code_scanner);
      expect(scannerButton, findsOneWidget);
      await tester.tap(scannerButton);
      await tester.pumpAndSettle();

      // Should be on QR Scanner screen
      expect(find.text('Scan QR Code'), findsOneWidget);

      // Tap on manual entry button
      final manualButton = find.byIcon(Icons.keyboard);
      expect(manualButton, findsOneWidget);
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Should see manual entry dialog
      expect(find.text('Enter Part ID'), findsOneWidget);

      // Enter P-001 in the text field
      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);
      await tester.enterText(textField, 'P-001');
      await tester.pumpAndSettle();

      // Tap Submit button
      final submitButton = find.text('Submit');
      expect(submitButton, findsOneWidget);
      await tester.tap(submitButton);
      await tester.pumpAndSettle(Duration(seconds: 5)); // Wait for API calls

      // Should be on QR Result screen
      expect(find.text('Part Details'), findsOneWidget);
      expect(find.text('P-001'), findsOneWidget);

      // Check if part information is displayed
      expect(find.text('Part Information'), findsOneWidget);
      
      // Check if ML analysis section appears (even if loading)
      expect(find.text('ML Health Analysis'), findsOneWidget);
      
      // Check if blockchain verification section appears
      expect(find.text('Blockchain Verification'), findsOneWidget);

      // Verify that we can see some part details
      // The exact content depends on the seeded data
      expect(find.byIcon(Icons.inventory), findsOneWidget);
      expect(find.byIcon(Icons.business), findsOneWidget);

      print('✅ Integration test passed: Successfully navigated through demo flow');
    });

    testWidgets('Test manual entry with invalid part ID',
        (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Navigate to QR Scanner
      final scannerButton = find.byIcon(Icons.qr_code_scanner);
      await tester.tap(scannerButton);
      await tester.pumpAndSettle();

      // Open manual entry
      final manualButton = find.byIcon(Icons.keyboard);
      await tester.tap(manualButton);
      await tester.pumpAndSettle();

      // Enter invalid part ID
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'INVALID-ID');
      await tester.pumpAndSettle();

      // Submit
      final submitButton = find.text('Submit');
      await tester.tap(submitButton);
      await tester.pumpAndSettle(Duration(seconds: 3));

      // Should still navigate to result screen (API will handle invalid IDs gracefully)
      expect(find.text('Part Details'), findsOneWidget);
      expect(find.text('INVALID-ID'), findsOneWidget);

      print('✅ Integration test passed: Invalid part ID handled gracefully');
    });


  });
}

