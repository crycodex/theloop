import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_home_dashboard.dart';
import 'home_dashboard_state.dart';

class HomeDashboardCubit extends Cubit<HomeDashboardState> {
  HomeDashboardCubit(this._getHomeDashboard)
    : super(const HomeDashboardInitial()) {
    load();
  }

  final GetHomeDashboard _getHomeDashboard;

  void load() {
    emit(HomeDashboardLoaded(_getHomeDashboard()));
  }
}
