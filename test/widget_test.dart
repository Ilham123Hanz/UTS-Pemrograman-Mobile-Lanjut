// This is a basic Flutter widget test.
// 
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:projectutp_2407051007_ilhamkhoirulsaputra/main.dart';

void main() {
  testWidgets('App loads and shows Canva branding', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CanvaPracticeApp());

    // Verify that Canva branding is shown
    expect(find.text('Canva'), findsOneWidget);
  });
}