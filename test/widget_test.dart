import 'package:Harikar/main.dart';
import 'package:Harikar/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 1️⃣ Smoke-test that the app can build your root widget
  testWidgets('AppRoot builds without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const LegaryanKare());
    // Allow any animations/splash to settle
    await tester.pumpAndSettle();
    // Verify we have a MaterialApp somewhere in the tree
    expect(find.byType(MaterialApp), findsOneWidget);
  });

  // 2️⃣ Example: check that your splash screen shows something
  testWidgets('SplashScreen shows welcome text', (WidgetTester tester) async {
    await tester.pumpWidget(SplashScreen());
    await tester.pumpAndSettle();
    // Adjust this to whatever text or widget your splash shows:
    expect(find.text('Welcome!'), findsOneWidget);
  });
}
