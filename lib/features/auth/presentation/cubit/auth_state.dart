import '../../domain/entities/auth_user.dart';

enum AuthFailureReason {
  emailAlreadyInUse,
  invalidCredential,
  weakPassword,
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

class AuthFailure extends AuthState {
  const AuthFailure(this.reason);

  final AuthFailureReason reason;
}
