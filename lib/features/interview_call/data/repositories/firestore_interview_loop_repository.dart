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

  CollectionReference<Map<String, dynamic>> _loopsFor(String trackId) {
    final user = _authRepository.currentUser;
    if (user == null) {
      throw StateError('No hay un usuario autenticado.');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('tracks')
        .doc(trackId)
        .collection('loops');
  }

  @override
  Future<List<InterviewLoop>> getLoopsForTrack(String trackId) async {
    final snapshot = await _loopsFor(trackId)
        .orderBy('startedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => _fromDocument(trackId, doc))
        .toList(growable: false);
  }

  @override
  Future<InterviewLoop?> getLoop({
    required String trackId,
    required String loopId,
  }) async {
    final document = await _loopsFor(trackId).doc(loopId).get();
    return document.exists ? _fromDocument(trackId, document) : null;
  }

  @override
  Future<InterviewLoop?> getLatestCompletedInterviewLoop(String trackId) async {
    final loops = await getLoopsForTrack(trackId);
    for (final loop in loops) {
      if (loop.loopType == LoopType.interview.name &&
          loop.status == 'completed' &&
          loop.report != null) {
        return loop;
      }
    }
    return null;
  }

  @override
  Future<String> createActiveLoop({
    required String trackId,
    String? sourceLoopId,
    LoopType loopType = LoopType.interview,
    required Map<String, dynamic> profileSnapshot,
  }) async {
    final collection = _loopsFor(trackId);
    final document = collection.doc();
    await document.set({
      'status': 'active',
      'sourceLoopId': sourceLoopId,
      'loopType': loopType.name,
      'profileSnapshot': profileSnapshot,
      'startedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return document.id;
  }

  @override
  Future<void> completePrepLoop({
    required String trackId,
    required String loopId,
    required List<TranscriptTurn> transcript,
    required int durationSeconds,
  }) {
    return _loopsFor(trackId).doc(loopId).update({
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
    required String trackId,
    required String loopId,
    required List<TranscriptTurn> transcript,
    required InterviewReport report,
    required int durationSeconds,
  }) async {
    final batch = _firestore.batch();
    final loopRef = _loopsFor(trackId).doc(loopId);
    batch.update(loopRef, {
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

    final user = _authRepository.currentUser;
    if (user != null) {
      final trackRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('tracks')
          .doc(trackId);
      batch.update(trackRef, {
        'latestScore': report.score,
        'latestLevel': report.score / 2,
        if (report.improvements.isNotEmpty) 'lastFocus': report.improvements.first,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Future<void> abandonLoop({
    required String trackId,
    required String loopId,
  }) {
    return _loopsFor(trackId).doc(loopId).update({
      'status': 'abandoned',
      'endedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<DateTime>> getCompletedPracticeDates(
    Iterable<String> trackIds,
  ) async {
    final dates = <DateTime>[];
    for (final trackId in trackIds) {
      final loops = await getLoopsForTrack(trackId);
      for (final loop in loops) {
        if (loop.status == 'completed' && loop.endedAt != null) {
          dates.add(loop.endedAt!);
        }
      }
    }
    return dates;
  }

  InterviewLoop _fromDocument(
    String trackId,
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
      trackId: trackId,
      status: data['status'] as String? ?? 'active',
      loopType: data['loopType'] as String? ?? LoopType.interview.name,
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
