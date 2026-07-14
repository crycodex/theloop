import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/settings/cubit/settings_cubit.dart';
import '../../../loops/domain/entities/interview_track.dart';
import '../../../loops/domain/repositories/tracks_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../data/services/cv_analysis_service.dart';
import '../../domain/repositories/cv_analysis_repository.dart';
import 'cv_analysis_state.dart';

class CvAnalysisCubit extends Cubit<CvAnalysisState> {
  CvAnalysisCubit(
    this._repository,
    this._service,
    this._profileRepository,
    this._tracksRepository,
    this._settingsCubit,
  ) : super(const CvAnalysisLoading()) {
    load();
  }

  final CvAnalysisRepository _repository;
  final CvAnalysisService _service;
  final ProfileRepository _profileRepository;
  final TracksRepository _tracksRepository;
  final SettingsCubit _settingsCubit;

  List<InterviewTrack> _tracks = const [];

  Future<void> load() async {
    emit(const CvAnalysisLoading());
    try {
      final analysisFuture = _repository.getLatest();
      final tracksFuture = _tracksRepository.getTracks();
      final analysis = await analysisFuture;
      _tracks = await tracksFuture;
      if (analysis == null) {
        emit(CvAnalysisEmpty(_tracks));
      } else {
        emit(CvAnalysisLoaded(analysis, _tracks));
      }
    } catch (_) {
      emit(CvAnalysisEmpty(_tracks));
    }
  }

  Future<void> analyze(Uint8List pdfBytes, {String? trackId}) async {
    emit(const CvAnalysisAnalyzing());
    try {
      final language = _settingsCubit.state.language;
      final strings = AppStrings(language);
      final profile = await _profileRepository.getProfile();
      final goalLabel = profile.target == 'custom'
          ? (profile.customGoal ?? strings.goalCustom)
          : strings.goalLabel(profile.target);
      final track = trackId == null
          ? null
          : await _tracksRepository.getTrack(trackId);

      final analysis = await _service.analyze(
        pdfBytes: pdfBytes,
        goalLabel: goalLabel,
        experience: profile.experience,
        track: track,
        language: language,
      );
      await _repository.saveLatest(analysis);
      emit(CvAnalysisLoaded(analysis, _tracks));
    } catch (error) {
      emit(CvAnalysisError(error.toString(), _tracks));
    }
  }
}
