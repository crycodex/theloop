import '../../domain/entities/session_recap.dart';

sealed class RecapState {
  const RecapState();
}

class RecapInitial extends RecapState {
  const RecapInitial();
}

class RecapLoaded extends RecapState {
  const RecapLoaded(this.recap);

  final SessionRecap recap;
}
