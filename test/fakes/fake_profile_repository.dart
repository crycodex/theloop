import 'package:theloop/features/profile/domain/entities/profile.dart';
import 'package:theloop/features/profile/domain/repositories/profile_repository.dart';

class FakeProfileRepository implements ProfileRepository {
  Profile _profile = const Profile(
    name: 'Cristhian',
    email: 'cristhian@example.com',
    target: 'bigTech',
    plan: 'Plan Gratis',
    experience: 'none',
  );

  @override
  Future<Profile> getProfile() async => _profile;

  @override
  Future<bool> isProfileComplete() async => _profile.target.isNotEmpty;

  @override
  Future<void> updateProfile({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  }) async {
    _profile = Profile(
      name: name,
      email: _profile.email,
      target: goalId,
      plan: _profile.plan,
      experience: experienceId,
      customGoal: customGoal,
    );
  }

  @override
  Future<Map<String, dynamic>> exportUserData() async => {
    'exportedAt': DateTime.now().toUtc().toIso8601String(),
    'profile': {
      'name': _profile.name,
      'email': _profile.email,
      'goal': _profile.target,
    },
    'tracks': <Map<String, dynamic>>[],
  };

  @override
  Future<void> deleteUserData() async {}
}
