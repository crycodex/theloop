import '../entities/session_recap.dart';

abstract interface class RecapRepository {
  Future<SessionRecap?> getRecap({
    required String trackId,
    required String loopId,
  });
}
