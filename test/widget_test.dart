import 'package:flutter_test/flutter_test.dart';

import 'package:theloop/main.dart';

void main() {
  testWidgets('Loop app renders home dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const LoopApp());
    await tester.pumpAndSettle();

    expect(find.text('Tu preparación para'), findsOneWidget);
    expect(find.text('Mobile Engineer · Meta'), findsWidgets);
  });
}
