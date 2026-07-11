import '../../../interview_call/domain/repositories/interview_loop_repository.dart';
import '../../../loops/domain/repositories/loops_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../../core/utils/streak_calculator.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_dashboard_repository.dart';

class FirestoreHomeDashboardRepository implements HomeDashboardRepository {
  const FirestoreHomeDashboardRepository(
    this._profiles,
    this._loops,
    this._interviewLoops,
  );

  final ProfileRepository _profiles;
  final LoopsRepository _loops;
  final InterviewLoopRepository _interviewLoops;

  @override
  Future<HomeDashboard> getDashboard() async {
    final profile = await _profiles.getProfile();
    final tracks = await _loops.getTracks();
    final trackIds = tracks.map((track) => track.id).toList(growable: false);
    final practiceDates =
        await _interviewLoops.getCompletedPracticeDates(trackIds);
    final totalLoops = practiceDates.length;
    final streakDays = computePracticeStreak(practiceDates);
    final measured = tracks.where((track) => track.cyclesCompleted > 0).toList();
    final latest = measured.isEmpty
        ? (tracks.isEmpty ? null : tracks.first)
        : measured.first;
    final score = latest?.progress ?? 0;

    return HomeDashboard(
      userName: profile.name,
      target: profile.customGoal?.isNotEmpty == true
          ? profile.customGoal!
          : profile.target,
      generalLevel: latest?.level ?? 0,
      streakDays: streakDays,
      totalLoops: totalLoops,
      totalTracks: tracks.length,
      tracks: tracks,
      hasMeasuredLevel: measured.isNotEmpty,
      criteria: measured.isEmpty
          ? const []
          : [
              CriterionProgress(
                name: 'Desempeño de entrevista',
                score: score,
                trend: '${(score * 10).toStringAsFixed(1)}/10',
              ),
            ],
    );
  }
}
