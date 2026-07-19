import '../entities/google_sign_in_result.dart';
import '../repositories/auth_repository.dart';

class SignInWithGoogle {
  const SignInWithGoogle(this._repository);

  final AuthRepository _repository;

  Future<GoogleSignInResult> call() => _repository.signInWithGoogle();
}
