import '../../domain/entities/roadmap.dart';

sealed class RoadmapState {
  const RoadmapState();
}

class RoadmapLoading extends RoadmapState {
  const RoadmapLoading();
}

class RoadmapEmpty extends RoadmapState {
  const RoadmapEmpty();
}

class RoadmapGenerating extends RoadmapState {
  const RoadmapGenerating();
}

class RoadmapLoaded extends RoadmapState {
  const RoadmapLoaded(this.roadmap);

  final Roadmap roadmap;
}

class RoadmapError extends RoadmapState {
  const RoadmapError(this.message);

  final String message;
}
