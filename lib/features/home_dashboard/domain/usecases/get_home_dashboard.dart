import '../entities/home_dashboard.dart';
import '../repositories/home_dashboard_repository.dart';

class GetHomeDashboard {
  const GetHomeDashboard(this._repository);

  final HomeDashboardRepository _repository;

  HomeDashboard call() => _repository.getDashboard();
}
