import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  const MockProfileRepository();

  @override
  Profile getProfile() {
    return const Profile(
      name: 'Cristhian',
      target: 'Mobile Engineer · Meta',
      plan: 'Plan Pro mock · \$50/mes',
    );
  }
}
