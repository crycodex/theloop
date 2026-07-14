import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/cv_analysis.dart';
import '../../domain/repositories/cv_analysis_repository.dart';

class FirestoreCvAnalysisRepository implements CvAnalysisRepository {
  const FirestoreCvAnalysisRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  DocumentReference<Map<String, dynamic>>? get _latestDoc {
    final user = _authRepository.currentUser;
    if (user == null) return null;
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cv')
        .doc('latest');
  }

  @override
  Future<CvAnalysis?> getLatest() async {
    final doc = _latestDoc;
    if (doc == null) return null;
    final snapshot = await doc.get();
    final data = snapshot.data();
    if (data == null) return null;
    return CvAnalysis.fromMap(data);
  }

  @override
  Future<void> saveLatest(CvAnalysis analysis) async {
    final doc = _latestDoc;
    if (doc == null) {
      throw StateError('No hay un usuario autenticado.');
    }
    await doc.set(analysis.toMap());
  }
}
