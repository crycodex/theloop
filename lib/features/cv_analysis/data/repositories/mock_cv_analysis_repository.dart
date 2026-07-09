import '../../../../core/theme/loop_colors.dart';
import '../../domain/entities/cv_analysis.dart';
import '../../domain/repositories/cv_analysis_repository.dart';

class MockCvAnalysisRepository implements CvAnalysisRepository {
  const MockCvAnalysisRepository();

  @override
  CvAnalysis getAnalysis() {
    return const CvAnalysis(
      score: 82,
      lastAnalyzedLabel: 'hoy',
      matchScore: 76,
      matchSummary:
          'Tu CV ya comunica experiencia mobile fuerte. Falta cuantificar impacto en performance, calidad y liderazgo tecnico.',
      criteria: [
        CvCriterion(
          name: 'Experiencia relevante',
          score: 0.84,
          color: LoopColors.lightGreen,
        ),
        CvCriterion(
          name: 'Logros medibles',
          score: 0.64,
          color: LoopColors.amber,
        ),
        CvCriterion(
          name: 'Claridad narrativa',
          score: 0.78,
          color: LoopColors.infoBlue,
        ),
        CvCriterion(
          name: 'Formato ATS',
          score: 0.91,
          color: LoopColors.lightGreen,
        ),
      ],
    );
  }
}
