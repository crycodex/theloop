import '../entities/auth_user.dart';
import '../entities/google_sign_in_result.dart';

abstract interface class AuthRepository {
  Stream<AuthUser?> authStateChanges();

  AuthUser? get currentUser;

  Future<AuthUser> signUp({
    required String email,
    required String password,
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  });

  Future<AuthUser> signIn({required String email, required String password});

  Future<GoogleSignInResult> signInWithGoogle();

  Future<AuthUser> completeGoogleOnboarding({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> reauthenticateWithPassword(String password);

  Future<void> deleteCurrentUser();
}
