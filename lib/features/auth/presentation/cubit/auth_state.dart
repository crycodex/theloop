import '../../domain/entities/auth_user.dart';

enum AuthFailureReason {
  emailAlreadyInUse,
  invalidCredential,
  weakPassword,
  emailNotVerified,
  network,
  unknown,
}

sealed class AuthState {
  const AuthState();
}

class AuthIdle extends AuthState {
  const AuthIdle();
}

class AuthSubmitting extends AuthState {
  const AuthSubmitting();
}

class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);

  final AuthUser user;
}

class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}

class EmailVerificationSent extends AuthState {
  const EmailVerificationSent(this.email);

  final String email;
}

class AuthFailure extends AuthState {
  const AuthFailure(this.reason);

  final AuthFailureReason reason;
}
