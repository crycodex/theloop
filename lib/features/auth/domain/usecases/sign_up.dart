import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  const SignUp(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String email,
    required String password,
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) => _repository.signUp(
    email: email,
    password: password,
    name: name,
    goalId: goalId,
    customGoal: customGoal,
    experienceId: experienceId,
  );
}
