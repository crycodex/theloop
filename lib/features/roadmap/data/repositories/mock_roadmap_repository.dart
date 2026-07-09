import '../../domain/entities/roadmap.dart';
import '../../domain/repositories/roadmap_repository.dart';

class MockRoadmapRepository implements RoadmapRepository {
  const MockRoadmapRepository();

  @override
  Roadmap getRoadmap() {
    return const Roadmap(
      target: 'Mobile Engineer · Meta',
      finalGoal: 'simulación behavioral para Meta',
      steps: [
        RoadmapStep(
          title: 'Define tu historia profesional',
          category: 'Foundation',
          state: RoadmapStepState.completed,
          level: 3.4,
        ),
        RoadmapStep(
          title: 'Practica ownership con STAR',
          category: 'Behavioral',
          state: RoadmapStepState.completed,
          level: 3.7,
        ),
        RoadmapStep(
          title: 'Mejora resultados cuantificados',
          category: 'Behavioral',
          state: RoadmapStepState.current,
          level: null,
        ),
        RoadmapStep(
          title: 'Simulación final Meta',
          category: 'Mock interview',
          state: RoadmapStepState.locked,
          level: null,
        ),
      ],
    );
  }
}
