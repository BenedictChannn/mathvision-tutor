import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:src/screens/result/result_screen.dart';

void main() {
  group('ResultScreen UI', () {
    testWidgets('expands/collapses step cards and enables CTA when quota left', (tester) async {
      const steps = ['First step explanation', 'Second step explanation'];

      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(
            answer: '42',
            steps: steps,
            followUpsLeft: 1,
          ),
        ),
      );

      expect(find.text('First step explanation'), findsOneWidget);
      expect(find.text('Second step explanation'), findsNothing);

      await tester.tap(find.text('Step 2'));
      await tester.pumpAndSettle();

      expect(find.text('Second step explanation'), findsOneWidget);

      final followUpBtn = find.widgetWithText(ElevatedButton, 'Ask a follow-up (1 left)');
      expect(followUpBtn, findsOneWidget);
      final ElevatedButton btnWidget = tester.widget(followUpBtn);
      expect(btnWidget.onPressed, isNotNull);
    });

    testWidgets('disables CTA when no follow-ups remaining', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ResultScreen(
            answer: 'Result',
            steps: ['only step'],
            followUpsLeft: 0,
          ),
        ),
      );

      final followUpBtn = find.widgetWithText(ElevatedButton, 'Ask a follow-up (0 left)');
      expect(followUpBtn, findsOneWidget);
      final ElevatedButton btnWidget = tester.widget(followUpBtn);
      expect(btnWidget.onPressed, isNull);
    });
  });
}
