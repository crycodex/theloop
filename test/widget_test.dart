import 'package:flutter_test/flutter_test.dart';

import 'package:theloop/main.dart';

void main() {
  testWidgets('Loop app opens the onboarding flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const LoopApp());
    await tester.pump();

    expect(find.text('Toca para continuar'), findsOneWidget);

    await tester.tap(find.text('Toca para continuar'));
    await tester.pump();
    expect(find.text('Bienvenido'), findsOneWidget);

    await tester.tap(find.text('Regístrate'));
    await tester.pump();
    expect(find.text('Empecemos contigo'), findsOneWidget);
  });
}
