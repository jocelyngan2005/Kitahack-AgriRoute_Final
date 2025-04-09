// This is a basic Flutter widget test for Climate Smart Farming app
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:climate_smart_farming_2/main.dart';

void main() {
  testWidgets('App should render HomeScreen with feature cards', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ClimateSmartFarmingApp());

    // Verify that the app title is displayed
    expect(find.text('Climate Smart Farming'), findsOneWidget);
    
    // Verify that the feature cards are displayed
    expect(find.text('Find Farming Techniques'), findsOneWidget);
    expect(find.text('Location-Based Advice'), findsOneWidget);
    expect(find.text('Seasonal Calendar'), findsOneWidget);
    expect(find.text('Climate Adaptation'), findsOneWidget);
    
    // Verify that the banner text is shown
    expect(find.text('Sustainable farming for a changing climate'), findsOneWidget);
    
    // Tap the first feature card and verify navigation
    await tester.tap(find.text('Find Farming Techniques'));
    await tester.pumpAndSettle(); // Wait for navigation to complete
    
    // Verify that we navigated to the search screen
    expect(find.byType(Scaffold), findsOneWidget);
  });
}