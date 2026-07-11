import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../loops/domain/entities/interview_track.dart';
import '../../domain/entities/interview_loop.dart';
import '../../domain/entities/interview_report.dart';
import '../../domain/entities/transcript_turn.dart';
import '../../domain/repositories/interview_loop_repository.dart';

class FirestoreInterviewLoopRepository implements InterviewLoopRepository {
  const FirestoreInterviewLoopRepository(this._firestore, this._authRepository);

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;

  CollectionReference<Map<String, dynamic>> get _loops {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw StateError('No hay un usuario autenticado.');
    }
    return _firestore.collection('users').doc(user.uid).collection('loops');
  }

  @override
  Future<List<InterviewLoop>> getCompletedLoops() async {
    final snapshot = await _loops
        .where('status', isEqualTo: 'completed')
        .orderBy('endedAt', descending: true)
        .get();
    return snapshot.docs.map(_fromDocument).toList(growable: false);
  }

  @override
  Future<InterviewLoop?> getLoop(String loopId) async {
    final document = await _loops.doc(loopId).get();
    return document.exists ? _fromDocument(document) : null;
  }

  @override
  Future<String> createActiveLoop({
    String? sourceLoopId,
    String? trackId,
    LoopType loopType = LoopType.interview,
    required Map<String, dynamic> profileSnapshot,
  }) async {
    final document = _loops.doc();
    await document.set({
      'status': 'active',
      'sourceLoopId': sourceLoopId,
      'trackId': trackId,
      'loopType': loopType.name,
      'profileSnapshot': profileSnapshot,
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }

  @override
  Future<void> completePrepLoop({
    required String loopId,
    required List<TranscriptTurn> transcript,
    required int durationSeconds,
  }) {
    return _loops.doc(loopId).update({
      'status': 'completed',
      'loopType': LoopType.prep.name,
      'transcript': transcript.map((turn) => turn.toJson()).toList(),
      'durationSeconds': durationSeconds,
      'endedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> completeLoop({
    required String loopId,
    required List<TranscriptTurn> transcript,
    required InterviewReport report,
    required int durationSeconds,
  }) {
    return _loops.doc(loopId).update({
      'status': 'completed',
      'transcript': transcript.map((turn) => turn.toJson()).toList(),
      'report': {
        'role': report.role,
        'summary': report.summary,
        'strengths': report.strengths,
        'improvements': report.improvements,
        'score': report.score,
        'recommendation': report.recommendation,
      },
      'memorySummary': report.memorySummary,
      'durationSeconds': durationSeconds,
      'endedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> abandonLoop(String loopId) {
    return _loops.doc(loopId).update({
      'status': 'abandoned',
      'endedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  InterviewLoop _fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? const <String, dynamic>{};
    final profile =
        data['profileSnapshot'] as Map<String, dynamic>? ??
        const <String, dynamic>{};
    final reportJson = data['report'] as Map<String, dynamic>?;
    final transcriptJson = data['transcript'] as List<dynamic>? ?? const [];
    final startedAt = data['startedAt'] as Timestamp?;
    final endedAt = data['endedAt'] as Timestamp?;

    return InterviewLoop(
      id: document.id,
      status: data['status'] as String? ?? 'active',
      startedAt: startedAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      endedAt: endedAt?.toDate(),
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
      profileName: profile['name'] as String? ?? '',
      goal: profile['customGoal'] as String? ?? profile['goal'] as String? ?? '',
      experience: profile['experience'] as String? ?? '',
      sourceLoopId: data['sourceLoopId'] as String?,
      transcript: transcriptJson
          .whereType<Map>()
          .map(
            (item) => TranscriptTurn.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(growable: false),
      report: reportJson == null
          ? null
          : InterviewReport.fromJson({
              ...reportJson,
              'memorySummary': data['memorySummary'],
            }),
    );
  }
}
