import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/complete_google_onboarding.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(AuthRepository repository)
    : _signUp = SignUp(repository),
      _signIn = SignIn(repository),
      _signInWithGoogle = SignInWithGoogle(repository),
      _completeGoogleOnboarding = CompleteGoogleOnboarding(repository),
      _signOut = SignOut(repository),
      _sendPasswordReset = SendPasswordReset(repository),
      super(const AuthIdle());

  final SignUp _signUp;
  final SignIn _signIn;
  final SignInWithGoogle _signInWithGoogle;
  final CompleteGoogleOnboarding _completeGoogleOnboarding;
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
    debugPrint('[AuthCubit] signUp start');
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
      debugPrint('[AuthCubit] signUp success, emitting EmailVerificationSent');
      emit(EmailVerificationSent(user.email ?? email));
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthCubit] signUp FirebaseAuthException: ${e.code}');
      emit(AuthFailure(_mapError(e.code)));
    } catch (e) {
      debugPrint('[AuthCubit] signUp unknown error: $e');
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

  Future<void> signInWithGoogle() async {
    emit(const AuthSubmitting());
    try {
      final result = await _signInWithGoogle();
      if (result.needsOnboarding) {
        emit(GoogleOnboardingRequired(result.user));
      } else {
        emit(AuthSuccess(result.user));
      }
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        emit(const AuthIdle());
        return;
      }
      emit(const AuthFailure(AuthFailureReason.unknown));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e.code)));
    } catch (e) {
      debugPrint('[AuthCubit] signInWithGoogle unknown error: $e');
      emit(const AuthFailure(AuthFailureReason.unknown));
    }
  }

  Future<void> completeGoogleOnboarding({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    emit(const AuthSubmitting());
    try {
      final user = await _completeGoogleOnboarding(
        name: name,
        goalId: goalId,
        customGoal: customGoal,
        experienceId: experienceId,
      );
      emit(AuthSuccess(user));
    } on FirebaseAuthException catch (e) {
      emit(AuthFailure(_mapError(e.code)));
    } catch (e) {
      debugPrint('[AuthCubit] completeGoogleOnboarding error: $e');
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
    'email-not-verified' => AuthFailureReason.emailNotVerified,
    'network-request-failed' => AuthFailureReason.network,
    _ => AuthFailureReason.unknown,
  };
}
