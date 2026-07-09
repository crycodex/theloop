import '../entities/session_recap.dart';

abstract interface class RecapRepository {
  SessionRecap getLatestRecap();
}
