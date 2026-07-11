import '../entities/interview_track.dart';

abstract interface class TracksRepository {
  Future<List<InterviewTrack>> getTracks();

  Future<InterviewTrack?> getTrack(String trackId);

  Future<InterviewTrack> createTrack({
    required String title,
    required String company,
    required String jobDescription,
  });

  Future<void> markPrepCompleted(String trackId);

  Future<void> incrementCycle(String trackId);
}
