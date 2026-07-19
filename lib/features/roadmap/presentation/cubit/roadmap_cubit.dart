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

  /// `true` cuando los pasos tienen id estable (catálogo, o un roadmap
  /// redefinido con IA en su formato nuevo) y por lo tanto su progreso se
  /// deriva de `completedStepIds` en vez del conteo total de ciclos.
  bool _hasStepIds(Roadmap roadmap) =>
      roadmap.steps.isNotEmpty && roadmap.steps.every((step) => step.id.isNotEmpty);

  Future<void> load() async {
    emit(const RoadmapLoading());
    try {
      final tracks = await _tracksRepository.getTracks();

      // El roadmap personal (redefinido con IA, o generado para un goal
      // custom) manda sobre el catálogo global: si el usuario ya lo definió,
      // esa es su ruta.
      final personal = await _repository.getLatest();
      if (personal != null && personal.steps.isNotEmpty) {
        final derived = _hasStepIds(personal)
            ? _withCatalogStates(
                personal,
                await _repository.getCompletedStepIds(),
                tracks,
              )
            : _withDerivedStates(personal, tracks);
        emit(RoadmapLoaded(derived, userLevel: _userLevel(tracks)));
        return;
      }

      final catalog = await _loadCatalogRoadmap();
      if (catalog != null) {
        final completed = await _repository.getCompletedStepIds();
        emit(
          RoadmapLoaded(
            _withCatalogStates(catalog, completed, tracks),
            userLevel: _userLevel(tracks),
          ),
        );
        return;
      }

      emit(const RoadmapEmpty());
    } catch (_) {
      emit(const RoadmapEmpty());
    }
  }

  /// Genera (o redefine) el roadmap del usuario con IA. Al redefinir se
  /// reemplaza cualquier roadmap anterior (catálogo o personal) y se
  /// reinicia el progreso, porque los ids de los pasos ya no existen.
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
      await _repository.resetProgress();
      await _repository.saveLatest(roadmap);
      final completed = await _repository.getCompletedStepIds();
      emit(
        RoadmapLoaded(
          _withCatalogStates(roadmap, completed, tracks),
          userLevel: _userLevel(tracks),
        ),
      );
    } catch (error) {
      emit(RoadmapError(error.toString()));
    }
  }

  /// Marca la lección como completada y refresca los estados de los pasos
  /// sin volver a leer el catálogo.
  Future<void> completeStep(String stepId) async {
    final current = state;
    await _repository.markStepCompleted(stepId);
    if (current is! RoadmapLoaded || !_hasStepIds(current.roadmap)) {
      await load();
      return;
    }
    final completed = await _repository.getCompletedStepIds();
    final tracks = await _tracksRepository.getTracks();
    emit(
      RoadmapLoaded(
        _withCatalogStates(current.roadmap, completed, tracks),
        userLevel: _userLevel(tracks),
      ),
    );
  }

  /// El nivel se identifica con la primera llamada: el mayor nivel logrado
  /// entre los trayectos con al menos un ciclo completado.
  double? _userLevel(List<InterviewTrack> tracks) {
    final levels = tracks
        .where((track) => track.cyclesCompleted > 0)
        .map((track) => track.latestLevel);
    if (levels.isEmpty) return null;
    return levels.reduce(max);
  }

  Future<Roadmap?> _loadCatalogRoadmap() async {
    try {
      final profile = await _profileRepository.getProfile();
      if (profile.target == 'custom') return null;
      return await _repository.getCatalogForGoal(
        profile.target,
        _settingsCubit.state.language,
      );
    } catch (_) {
      return null;
    }
  }

  /// Catálogo: un paso lección se completa al aprobar su quiz; el paso de
  /// llamada se completa al terminar al menos un ciclo de loop.
  Roadmap _withCatalogStates(
    Roadmap roadmap,
    Set<String> completedIds,
    List<InterviewTrack> tracks,
  ) {
    final hasCycles = tracks.any((track) => track.cyclesCompleted > 0);
    var currentAssigned = false;
    final steps = <RoadmapStep>[];
    for (final step in roadmap.steps) {
      final isCompleted = completedIds.contains(step.id) ||
          (step.type == RoadmapStepType.call && hasCycles);
      if (isCompleted) {
        steps.add(step.copyWith(state: RoadmapStepState.completed));
      } else if (!currentAssigned) {
        currentAssigned = true;
        steps.add(step.copyWith(state: RoadmapStepState.current));
      } else {
        steps.add(step.copyWith(state: RoadmapStepState.locked));
      }
    }
    return roadmap.copyWith(steps: steps);
  }

  /// Generado con Gemini: el avance se deriva de los ciclos completados en
  /// todos los trayectos; el último paso solo se completa avanzando más allá.
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
