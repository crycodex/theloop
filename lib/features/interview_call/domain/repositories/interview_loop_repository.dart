import '../entities/interview_loop.dart';

abstract interface class InterviewLoopRepository {
  Future<List<InterviewLoop>> getCompletedLoops();

  Future<InterviewLoop?> getLoop(String loopId);

  Future<void> abandonLoop(String loopId);
}
