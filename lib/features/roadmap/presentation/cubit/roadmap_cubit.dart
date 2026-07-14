import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/settings/cubit/settings_cubit.dart';
import '../../../loops/domain/entities/interview_track.dart';
import '../../../loops/domain/repositories/tracks_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../data/services/roadmap_service.dart';
import '../../domain/entities/roadmap.dart';
import '../../domain/repositories/roadmap_repository.dart';
import 'roadmap_state.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  RoadmapCubit(
    this._repository,
    this._service,
    this._profileRepository,
    this._tracksRepository,
    this._settingsCubit,
  ) : super(const RoadmapLoading()) {
    load();
  }

  final RoadmapRepository _repository;
  final RoadmapService _service;
  final ProfileRepository _profileRepository;
  final TracksRepository _tracksRepository;
  final SettingsCubit _settingsCubit;

  Future<void> load() async {
    emit(const RoadmapLoading());
    try {
      final roadmap = await _repository.getLatest();
      if (roadmap == null || roadmap.steps.isEmpty) {
        emit(const RoadmapEmpty());
        return;
      }
      final tracks = await _tracksRepository.getTracks();
      emit(RoadmapLoaded(_withDerivedStates(roadmap, tracks)));
    } catch (_) {
      emit(const RoadmapEmpty());
    }
  }

  Future<void> generate() async {
    emit(const RoadmapGenerating());
    try {
      final language = _settingsCubit.state.language;
      final strings = AppStrings(language);
      final profile = await _profileRepository.getProfile();
      final goalLabel = profile.target == 'custom'
          ? (profile.customGoal ?? strings.goalCustom)
          : strings.goalLabel(profile.target);
      final tracks = await _tracksRepository.getTracks();

      final roadmap = await _service.generate(
        goalLabel: goalLabel,
        experience: profile.experience,
        tracks: tracks,
        language: language,
      );
      await _repository.saveLatest(roadmap);
      emit(RoadmapLoaded(_withDerivedStates(roadmap, tracks)));
    } catch (error) {
      emit(RoadmapError(error.toString()));
    }
  }

  /// El avance se deriva de los ciclos completados en todos los trayectos:
  /// el último paso solo se completa avanzando más allá de él.
  Roadmap _withDerivedStates(Roadmap roadmap, List<InterviewTrack> tracks) {
    final totalCycles = tracks.fold<int>(
      0,
      (sum, track) => sum + track.cyclesCompleted,
    );
    final completed = min(totalCycles, roadmap.steps.length - 1);
    final steps = [
      for (var i = 0; i < roadmap.steps.length; i++)
        roadmap.steps[i].copyWith(
          state: i < completed
              ? RoadmapStepState.completed
              : i == completed
                  ? RoadmapStepState.current
                  : RoadmapStepState.locked,
        ),
    ];
    return roadmap.copyWith(steps: steps);
  }
}
