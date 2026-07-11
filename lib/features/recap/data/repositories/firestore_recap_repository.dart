import '../../../home_dashboard/domain/entities/home_dashboard.dart';
import '../../../interview_call/domain/repositories/interview_loop_repository.dart';
import '../../domain/entities/session_recap.dart';
import '../../domain/repositories/recap_repository.dart';

class FirestoreRecapRepository implements RecapRepository {
  const FirestoreRecapRepository(this._loops);

  final InterviewLoopRepository _loops;

  @override
  Future<SessionRecap?> getRecap({
    required String trackId,
    required String loopId,
  }) async {
    final loop = await _loops.getLoop(trackId: trackId, loopId: loopId);
    final report = loop?.report;
    if (loop == null || report == null) return null;
    return SessionRecap(
      trackId: trackId,
      loopId: loop.id,
      level: report.score / 2,
      delta: 0,
      title: report.role,
      summary: report.summary,
      criteria: [
        CriterionProgress(
          name: 'Puntaje general',
          score: report.score / 10,
          trend: '${report.score.toStringAsFixed(1)}/10',
        ),
      ],
      strength: report.strengths.isEmpty
          ? report.summary
          : report.strengths.first,
      improvement: report.improvements.isEmpty
          ? report.recommendation
          : report.improvements.first,
      recommendation: report.recommendation,
      transcript: loop.transcript,
    );
  }
}
