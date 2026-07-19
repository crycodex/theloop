import '../entities/home_dashboard.dart';

abstract interface class HomeDashboardRepository {
  Future<HomeDashboard> getDashboard();
}
