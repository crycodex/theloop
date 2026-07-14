import '../entities/roadmap.dart';

abstract interface class RoadmapRepository {
  Future<Roadmap?> getLatest();

  Future<void> saveLatest(Roadmap roadmap);
}
