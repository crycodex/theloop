import 'dart:async';

import 'package:theloop/features/auth/domain/entities/auth_user.dart';
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
    final user = AuthUser(uid: 'fake-uid', email: email);
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}
}
