import '../entities/interview_loop.dart';
import '../entities/interview_report.dart';
import '../entities/transcript_turn.dart';

abstract interface class InterviewLoopRepository {
  Future<List<InterviewLoop>> getCompletedLoops();

  Future<InterviewLoop?> getLoop(String loopId);

  Future<String> createActiveLoop({
    String? sourceLoopId,
    required Map<String, dynamic> profileSnapshot,
  });

  Future<void> completeLoop({
    required String loopId,
    required List<TranscriptTurn> transcript,
    required InterviewReport report,
    required int durationSeconds,
  });

  Future<void> abandonLoop(String loopId);
}
