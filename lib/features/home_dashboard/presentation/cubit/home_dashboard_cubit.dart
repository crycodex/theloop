import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_home_dashboard.dart';
import 'home_dashboard_state.dart';

class HomeDashboardCubit extends Cubit<HomeDashboardState> {
  HomeDashboardCubit(this._getHomeDashboard)
    : super(const HomeDashboardInitial()) {
    load();
  }

  final GetHomeDashboard _getHomeDashboard;

  Future<void> load() async {
    emit(const HomeDashboardInitial());
    try {
      emit(HomeDashboardLoaded(await _getHomeDashboard()));
    } catch (error) {
      emit(HomeDashboardError(error.toString()));
    }
  }
}
