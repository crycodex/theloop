import '../../../interview_call/domain/repositories/interview_loop_repository.dart';
import '../../domain/entities/loop_track.dart';
import '../../domain/repositories/loops_repository.dart';

class FirestoreLoopsRepository implements LoopsRepository {
  const FirestoreLoopsRepository(this._interviewLoops);

  final InterviewLoopRepository _interviewLoops;

  @override
  Future<List<LoopTrack>> getTracks() async {
    final loops = await _interviewLoops.getCompletedLoops();
    return loops.map((loop) {
      final report = loop.report!;
      return LoopTrack(
        id: loop.id,
        roleTitle: report.role,
        company: 'Entrevista IA',
        level: report.score / 2,
        cyclesCompleted: 1,
        delta: 0,
        progress: report.score / 10,
        focus: report.improvements.isEmpty
            ? report.recommendation
            : report.improvements.first,
      );
    }).toList(growable: false);
  }
}
