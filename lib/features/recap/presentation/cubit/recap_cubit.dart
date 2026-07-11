import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_latest_recap.dart';
import 'recap_state.dart';

class RecapCubit extends Cubit<RecapState> {
  RecapCubit(this._getLatestRecap) : super(const RecapInitial());

  final GetLatestRecap _getLatestRecap;

  Future<void> load([String? loopId]) async {
    emit(const RecapInitial());
    try {
      final recap = await _getLatestRecap(loopId);
      emit(recap == null ? const RecapEmpty() : RecapLoaded(recap));
    } catch (error) {
      emit(RecapError(error.toString()));
    }
  }
}
