import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/services/audio_service.dart';
import '../../data/services/gemini_live_service.dart';
import '../../data/services/interview_api_service.dart';
import '../../domain/repositories/interview_loop_repository.dart';
import 'interview_call_state.dart';

class InterviewCallCubit extends Cubit<InterviewCallState> {
  InterviewCallCubit(
    this._api,
    this._live,
    this._audio,
    this._loops,
  ) : super(const InterviewCallState.initial());

  final InterviewApiService _api;
  final GeminiLiveService _live;
  final InterviewAudioService _audio;
  final InterviewLoopRepository _loops;
  StreamSubscription<LiveEvent>? _liveSubscription;
  Timer? _timer;
  bool _allowUserAudio = false;
  Future<void> start({String? sourceLoopId}) async {
    if (state.phase == InterviewCallPhase.connecting ||
        state.phase == InterviewCallPhase.inCall) {
      return;
    }
    emit(
      const InterviewCallState.initial().copyWith(
        phase: InterviewCallPhase.connecting,
      ),
    );
    try {
      if (!await _audio.requestMicrophonePermission()) {
        throw const InterviewApiException(
          'Se necesita permiso de micrófono para iniciar la llamada.',
        );
      }
      final credentials = await _api.createLiveToken(
        sourceLoopId: sourceLoopId,
      );
      emit(state.copyWith(loopId: credentials.loopId));
      await _liveSubscription?.cancel();
      _liveSubscription = _live.events.listen(_onLiveEvent);
      await _live.connect(credentials);
    } catch (error) {
      await _fail(error);
    }
  }

  void toggleMic() {
    emit(state.copyWith(isMicEnabled: !state.isMicEnabled));
  }

  Future<void> togglePause() async {
    if (state.phase != InterviewCallPhase.inCall) return;
    final paused = !state.isPaused;
    if (paused) {
      await _audio.pauseMic();
    } else {
      await _audio.resumeMic();
    }
    emit(state.copyWith(isPaused: paused));
  }

  Future<String?> end() async {
    if (state.phase != InterviewCallPhase.inCall) return state.loopId;
    final loopId = state.loopId;
    final elapsed = state.elapsedSeconds;
    emit(state.copyWith(phase: InterviewCallPhase.ending));
    await _stopRealtime();
    if (loopId == null) {
      await _fail(const InterviewApiException('La llamada no tiene sesión.'));
      return null;
    }
    if (state.transcript.isEmpty) {
      await _loops.abandonLoop(loopId);
      emit(const InterviewCallState.initial());
      return null;
    }
    try {
      final report = await _api.generateReport(
        loopId: loopId,
        transcript: state.transcript,
        durationSeconds: elapsed,
      );
      emit(
        state.copyWith(
          phase: InterviewCallPhase.completed,
          report: report,
          isAiSpeaking: false,
        ),
      );
      return loopId;
    } catch (error) {
      await _fail(error, abandon: false);
      return null;
    }
  }

  Future<void> cancel() async {
    final loopId = state.loopId;
    await _stopRealtime();
    if (loopId != null &&
        state.phase != InterviewCallPhase.completed &&
        state.transcript.isEmpty) {
      try {
        await _loops.abandonLoop(loopId);
      } catch (_) {
        // The server may not have created the loop yet.
      }
    }
    emit(const InterviewCallState.initial());
  }

  Future<void> _onLiveEvent(LiveEvent event) async {
    switch (event) {
      case LiveSetupComplete():
        _allowUserAudio = false;
        await _audio.setupPlayer();
        _audio.onPlaybackDone = () {
          if (!isClosed) emit(state.copyWith(isAiSpeaking: false));
        };
        _live.startConversation();
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          if (!isClosed && state.phase == InterviewCallPhase.inCall) {
            emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
          }
        });
        emit(state.copyWith(phase: InterviewCallPhase.inCall));
        await _audio.startMic((pcm) {
          if (!_allowUserAudio ||
              state.phase != InterviewCallPhase.inCall ||
              !state.isMicEnabled ||
              state.isPaused ||
              state.isAiSpeaking ||
              _audio.isPlaying) {
            return;
          }
          _live.sendAudio(pcm);
        });
      case LiveAudioChunk(:final pcm):
        _audio.play(pcm);
        emit(state.copyWith(isAiSpeaking: true));
      case LiveInterrupted():
        _audio.clearPlayback();
        emit(state.copyWith(isAiSpeaking: false));
      case LiveTranscriptUpdated(:final transcript):
        emit(state.copyWith(transcript: transcript));
      case LiveTurnComplete():
        _allowUserAudio = true;
      case LiveClosed(:final reason):
        await _fail(InterviewApiException(reason));
    }
  }

  Future<void> _stopRealtime() async {
    _allowUserAudio = false;
    _timer?.cancel();
    _timer = null;
    await _audio.stopMic();
    _audio.clearPlayback();
    await _live.disconnect();
    await _liveSubscription?.cancel();
    _liveSubscription = null;
  }

  Future<void> _fail(Object error, {bool abandon = true}) async {
    await _stopRealtime();
    final loopId = state.loopId;
    if (abandon && loopId != null) {
      try {
        await _loops.abandonLoop(loopId);
      } catch (_) {
        // Preserve the original connection error.
      }
    }
    emit(
      state.copyWith(
        phase: InterviewCallPhase.error,
        errorMessage: error.toString(),
        isAiSpeaking: false,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _stopRealtime();
    await _audio.dispose();
    await _live.dispose();
    _api.dispose();
    return super.close();
  }
}
