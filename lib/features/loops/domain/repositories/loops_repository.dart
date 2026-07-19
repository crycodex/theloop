import '../entities/loop_track.dart';

abstract interface class LoopsRepository {
  Future<List<LoopTrack>> getTracks();
}
