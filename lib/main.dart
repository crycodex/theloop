import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/navigation/app_router.dart';
import 'core/settings/cubit/settings_cubit.dart';
import 'core/settings/cubit/settings_state.dart';
import 'core/theme/loop_theme.dart';
import 'features/cv_analysis/data/repositories/mock_cv_analysis_repository.dart';
import 'features/cv_analysis/domain/repositories/cv_analysis_repository.dart';
import 'features/cv_analysis/domain/usecases/get_cv_analysis.dart';
import 'features/cv_analysis/presentation/cubit/cv_analysis_cubit.dart';
import 'features/home_dashboard/data/repositories/mock_home_dashboard_repository.dart';
import 'features/home_dashboard/domain/repositories/home_dashboard_repository.dart';
import 'features/home_dashboard/domain/usecases/get_home_dashboard.dart';
import 'features/home_dashboard/presentation/cubit/home_dashboard_cubit.dart';
import 'features/interview_call/presentation/cubit/interview_call_cubit.dart';
import 'features/loops/data/repositories/mock_loops_repository.dart';
import 'features/loops/domain/repositories/loops_repository.dart';
import 'features/loops/domain/usecases/get_loop_tracks.dart';
import 'features/loops/presentation/cubit/loops_cubit.dart';
import 'features/profile/data/repositories/mock_profile_repository.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/recap/data/repositories/mock_recap_repository.dart';
import 'features/recap/domain/repositories/recap_repository.dart';
import 'features/recap/domain/usecases/get_latest_recap.dart';
import 'features/recap/presentation/cubit/recap_cubit.dart';
import 'features/roadmap/data/repositories/mock_roadmap_repository.dart';
import 'features/roadmap/domain/repositories/roadmap_repository.dart';
import 'features/roadmap/domain/usecases/get_roadmap.dart';
import 'features/roadmap/presentation/cubit/roadmap_cubit.dart';
import 'features/splash/presentation/cubit/splash_cubit.dart';

void main() {
  runApp(const LoopApp());
}

class LoopApp extends StatelessWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LoopsRepository>(
          create: (_) => const MockLoopsRepository(),
        ),
        RepositoryProvider<HomeDashboardRepository>(
          create: (context) =>
              MockHomeDashboardRepository(context.read<LoopsRepository>()),
        ),
        RepositoryProvider<CvAnalysisRepository>(
          create: (_) => const MockCvAnalysisRepository(),
        ),
        RepositoryProvider<RoadmapRepository>(
          create: (_) => const MockRoadmapRepository(),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (_) => const MockProfileRepository(),
        ),
        RepositoryProvider<RecapRepository>(
          create: (_) => const MockRecapRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => HomeDashboardCubit(
              GetHomeDashboard(context.read<HomeDashboardRepository>()),
            ),
          ),
          BlocProvider(
            create: (context) =>
                LoopsCubit(GetLoopTracks(context.read<LoopsRepository>())),
          ),
          BlocProvider(
            create: (context) => CvAnalysisCubit(
              GetCvAnalysis(context.read<CvAnalysisRepository>()),
            ),
          ),
          BlocProvider(
            create: (context) =>
                RoadmapCubit(GetRoadmap(context.read<RoadmapRepository>())),
          ),
          BlocProvider(
            create: (context) =>
                ProfileCubit(GetProfile(context.read<ProfileRepository>())),
          ),
          BlocProvider(
            create: (context) =>
                RecapCubit(GetLatestRecap(context.read<RecapRepository>())),
          ),
          BlocProvider(create: (_) => InterviewCallCubit()),
          BlocProvider(create: (_) => SplashCubit()),
          BlocProvider(create: (_) => SettingsCubit()),
        ],
        child: BlocBuilder<SettingsCubit, SettingsState>(
          builder: (context, settings) {
            return MaterialApp.router(
              title: 'Loop',
              debugShowCheckedModeBanner: false,
              theme: LoopTheme.light,
              darkTheme: LoopTheme.dark,
              themeMode: settings.themeMode,
              locale: settings.language.locale,
              supportedLocales: const [Locale('es'), Locale('en')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              routerConfig: appRouter,
            );
          },
        ),
      ),
    );
  }
}
