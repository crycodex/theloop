import '../entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile> getProfile();

  Future<void> updateProfile({
    required String name,
    required String goalId,
    String? customGoal,
    required String experienceId,
  });

  Future<Map<String, dynamic>> exportUserData();

  Future<void> deleteUserData();
}
