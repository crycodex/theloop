import '../entities/cv_analysis.dart';

abstract interface class CvAnalysisRepository {
  Future<CvAnalysis?> getLatest();

  Future<void> saveLatest(CvAnalysis analysis);
}
