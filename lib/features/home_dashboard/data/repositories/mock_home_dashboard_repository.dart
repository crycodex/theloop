import '../../../loops/domain/repositories/loops_repository.dart';
import '../../domain/entities/home_dashboard.dart';
import '../../domain/repositories/home_dashboard_repository.dart';

class MockHomeDashboardRepository implements HomeDashboardRepository {
  const MockHomeDashboardRepository(this._loopsRepository);

  final LoopsRepository _loopsRepository;

  @override
  HomeDashboard getDashboard() {
    final tracks = _loopsRepository.getTracks();

    return HomeDashboard(
      userName: 'Cristhian',
      target: 'Mobile Engineer · Meta',
      generalLevel: 3.7,
      streakDays: 6,
      totalLoops: 18,
      latestTrack: tracks.first,
      criteria: const [
        CriterionProgress(name: 'Estructura STAR', score: 0.82, trend: '+0.4'),
        CriterionProgress(name: 'Impacto medible', score: 0.68, trend: '+0.2'),
        CriterionProgress(name: 'Claridad', score: 0.76, trend: '+0.3'),
        CriterionProgress(name: 'Profundidad', score: 0.61, trend: 'plano'),
      ],
    );
  }
}
