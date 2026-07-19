import '../entities/session_recap.dart';
import '../repositories/recap_repository.dart';

class GetLatestRecap {
  const GetLatestRecap(this._repository);

  final RecapRepository _repository;

  Future<SessionRecap?> call({
    required String trackId,
    required String loopId,
  }) =>
      _repository.getRecap(trackId: trackId, loopId: loopId);
}
