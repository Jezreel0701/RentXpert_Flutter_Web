import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rentxpert_flutter_web/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app with test mode (not logged in)
    await tester.pumpWidget(const AdminWeb(isLoggedIn: false));

    // Add your specific widget tests here
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify the counter increments
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
