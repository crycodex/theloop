import '../../../loops/domain/repositories/loops_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_dashboard_repository.dart';

class FirestoreHomeDashboardRepository implements HomeDashboardRepository {
  const FirestoreHomeDashboardRepository(this._profiles, this._loops);

  final ProfileRepository _profiles;
  final LoopsRepository _loops;

  @override
  Future<HomeDashboard> getDashboard() async {
    final profile = await _profiles.getProfile();
    final tracks = await _loops.getTracks();
    final totalLoops = tracks.fold<int>(
      0,
      (sum, track) => sum + track.cyclesCompleted,
    );
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
      streakDays: totalLoops > 0 ? 1 : 0,
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
