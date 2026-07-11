import '../../domain/entities/loop_track.dart';
import '../../domain/repositories/loops_repository.dart';

class MockLoopsRepository implements LoopsRepository {
  const MockLoopsRepository();

  @override
  Future<List<LoopTrack>> getTracks() async {
    return const [
      LoopTrack(
        roleTitle: 'Mobile Engineer',
        company: 'Meta',
        level: 3.7,
        cyclesCompleted: 8,
        delta: 0.4,
        progress: 0.74,
        focus: 'Ownership y conflictos técnicos',
      ),
      LoopTrack(
        roleTitle: 'Senior Flutter Engineer',
        company: 'Spotify',
        level: 3.2,
        cyclesCompleted: 5,
        delta: 0.3,
        progress: 0.58,
        focus: 'Colaboración cross-functional',
      ),
      LoopTrack(
        roleTitle: 'AI Product Engineer',
        company: 'OpenAI',
        level: 2.8,
        cyclesCompleted: 3,
        delta: 0.5,
        progress: 0.42,
        focus: 'Ambiguedad y toma de decisiones',
      ),
    ];
  }
}
