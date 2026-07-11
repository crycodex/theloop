import '../entities/session_recap.dart';

abstract interface class RecapRepository {
  Future<SessionRecap?> getRecap(String? loopId);
}
