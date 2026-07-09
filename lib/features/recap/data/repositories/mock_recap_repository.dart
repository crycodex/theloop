import '../../../home_dashboard/domain/entities/home_dashboard.dart';
import '../../domain/entities/session_recap.dart';
import '../../domain/repositories/recap_repository.dart';

class MockRecapRepository implements RecapRepository {
  const MockRecapRepository();

  @override
  SessionRecap getLatestRecap() {
    return const SessionRecap(
      level: 3.9,
      delta: 0.4,
      title: 'Buen avance',
      summary:
          'Tu respuesta fue más concreta y conectó mejor decisiones con resultados.',
      strength: 'Explicaste el contexto sin perder el foco del problema.',
      improvement: 'Cierra con una métrica antes de pasar a aprendizajes.',
      criteria: [
        CriterionProgress(name: 'Estructura STAR', score: 0.82, trend: '+0.4'),
        CriterionProgress(name: 'Impacto medible', score: 0.68, trend: '+0.2'),
        CriterionProgress(name: 'Claridad', score: 0.76, trend: '+0.3'),
        CriterionProgress(name: 'Profundidad', score: 0.61, trend: 'plano'),
      ],
    );
  }
}
