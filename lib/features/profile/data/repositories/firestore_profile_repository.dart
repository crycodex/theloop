import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class FirestoreProfileRepository implements ProfileRepository {
  const FirestoreProfileRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  @override
  Future<Profile> getProfile() async {
    final user = _authRepository.currentUser;
    if (user == null) {
      return const Profile(name: '', email: '', target: '', plan: '');
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    final data = doc.data() ?? <String, dynamic>{};

    return Profile(
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? user.email ?? '',
      target: data['goal'] as String? ?? '',
      plan: 'Plan Gratis',
    );
  }
}
