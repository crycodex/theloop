import '../entities/cv_analysis.dart';
import '../repositories/cv_analysis_repository.dart';

class GetCvAnalysis {
  const GetCvAnalysis(this._repository);

  final CvAnalysisRepository _repository;

  CvAnalysis call() => _repository.getAnalysis();
}
