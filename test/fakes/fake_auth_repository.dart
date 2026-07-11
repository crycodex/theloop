import 'dart:async';

import 'package:theloop/features/auth/domain/entities/auth_user.dart';
import 'package:theloop/features/auth/domain/entities/google_sign_in_result.dart';
import 'package:theloop/features/auth/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    final user = AuthUser(uid: 'fake-uid', email: email);
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = AuthUser(uid: 'fake-uid', email: email, emailVerified: true);
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<GoogleSignInResult> signInWithGoogle() async {
    final user = AuthUser(
      uid: 'fake-google-uid',
      email: 'google@example.com',
      emailVerified: true,
    );
    _currentUser = user;
    _controller.add(user);
    return GoogleSignInResult(user: user, needsOnboarding: false);
  }

  @override
  Future<AuthUser> completeGoogleOnboarding({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    final user = _currentUser;
    if (user == null) throw StateError('No hay un usuario autenticado.');
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> reauthenticateWithPassword(String password) async {}

  @override
  Future<void> deleteCurrentUser() async {
    _currentUser = null;
    _controller.add(null);
  }
}
