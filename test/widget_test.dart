
import 'package:flutter_test/flutter_test.dart';
import 'package:ipad_pos/main.dart'; // Replace with your app's main file
import 'package:ipad_pos/POSPage.dart';
import 'package:flutter/material.dart';


void main() {
  testWidgets('Widget Test', (WidgetTester tester) async {
     final categories = [
    Category(name: 'Beef', items: [], icon: Icons.fastfood),
    Category(name: 'Chicken', items: [], icon: Icons.fastfood),
    Category(name: 'Fries', items: [], icon: Icons.fastfood),
    Category(name: 'Soft Drinks', items: [], icon: Icons.local_drink),
  ];

    // Build your app and trigger a frame.
    await tester.pumpWidget(MyApp(categories: categories)); // Replace with your main app widget

    // You can add test expectations here. For example, you can check if certain widgets are on the screen.
    expect(find.text('POS App'), findsOneWidget);
    expect(find.text('Item 1'), findsNWidgets(2)); // Example: If Item 1 appears twice.

    // You can simulate user interactions in the test as well.
    // For example, you can tap buttons, etc.
  });
}
