import '../../domain/entities/loop_track.dart';

sealed class LoopsState {
  const LoopsState();
}

class LoopsInitial extends LoopsState {
  const LoopsInitial();
}

class LoopsLoaded extends LoopsState {
  const LoopsLoaded(this.tracks);

  final List<LoopTrack> tracks;
}
