import '../../domain/entities/loop_track.dart';
import '../../domain/repositories/loops_repository.dart';
import '../../domain/repositories/tracks_repository.dart';

class FirestoreLoopsRepository implements LoopsRepository {
  const FirestoreLoopsRepository(this._tracks);

  final TracksRepository _tracks;

  @override
  Future<List<LoopTrack>> getTracks() async {
    final tracks = await _tracks.getTracks();
    return tracks
        .map(
          (track) => LoopTrack(
            id: track.id,
            roleTitle: track.title,
            company: track.company.isEmpty ? 'Entrevista IA' : track.company,
            level: track.latestLevel > 0
                ? track.latestLevel
                : track.cyclesCompleted.toDouble(),
            cyclesCompleted: track.cyclesCompleted,
            delta: 0,
            progress: track.prepCompleted
                ? (track.cyclesCompleted / 5).clamp(0, 1)
                : 0.1,
            focus: track.jobDescription,
            prepCompleted: track.prepCompleted,
          ),
        )
        .toList(growable: false);
  }
}
