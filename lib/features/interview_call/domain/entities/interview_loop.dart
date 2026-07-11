import 'interview_report.dart';
import 'transcript_turn.dart';

class InterviewLoop {
  const InterviewLoop({
    required this.id,
    required this.trackId,
    required this.status,
    required this.loopType,
    required this.startedAt,
    required this.durationSeconds,
    required this.profileName,
    required this.goal,
    required this.experience,
    required this.transcript,
    this.endedAt,
    this.sourceLoopId,
    this.report,
  });

  final String id;
  final String trackId;
  final String status;
  final String loopType;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;
  final String profileName;
  final String goal;
  final String experience;
  final String? sourceLoopId;
  final List<TranscriptTurn> transcript;
  final InterviewReport? report;

  bool get isCompleted => status == 'completed' && report != null;
}
