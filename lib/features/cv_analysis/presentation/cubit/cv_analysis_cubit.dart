import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_cv_analysis.dart';
import 'cv_analysis_state.dart';

class CvAnalysisCubit extends Cubit<CvAnalysisState> {
  CvAnalysisCubit(this._getCvAnalysis) : super(const CvAnalysisInitial()) {
    load();
  }

  final GetCvAnalysis _getCvAnalysis;

  void load() {
    emit(CvAnalysisLoaded(_getCvAnalysis()));
  }
}
