import '../../../home_dashboard/domain/entities/home_dashboard.dart';
import '../../../interview_call/domain/repositories/interview_loop_repository.dart';
import '../../domain/entities/session_recap.dart';
import '../../domain/repositories/recap_repository.dart';

class FirestoreRecapRepository implements RecapRepository {
  const FirestoreRecapRepository(this._loops);

  final InterviewLoopRepository _loops;

  @override
  Future<SessionRecap?> getRecap(String? loopId) async {
    final completed = loopId == null || loopId.isEmpty
        ? await _loops.getCompletedLoops()
        : null;
    final loop = completed != null
        ? (completed.isEmpty ? null : completed.first)
        : await _loops.getLoop(loopId!);
    final report = loop?.report;
    if (loop == null || report == null) return null;
    return SessionRecap(
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
