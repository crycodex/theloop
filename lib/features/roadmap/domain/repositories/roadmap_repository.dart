import '../../../../core/settings/cubit/settings_state.dart';
import '../entities/roadmap.dart';

abstract interface class RoadmapRepository {
  Future<Roadmap?> getLatest();

  Future<void> saveLatest(Roadmap roadmap);

  /// Roadmap predefinido del catálogo global `roadmap_catalog/{goalId}`,
  /// o `null` si el goal no tiene catálogo (p.ej. objetivo custom).
  Future<Roadmap?> getCatalogForGoal(String goalId, AppLanguage language);

  /// Ids de pasos del catálogo completados por el usuario.
  Future<Set<String>> getCompletedStepIds();

  Future<void> markStepCompleted(String stepId);

  /// Limpia `completedStepIds`: se usa al redefinir el roadmap con IA, ya
  /// que los ids de pasos anteriores dejan de existir.
  Future<void> resetProgress();
}
