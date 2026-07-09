import '../../../home_dashboard/domain/entities/home_dashboard.dart';

class SessionRecap {
  const SessionRecap({
    required this.level,
    required this.delta,
    required this.title,
    required this.summary,
    required this.criteria,
    required this.strength,
    required this.improvement,
  });

  final double level;
  final double delta;
  final String title;
  final String summary;
  final List<CriterionProgress> criteria;
  final String strength;
  final String improvement;
}
