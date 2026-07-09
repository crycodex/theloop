import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/cv_analysis/presentation/cv_analysis_screen.dart';
import '../../features/home_dashboard/presentation/home_screen.dart';
import '../../features/interview_call/presentation/interview_call_screen.dart';
import '../../features/loops/presentation/loops_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/recap/presentation/recap_screen.dart';
import '../../features/roadmap/presentation/roadmap_screen.dart';
import 'app_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/loops',
            builder: (context, state) => const LoopsScreen(),
          ),
          GoRoute(
            path: '/cv',
            builder: (context, state) => const CvAnalysisScreen(),
          ),
          GoRoute(
            path: '/roadmap',
            builder: (context, state) => const RoadmapScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/interview',
        builder: (context, state) => const InterviewCallScreen(),
      ),
      GoRoute(
        path: '/recap',
        builder: (context, state) => const RecapScreen(),
      ),
    ],
  );
});
