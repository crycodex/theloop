import '../../domain/entities/cv_analysis.dart';

sealed class CvAnalysisState {
  const CvAnalysisState();
}

class CvAnalysisInitial extends CvAnalysisState {
  const CvAnalysisInitial();
}

class CvAnalysisLoaded extends CvAnalysisState {
  const CvAnalysisLoaded(this.analysis);

  final CvAnalysis analysis;
}
