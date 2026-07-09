import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_roadmap.dart';
import 'roadmap_state.dart';

class RoadmapCubit extends Cubit<RoadmapState> {
  RoadmapCubit(this._getRoadmap) : super(const RoadmapInitial()) {
    load();
  }

  final GetRoadmap _getRoadmap;

  void load() {
    emit(RoadmapLoaded(_getRoadmap()));
  }
}
