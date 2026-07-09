import 'package:flutter_bloc/flutter_bloc.dart';

import 'interview_call_state.dart';

class InterviewCallCubit extends Cubit<InterviewCallState> {
  InterviewCallCubit() : super(const InterviewCallState.initial());

  void toggleMic() {
    emit(state.copyWith(isMicEnabled: !state.isMicEnabled));
  }

  void togglePause() {
    emit(state.copyWith(isPaused: !state.isPaused));
  }
}
