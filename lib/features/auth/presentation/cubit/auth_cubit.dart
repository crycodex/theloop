import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(AuthRepository repository)
    : _signUp = SignUp(repository),
      _signIn = SignIn(repository),
      _signOut = SignOut(repository),
      _sendPasswordReset = SendPasswordReset(repository),
      super(const AuthIdle());

  final SignUp _signUp;
  final SignIn _signIn;
  final SignOut _signOut;
  final SendPasswordReset _sendPasswordReset;

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    emit(const AuthSubmitting());
    try {
      final user = await _signUp(
        email: email,
        password: password,
        name: name,
        goalId: goalId,
        customGoal: customGoal,
        experienceId: experienceId,
      );
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e.code)));
    } catch (_) {
      emit(const AuthFailure(AuthFailureReason.unknown));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthSubmitting());
    try {
      final user = await _signIn(email: email, password: password);
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e.code)));
    } catch (_) {
      emit(const AuthFailure(AuthFailureReason.unknown));
    }
  }

  Future<void> signOut() async {
    await _signOut();
    emit(const AuthIdle());
  }

  Future<void> sendPasswordReset(String email) async {
    emit(const AuthSubmitting());
    try {
      await _sendPasswordReset(email);
      emit(const PasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e.code)));
    } catch (_) {
      emit(const AuthFailure(AuthFailureReason.unknown));
    }
  }

  AuthFailureReason _mapError(String code) => switch (code) {
    'email-already-in-use' => AuthFailureReason.emailAlreadyInUse,
    'invalid-credential' ||
    'wrong-password' ||
    'user-not-found' => AuthFailureReason.invalidCredential,
    'weak-password' => AuthFailureReason.weakPassword,
    'network-request-failed' => AuthFailureReason.network,
    _ => AuthFailureReason.unknown,
  };
}
