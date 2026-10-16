import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:southsea_cinema/widgets/primary_button.dart';

void main() {
  group('PrimaryButton', () {
    testWidgets('invokes onPressed when tapped', (WidgetTester tester) async {
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PrimaryButton(
              label: 'BOOK NOW',
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('BOOK NOW'));
      await tester.pump();

      expect(wasPressed, isTrue);
    });
  });
}
