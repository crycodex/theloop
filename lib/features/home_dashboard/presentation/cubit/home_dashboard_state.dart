import '../../domain/entities/home_dashboard.dart';

sealed class HomeDashboardState {
  const HomeDashboardState();
}

class HomeDashboardInitial extends HomeDashboardState {
  const HomeDashboardInitial();
}

class HomeDashboardLoaded extends HomeDashboardState {
  const HomeDashboardLoaded(this.dashboard);

  final HomeDashboard dashboard;
}
