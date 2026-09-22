// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:justdemo/main.dart';

void main() {
  testWidgets('shows the study tracker home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyTrackerApp());

    expect(find.text('Study Tracker'), findsOneWidget);
    expect(find.text('No subjects yet!'), findsOneWidget);
    expect(find.text('Subjects'), findsOneWidget);
  });

  testWidgets('adds a study subject', (WidgetTester tester) async {
    await tester.pumpWidget(const StudyTrackerApp());

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Math');
    await tester.enterText(fields.at(1), '2');
    await tester.tap(find.text('Add').last);
    await tester.pumpAndSettle();

    expect(find.text('Math'), findsOneWidget);
    expect(find.text('2h'), findsOneWidget);
  });
}
