import '../../domain/entities/roadmap.dart';

sealed class RoadmapState {
  const RoadmapState();
}

class RoadmapInitial extends RoadmapState {
  const RoadmapInitial();
}

class RoadmapLoaded extends RoadmapState {
  const RoadmapLoaded(this.roadmap);

  final Roadmap roadmap;
}
