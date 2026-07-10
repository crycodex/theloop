import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository();

  @override
  Future<Profile> getProfile() async {
    return const Profile(
      name: 'Cristhian',
      email: 'cristhian@example.com',
      target: 'Mobile Engineer · Meta',
      plan: 'Plan Pro mock · \$50/mes',
    );
  }
}
