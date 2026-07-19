import '../../../loops/domain/entities/interview_track.dart';
import '../entities/interview_loop.dart';
import '../entities/interview_report.dart';
import '../entities/transcript_turn.dart';

abstract interface class InterviewLoopRepository {
  Future<List<InterviewLoop>> getLoopsForTrack(String trackId);

  Future<InterviewLoop?> getLoop({
    required String trackId,
    required String loopId,
  });

  /// Última entrevista completada con reporte (para memoria del siguiente ciclo).
  Future<InterviewLoop?> getLatestCompletedInterviewLoop(String trackId);

  Future<String> createActiveLoop({
    required String trackId,
    String? sourceLoopId,
    LoopType loopType = LoopType.interview,
    required Map<String, dynamic> profileSnapshot,
  });

  Future<void> completeLoop({
    required String trackId,
    required String loopId,
    required List<TranscriptTurn> transcript,
    required InterviewReport report,
    required int durationSeconds,
  });

  Future<void> completePrepLoop({
    required String trackId,
    required String loopId,
    required List<TranscriptTurn> transcript,
    required int durationSeconds,
  });

  Future<void> abandonLoop({
    required String trackId,
    required String loopId,
  });

  Future<List<DateTime>> getCompletedPracticeDates(Iterable<String> trackIds);
}
