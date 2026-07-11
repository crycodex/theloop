import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

class CompleteGoogleOnboarding {
  const CompleteGoogleOnboarding(this._repository);

  final AuthRepository _repository;

  Future<AuthUser> call({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) =>
      _repository.completeGoogleOnboarding(
        name: name,
        goalId: goalId,
        customGoal: customGoal,
        experienceId: experienceId,
      );
}
