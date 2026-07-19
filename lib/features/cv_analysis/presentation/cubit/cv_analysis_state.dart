import '../../../loops/domain/entities/interview_track.dart';
import '../../domain/entities/cv_analysis.dart';

sealed class CvAnalysisState {
  const CvAnalysisState();
}

class CvAnalysisLoading extends CvAnalysisState {
  const CvAnalysisLoading();
}

class CvAnalysisEmpty extends CvAnalysisState {
  const CvAnalysisEmpty(this.tracks);

  final List<InterviewTrack> tracks;
}

class CvAnalysisAnalyzing extends CvAnalysisState {
  const CvAnalysisAnalyzing();
}

class CvAnalysisLoaded extends CvAnalysisState {
  const CvAnalysisLoaded(this.analysis, this.tracks);

  final CvAnalysis analysis;
  final List<InterviewTrack> tracks;
}

class CvAnalysisError extends CvAnalysisState {
  const CvAnalysisError(this.message, this.tracks);

  final String message;
  final List<InterviewTrack> tracks;
}
