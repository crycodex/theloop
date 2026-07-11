import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/settings/cubit/settings_cubit.dart';
import '../../../loops/domain/entities/interview_track.dart';
import '../../../loops/domain/repositories/tracks_repository.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/gemini_config.dart';
import '../../data/services/gemini_live_service.dart';
import '../../data/services/interview_prompt.dart';
import '../../data/services/interview_report_service.dart';
import '../../domain/repositories/interview_loop_repository.dart';
import 'interview_call_state.dart';

class InterviewCallCubit extends Cubit<InterviewCallState> {
  InterviewCallCubit(
    this._live,
    this._audio,
    this._reports,
    this._loops,
    this._profiles,
    this._tracks,
    this._settings,
  ) : super(const InterviewCallState.initial());

  final GeminiLiveService _live;
  final InterviewAudioService _audio;
  final InterviewReportService _reports;
  final InterviewLoopRepository _loops;
  final ProfileRepository _profiles;
  final TracksRepository _tracks;
  final SettingsCubit _settings;
  StreamSubscription<LiveEvent>? _liveSubscription;
  Timer? _timer;

  Future<void> start({
    String? sourceLoopId,
    String? trackId,
    LoopType loopType = LoopType.interview,
  }) async {
    if (state.phase == InterviewCallPhase.connecting ||
        state.phase == InterviewCallPhase.inCall) {
      return;
    }

    final settings = _settings.state;
    final isPrep = loopType == LoopType.prep;

    emit(
      InterviewCallState.initial().copyWith(
        phase: InterviewCallPhase.connecting,
        trackId: trackId,
        isPrep: isPrep,
        remainingSeconds: kLoopDurationSeconds,
      ),
    );

    try {
      if (!await _audio.requestMicrophonePermission()) {
        throw const GeminiLiveException(
          'Se necesita permiso de micrófono para iniciar la llamada.',
        );
      }

      if (trackId == null || trackId.isEmpty) {
        throw const GeminiLiveException(
          'Se necesita un trayecto para iniciar el loop.',
        );
      }

      final profile = await _profiles.getProfile();
      final previousLoop = sourceLoopId == null
          ? null
          : await _loops.getLoop(trackId: trackId, loopId: sourceLoopId);
      final track = await _tracks.getTrack(trackId);

      final systemPrompt = isPrep
          ? buildPrepSystemPrompt(
              profile: profile,
              language: settings.language,
              track: track ??
                  InterviewTrack(
                    id: trackId,
                    title: profile.target,
                    company: '',
                    jobDescription: profile.customGoal ?? '',
                    prepCompleted: false,
                    cyclesCompleted: 0,
                    createdAt: DateTime.now(),
                  ),
            )
          : buildInterviewSystemPrompt(
              profile: profile,
              language: settings.language,
              previousLoop: previousLoop,
              track: track,
            );

      final loopId = await _loops.createActiveLoop(
        trackId: trackId,
        sourceLoopId: sourceLoopId,
        loopType: loopType,
        profileSnapshot: {
          'name': profile.name,
          'goal': profile.target,
          'customGoal': profile.customGoal,
          'experience': profile.experience,
        },
      );

      emit(state.copyWith(loopId: loopId));
      await _liveSubscription?.cancel();
      _liveSubscription = _live.events.listen(_onLiveEvent);
      await _live.connect(
        systemPrompt: systemPrompt,
        voice: settings.recruiterVoice,
      );
    } catch (error) {
      await _fail(error);
    }
  }

  void toggleMic() {
    emit(state.copyWith(isMicEnabled: !state.isMicEnabled));
  }

  Future<String?> end() async {
    if (state.phase != InterviewCallPhase.inCall) return state.loopId;
    final loopId = state.loopId;
    final trackId = state.trackId;
    final elapsed = state.elapsedSeconds;
    final isPrep = state.isPrep;
    emit(state.copyWith(phase: InterviewCallPhase.ending));
    await _stopRealtime();

    if (loopId == null || trackId == null || trackId.isEmpty) {
      await _fail(const GeminiLiveException('La llamada no tiene sesión.'));
      return null;
    }

    final tooShort = elapsed < kMinReportSeconds;
    if (state.transcript.isEmpty || tooShort) {
      await _loops.abandonLoop(trackId: trackId, loopId: loopId);
      emit(const InterviewCallState.initial());
      return null;
    }

    if (isPrep) {
      await _loops.completePrepLoop(
        trackId: trackId,
        loopId: loopId,
        transcript: state.transcript,
        durationSeconds: elapsed,
      );
      await _tracks.markPrepCompleted(trackId);
      emit(
        state.copyWith(
          phase: InterviewCallPhase.completed,
          isAiSpeaking: false,
        ),
      );
      return trackId;
    }

    try {
      final report = await _reports.generateReport(
        transcript: state.transcript,
        language: _settings.state.language,
      );
      await _loops.completeLoop(
        trackId: trackId,
        loopId: loopId,
        transcript: state.transcript,
        report: report,
        durationSeconds: elapsed,
      );
      await _tracks.incrementCycle(trackId);
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
    final trackId = state.trackId;
    await _stopRealtime();
    if (loopId != null &&
        trackId != null &&
        trackId.isNotEmpty &&
        state.phase != InterviewCallPhase.completed &&
        state.transcript.isEmpty) {
      try {
        await _loops.abandonLoop(trackId: trackId, loopId: loopId);
      } catch (_) {}
    }
    emit(const InterviewCallState.initial());
  }

  Future<void> _onLiveEvent(LiveEvent event) async {
    switch (event) {
      case LiveSetupComplete():
        final language = _settings.state.language;
        await _audio.setupPlayer();
        _audio.onPlaybackDone = () {
          if (!isClosed) emit(state.copyWith(isAiSpeaking: false));
        };
        await _audio.startMic((pcm) {
          if (state.phase == InterviewCallPhase.inCall &&
              state.isMicEnabled &&
              !_audio.isPlaying) {
            _live.sendAudio(pcm);
          }
        });
        _live.startConversation(
          message: state.isPrep
              ? prepStartMessage(language)
              : liveStartMessage(language),
        );
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) async {
          if (isClosed || state.phase != InterviewCallPhase.inCall) return;
          final next = state.remainingSeconds - 1;
          if (next <= 0) {
            await end();
            return;
          }
          emit(state.copyWith(remainingSeconds: next));
        });
        emit(state.copyWith(phase: InterviewCallPhase.inCall));
      case LiveAudioChunk(:final pcm):
        _audio.play(pcm);
        emit(state.copyWith(isAiSpeaking: true));
      case LiveInterrupted():
        _audio.clearPlayback();
        emit(state.copyWith(isAiSpeaking: false));
      case LiveTranscriptUpdated(:final transcript):
        emit(state.copyWith(transcript: transcript));
      case LiveTurnComplete():
        break;
      case LiveClosed(:final reason):
        await _fail(GeminiLiveException(reason));
    }
  }

  Future<void> _stopRealtime() async {
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
    final trackId = state.trackId;
    if (abandon && loopId != null && trackId != null && trackId.isNotEmpty) {
      try {
        await _loops.abandonLoop(trackId: trackId, loopId: loopId);
      } catch (_) {}
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
    _reports.dispose();
    return super.close();
  }
}
