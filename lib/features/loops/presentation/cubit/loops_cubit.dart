import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_loop_tracks.dart';
import 'loops_state.dart';

class LoopsCubit extends Cubit<LoopsState> {
  LoopsCubit(this._getLoopTracks) : super(const LoopsInitial()) {
    load();
  }

  final GetLoopTracks _getLoopTracks;

  void load() {
    emit(LoopsLoaded(_getLoopTracks()));
  }
}
