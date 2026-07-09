import '../entities/loop_track.dart';
import '../repositories/loops_repository.dart';

class GetLoopTracks {
  const GetLoopTracks(this._repository);

  final LoopsRepository _repository;

  List<LoopTrack> call() => _repository.getTracks();
}
