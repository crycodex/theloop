import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/cv_analysis/presentation/cv_analysis_screen.dart';
import '../../features/home_dashboard/presentation/home_screen.dart';
import '../../features/interview_call/presentation/interview_call_screen.dart';
import '../../features/loops/presentation/loops_screen.dart';
import '../../features/onboarding/presentation/onboarding_screens.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/recap/presentation/recap_screen.dart';
import '../../features/roadmap/presentation/roadmap_screen.dart';
import 'app_shell.dart';

const _authRoutes = {'/welcome', '/login', '/forgot-password', '/register'};

class AppRouter {
  AppRouter(this._authRepository)
    : refresh = GoRouterRefreshStream(_authRepository.authStateChanges()) {
    router = GoRouter(
      initialLocation: '/welcome',
      refreshListenable: refresh,
      redirect: _redirect,
      routes: routes,
    );
  }

  final AuthRepository _authRepository;
  final GoRouterRefreshStream refresh;
  late final GoRouter router;

  String? _redirect(BuildContext context, GoRouterState state) {
    final loggedIn = _authRepository.currentUser != null;
    final goingToAuthRoute = _authRoutes.contains(state.matchedLocation);

    if (!loggedIn && !goingToAuthRoute) return '/welcome';
    if (loggedIn && goingToAuthRoute) return '/';
    return null;
  }

  void dispose() => refresh.dispose();
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routes = [
  GoRoute(
    path: '/welcome',
    pageBuilder: (context, state) =>
        _instantPage(state: state, child: const WelcomeScreen()),
  ),
  GoRoute(
    path: '/login',
    pageBuilder: (context, state) =>
        _instantPage(state: state, child: const LoginScreen()),
  ),
  GoRoute(
    path: '/forgot-password',
    pageBuilder: (context, state) =>
        _navPage(state: state, child: const ForgotPasswordScreen()),
  ),
  GoRoute(
    path: '/register',
    pageBuilder: (context, state) =>
        _instantPage(state: state, child: const RegisterScreen()),
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
];

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
