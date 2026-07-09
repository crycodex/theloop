import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/cv_analysis/presentation/cv_analysis_screen.dart';
import '../../features/home_dashboard/presentation/home_screen.dart';
import '../../features/interview_call/presentation/interview_call_screen.dart';
import '../../features/loops/presentation/loops_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/recap/presentation/recap_screen.dart';
import '../../features/roadmap/presentation/roadmap_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import 'app_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _instantPage(state: state, child: const SplashScreen()),
    ),
    ShellRoute(
      builder: (context, state, child) {
        return AppShell(location: state.uri.path, child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              _navPage(state: state, child: const HomeScreen()),
        ),
        GoRoute(
          path: '/loops',
          pageBuilder: (context, state) =>
              _navPage(state: state, child: const LoopsScreen()),
        ),
        GoRoute(
          path: '/cv',
          pageBuilder: (context, state) =>
              _navPage(state: state, child: const CvAnalysisScreen()),
        ),
        GoRoute(
          path: '/roadmap',
          pageBuilder: (context, state) =>
              _navPage(state: state, child: const RoadmapScreen()),
        ),
      ],
    ),
    GoRoute(
      path: '/profile',
      pageBuilder: (context, state) =>
          _navPage(state: state, child: const ProfileScreen()),
    ),
    GoRoute(
      path: '/interview',
      pageBuilder: (context, state) =>
          _callPage(state: state, child: const InterviewCallScreen()),
    ),
    GoRoute(
      path: '/recap',
      pageBuilder: (context, state) =>
          _recapPage(state: state, child: const RecapScreen()),
    ),
  ],
);

CustomTransitionPage<void> _instantPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) =>
        child,
  );
}

CustomTransitionPage<void> _navPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final fade = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0),
        end: Offset.zero,
      ).animate(curvedAnimation);
      final scale = Tween<double>(
        begin: 0.985,
        end: 1,
      ).animate(curvedAnimation);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}

CustomTransitionPage<void> _callPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
        reverseCurve: Curves.easeInCubic,
      );
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.08),
        end: Offset.zero,
      ).animate(curvedAnimation);
      final fade = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
      final scale = Tween<double>(begin: 0.96, end: 1).animate(curvedAnimation);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slide,
          child: ScaleTransition(scale: scale, child: child),
        ),
      );
    },
  );
}

CustomTransitionPage<void> _recapPage({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curvedAnimation = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      final fade = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
      final slide = Tween<Offset>(
        begin: const Offset(0, 0.04),
        end: Offset.zero,
      ).animate(curvedAnimation);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
