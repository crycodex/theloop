import '../entities/roadmap.dart';
import '../repositories/roadmap_repository.dart';

class GetRoadmap {
  const GetRoadmap(this._repository);

  final RoadmapRepository _repository;

  Roadmap call() => _repository.getRoadmap();
}
