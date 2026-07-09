import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_latest_recap.dart';
import 'recap_state.dart';

class RecapCubit extends Cubit<RecapState> {
  RecapCubit(this._getLatestRecap) : super(const RecapInitial()) {
    load();
  }

  final GetLatestRecap _getLatestRecap;

  void load() {
    emit(RecapLoaded(_getLatestRecap()));
  }
}
