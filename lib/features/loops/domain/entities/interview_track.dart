enum LoopType { prep, interview }

class InterviewTrack {
  const InterviewTrack({
    required this.id,
    required this.title,
    required this.company,
    required this.jobDescription,
    required this.prepCompleted,
    required this.cyclesCompleted,
    required this.createdAt,
    this.latestScore = 0,
    this.latestLevel = 0,
  });

  final String id;
  final String title;
  final String company;
  final String jobDescription;
  final bool prepCompleted;
  final int cyclesCompleted;
  final DateTime createdAt;
  final double latestScore;
  final double latestLevel;
}
