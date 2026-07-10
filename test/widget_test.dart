import 'package:flutter/material.dart';
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

    await tester.tap(find.text('¿Olvidaste tu contraseña?'));
    await tester.pumpAndSettle();
    expect(find.text('Recupera tu cuenta'), findsOneWidget);

    await tester.enterText(find.byType(EditableText), 'persona@example.com');
    await tester.tap(find.text('Enviar instrucciones'));
    await tester.pumpAndSettle();
    expect(find.text('Revisa tu correo'), findsOneWidget);

    await tester.tap(find.text('Volver a iniciar sesión'));
    await tester.pumpAndSettle();
    expect(find.text('Bienvenido'), findsOneWidget);

    await tester.tap(find.text('Regístrate'));
    await tester.pump();
    expect(find.text('Empecemos contigo'), findsOneWidget);
  });
}
