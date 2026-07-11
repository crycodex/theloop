import '../../../home_dashboard/domain/entities/home_dashboard.dart';
import '../../../interview_call/domain/entities/transcript_turn.dart';

class SessionRecap {
  const SessionRecap({
    required this.level,
    required this.delta,
    required this.title,
    required this.summary,
    required this.criteria,
    required this.strength,
    required this.improvement,
    this.loopId = '',
    this.transcript = const [],
    this.recommendation = '',
  });

  final double level;
  final double delta;
  final String title;
  final String summary;
  final List<CriterionProgress> criteria;
  final String strength;
  final String improvement;
  final String loopId;
  final List<TranscriptTurn> transcript;
  final String recommendation;
}
