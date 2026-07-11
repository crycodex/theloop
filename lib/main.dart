import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/bootstrap/loop_bootstrap.dart';
import 'core/config/app_env.dart';
import 'core/navigation/app_router.dart';
import 'core/settings/cubit/settings_cubit.dart';
import 'core/settings/cubit/settings_state.dart';
import 'core/settings/data/settings_storage.dart';
import 'core/theme/loop_theme.dart';
import 'features/auth/data/repositories/firebase_auth_repository.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/cv_analysis/data/repositories/mock_cv_analysis_repository.dart';
import 'features/cv_analysis/domain/repositories/cv_analysis_repository.dart';
import 'features/cv_analysis/domain/usecases/get_cv_analysis.dart';
import 'features/cv_analysis/presentation/cubit/cv_analysis_cubit.dart';
import 'features/home_dashboard/data/repositories/firestore_home_dashboard_repository.dart';
import 'features/home_dashboard/domain/repositories/home_dashboard_repository.dart';
import 'features/home_dashboard/domain/usecases/get_home_dashboard.dart';
import 'features/home_dashboard/presentation/cubit/home_dashboard_cubit.dart';
import 'features/interview_call/data/repositories/firestore_interview_loop_repository.dart';
import 'features/interview_call/data/services/audio_service.dart';
import 'features/interview_call/data/services/gemini_live_service.dart';
import 'features/interview_call/data/services/interview_report_service.dart';
import 'features/interview_call/domain/repositories/interview_loop_repository.dart';
import 'features/interview_call/presentation/cubit/interview_call_cubit.dart';
import 'features/loops/data/repositories/firestore_loops_repository.dart';
import 'features/loops/data/repositories/firestore_tracks_repository.dart';
import 'features/loops/domain/repositories/loops_repository.dart';
import 'features/loops/domain/repositories/tracks_repository.dart';
import 'features/loops/domain/usecases/get_loop_tracks.dart';
import 'features/loops/presentation/cubit/loops_cubit.dart';
import 'features/profile/data/repositories/firestore_profile_repository.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/domain/usecases/get_profile.dart';
import 'features/profile/presentation/cubit/profile_cubit.dart';
import 'features/recap/data/repositories/firestore_recap_repository.dart';
import 'features/recap/domain/repositories/recap_repository.dart';
import 'features/recap/domain/usecases/get_latest_recap.dart';
import 'features/recap/presentation/cubit/recap_cubit.dart';
import 'features/roadmap/data/repositories/mock_roadmap_repository.dart';
import 'features/roadmap/domain/repositories/roadmap_repository.dart';
import 'features/roadmap/domain/usecases/get_roadmap.dart';
import 'features/roadmap/presentation/cubit/roadmap_cubit.dart';

const _firestoreDatabaseId = 'default';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppEnv.load();

  final settingsStorage = SharedPreferencesSettingsStorage();
  final initialSettings = await settingsStorage.load();

  runApp(
    LoopBootstrap(
      initialSettings: initialSettings,
      settingsStorage: settingsStorage,
    ),
  );
}

class LoopApp extends StatelessWidget {
  const LoopApp({
    super.key,
    required this.initialSettings,
    required this.settingsStorage,
  });

  final SettingsState initialSettings;
  final SettingsStorage settingsStorage;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FirebaseFirestore>(
          create: (_) => FirebaseFirestore.instanceFor(
            app: Firebase.app(),
            databaseId: _firestoreDatabaseId,
          ),
        ),
        RepositoryProvider<AuthRepository>(
          create: (context) => FirebaseAuthRepository(
            FirebaseAuth.instance,
            context.read<FirebaseFirestore>(),
          ),
        ),
        RepositoryProvider<ProfileRepository>(
          create: (context) => FirestoreProfileRepository(
            context.read<FirebaseFirestore>(),
            context.read<AuthRepository>(),
          ),
        ),
        RepositoryProvider<InterviewLoopRepository>(
          create: (context) => FirestoreInterviewLoopRepository(
            context.read<FirebaseFirestore>(),
            context.read<AuthRepository>(),
          ),
        ),
        RepositoryProvider<TracksRepository>(
          create: (context) => FirestoreTracksRepository(
            context.read<FirebaseFirestore>(),
            context.read<AuthRepository>(),
          ),
        ),
        RepositoryProvider<LoopsRepository>(
          create: (context) =>
              FirestoreLoopsRepository(context.read<TracksRepository>()),
        ),
        RepositoryProvider<HomeDashboardRepository>(
          create: (context) => FirestoreHomeDashboardRepository(
            context.read<ProfileRepository>(),
            context.read<LoopsRepository>(),
            context.read<InterviewLoopRepository>(),
          ),
        ),
        RepositoryProvider<CvAnalysisRepository>(
          create: (_) => const MockCvAnalysisRepository(),
        ),
        RepositoryProvider<RoadmapRepository>(
          create: (_) => const MockRoadmapRepository(),
        ),
        RepositoryProvider<RecapRepository>(
          create: (context) =>
              FirestoreRecapRepository(context.read<InterviewLoopRepository>()),
        ),
      ],
      child: _LoopAppView(
        initialSettings: initialSettings,
        settingsStorage: settingsStorage,
      ),
    );
  }
}

class _LoopAppView extends StatefulWidget {
  const _LoopAppView({
    required this.initialSettings,
    required this.settingsStorage,
  });

  final SettingsState initialSettings;
  final SettingsStorage settingsStorage;

  @override
  State<_LoopAppView> createState() => _LoopAppViewState();
}

class _LoopAppViewState extends State<_LoopAppView> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter(
      context.read<AuthRepository>(),
      context.read<ProfileRepository>(),
    );
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
          create: (context) => ProfileCubit(
            GetProfile(context.read<ProfileRepository>()),
            context.read<ProfileRepository>(),
            context.read<AuthRepository>(),
          ),
        ),
        BlocProvider(
          create: (context) =>
              RecapCubit(GetLatestRecap(context.read<RecapRepository>())),
        ),
        BlocProvider(
          create: (_) => SettingsCubit(
            widget.settingsStorage,
            initialState: widget.initialSettings,
          ),
        ),
        BlocProvider(
          create: (context) => InterviewCallCubit(
            GeminiLiveService(),
            InterviewAudioService(),
            InterviewReportService(),
            context.read<InterviewLoopRepository>(),
            context.read<ProfileRepository>(),
            context.read<TracksRepository>(),
            context.read<SettingsCubit>(),
          ),
        ),
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
