import '../entities/google_sign_in_result.dart';
import '../repositories/auth_repository.dart';

class SignInWithApple {
  const SignInWithApple(this._repository);

  final AuthRepository _repository;

  Future<GoogleSignInResult> call() => _repository.signInWithApple();
}
