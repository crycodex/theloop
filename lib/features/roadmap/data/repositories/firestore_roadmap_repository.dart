import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/roadmap.dart';
import '../../domain/repositories/roadmap_repository.dart';

class FirestoreRoadmapRepository implements RoadmapRepository {
  const FirestoreRoadmapRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  DocumentReference<Map<String, dynamic>>? get _latestDoc {
    final user = _authRepository.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('roadmap')
        .doc('latest');
  }

  @override
  Future<Roadmap?> getLatest() async {
    final doc = _latestDoc;
    if (doc == null) return null;
    final snapshot = await doc.get();
    final data = snapshot.data();
    if (data == null) return null;
    return Roadmap.fromMap(data);
  }

  @override
  Future<void> saveLatest(Roadmap roadmap) async {
    final doc = _latestDoc;
    if (doc == null) {
      throw StateError('No hay un usuario autenticado.');
    }
    await doc.set(roadmap.toMap());
  }
}
