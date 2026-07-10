import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

class GetProfile {
  const GetProfile(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call() => _repository.getProfile();
}
