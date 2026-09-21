
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_meal_planner/screens/home_screen.dart';

void main() {
  testWidgets('Home screen loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}