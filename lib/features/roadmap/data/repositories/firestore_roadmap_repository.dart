import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/settings/cubit/settings_state.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/roadmap.dart';
import '../../domain/repositories/roadmap_repository.dart';

class FirestoreRoadmapRepository implements RoadmapRepository {
  const FirestoreRoadmapRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  DocumentReference<Map<String, dynamic>>? _userDoc(String docId) {
    final user = _authRepository.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('roadmap')
        .doc(docId);
  }

  @override
  Future<Roadmap?> getLatest() async {
    final doc = _userDoc('latest');
    if (doc == null) return null;
    final snapshot = await doc.get();
    final data = snapshot.data();
    if (data == null) return null;
    return Roadmap.fromMap(data);
  }

  @override
  Future<void> saveLatest(Roadmap roadmap) async {
    final doc = _userDoc('latest');
    if (doc == null) {
      throw StateError('No hay un usuario autenticado.');
    }
    await doc.set(roadmap.toMap());
  }

  @override
  Future<Roadmap?> getCatalogForGoal(
    String goalId,
    AppLanguage language,
  ) async {
    if (goalId.trim().isEmpty) return null;
    final snapshot =
        await _firestore.collection('roadmap_catalog').doc(goalId).get();
    final data = snapshot.data();
    if (data == null) return null;
    final roadmap = Roadmap.fromCatalogMap(
      data,
      es: language == AppLanguage.spanish,
    );
    return roadmap.steps.isEmpty ? null : roadmap;
  }

  @override
  Future<Set<String>> getCompletedStepIds() async {
    final doc = _userDoc('progress');
    if (doc == null) return const {};
    final snapshot = await doc.get();
    final ids = snapshot.data()?['completedStepIds'] as List<dynamic>?;
    return ids?.whereType<String>().toSet() ?? const {};
  }

  @override
  Future<void> markStepCompleted(String stepId) async {
    final doc = _userDoc('progress');
    if (doc == null) {
      throw StateError('No hay un usuario autenticado.');
    }
    await doc.set({
      'completedStepIds': FieldValue.arrayUnion([stepId]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> resetProgress() async {
    final doc = _userDoc('progress');
    if (doc == null) return;
    await doc.set({
      'completedStepIds': <String>[],
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
