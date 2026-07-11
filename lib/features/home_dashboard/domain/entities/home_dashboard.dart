import '../../../loops/domain/entities/loop_track.dart';

class HomeDashboard {
  const HomeDashboard({
    required this.userName,
    required this.target,
    required this.generalLevel,
    required this.streakDays,
    required this.totalLoops,
    required this.criteria,
    required this.latestTrack,
  });

  final String userName;
  final String target;
  final double generalLevel;
  final int streakDays;
  final int totalLoops;
  final List<CriterionProgress> criteria;
  final LoopTrack? latestTrack;
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
