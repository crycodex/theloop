import '../../../loops/domain/entities/loop_track.dart';

class HomeDashboard {
  const HomeDashboard({
    required this.userName,
    required this.target,
    required this.generalLevel,
    required this.streakDays,
    required this.totalLoops,
    required this.totalTracks,
    required this.criteria,
    required this.tracks,
    required this.hasMeasuredLevel,
  });

  final String userName;
  final String target;
  final double generalLevel;
  final int streakDays;
  final int totalLoops;
  final int totalTracks;
  final List<CriterionProgress> criteria;
  final List<LoopTrack> tracks;
  final bool hasMeasuredLevel;

  LoopTrack? get latestTrack => tracks.isEmpty ? null : tracks.first;

  bool get hasTracks => tracks.isNotEmpty;
}

class CriterionProgress {
  const CriterionProgress({
    required this.name,
    required this.score,
    required this.trend,
  });

  final String name;
  final double score;
  final String trend;
}
