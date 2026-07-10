import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theloop/core/navigation/app_router.dart';
import 'package:theloop/core/settings/cubit/settings_cubit.dart';
import 'package:theloop/core/settings/cubit/settings_state.dart';
import 'package:theloop/core/theme/loop_theme.dart';
import 'package:theloop/features/auth/domain/repositories/auth_repository.dart';
import 'package:theloop/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:theloop/features/profile/data/repositories/mock_profile_repository.dart';
import 'package:theloop/features/profile/domain/repositories/profile_repository.dart';
import 'package:theloop/features/profile/domain/usecases/get_profile.dart';
import 'package:theloop/features/profile/presentation/cubit/profile_cubit.dart';

import 'fakes/fake_auth_repository.dart';

class _TestApp extends StatelessWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => FakeAuthRepository()),
        RepositoryProvider<ProfileRepository>(
          create: (_) => const MockProfileRepository(),
        ),
      ],
      child: const _TestAppView(),
    );
  }
}

class _TestAppView extends StatefulWidget {
  const _TestAppView();

  @override
  State<_TestAppView> createState() => _TestAppViewState();
}

class _TestAppViewState extends State<_TestAppView> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(context.read<AuthRepository>());
  }

  @override
  void dispose() {
    _appRouter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(context.read<AuthRepository>()),
        ),
        BlocProvider(
          create: (context) =>
              ProfileCubit(GetProfile(context.read<ProfileRepository>())),
        ),
        BlocProvider(create: (_) => SettingsCubit()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: LoopTheme.light,
            darkTheme: LoopTheme.dark,
            themeMode: settings.themeMode,
            locale: settings.language.locale,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('es'), Locale('en')],
            routerConfig: _appRouter.router,
          );
        },
      ),
    );
  }
}

void main() {
  testWidgets('Loop app opens the onboarding flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const _TestApp());
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
