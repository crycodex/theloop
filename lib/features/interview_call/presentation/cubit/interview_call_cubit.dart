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
import '../../data/services/interview_session_end.dart';
import '../../domain/entities/interview_loop.dart';
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
  bool _endAfterSpeech = false;
  bool _endingInFlight = false;
  InterviewTrack? _activeTrack;
  bool _isFollowUpInterview = false;
  DateTime? _micOpensAt;

  /// Half-duplex: no enviar audio del candidato mientras el reclutador habla.
  bool get _canSendCandidateAudio {
    if (_micOpensAt != null && DateTime.now().isBefore(_micOpensAt!)) {
      return false;
    }
    return !_audio.isPlaying && !state.isAiSpeaking;
  }

  void _scheduleMicOpen({Duration delay = const Duration(milliseconds: 300)}) {
    _micOpensAt = DateTime.now().add(delay);
  }

  Future<void> start({
    String? sourceLoopId,
    String? trackId,
    LoopType loopType = LoopType.interview,
  }) async {
    if (state.phase == InterviewCallPhase.connecting ||
        state.phase == InterviewCallPhase.inCall ||
        state.phase == InterviewCallPhase.ending) {
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
    _endAfterSpeech = false;
    _endingInFlight = false;
    _micOpensAt = null;

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
      final track = await _tracks.getTrack(trackId);
      _activeTrack = track ??
          InterviewTrack(
            id: trackId,
            title: profile.target,
            company: '',
            jobDescription: profile.customGoal ?? '',
            prepCompleted: false,
            cyclesCompleted: 0,
            createdAt: DateTime.now(),
          );

      InterviewLoop? previousLoop;
      String? resolvedSourceLoopId = sourceLoopId;
      if (!isPrep) {
        if (resolvedSourceLoopId != null) {
          previousLoop = await _loops.getLoop(
            trackId: trackId,
            loopId: resolvedSourceLoopId,
          );
        } else {
          previousLoop =
              await _loops.getLatestCompletedInterviewLoop(trackId);
          resolvedSourceLoopId = previousLoop?.id;
        }
      }
      _isFollowUpInterview = !isPrep && previousLoop?.report != null;

      final systemPrompt = isPrep
          ? buildPrepSystemPrompt(
              profile: profile,
              language: settings.language,
              track: _activeTrack!,
            )
          : buildInterviewSystemPrompt(
              profile: profile,
              language: settings.language,
              previousLoop: previousLoop,
              track: _activeTrack,
            );

      final loopId = await _loops.createActiveLoop(
        trackId: trackId,
        sourceLoopId: resolvedSourceLoopId,
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

  Future<String?> end({CallEndReason? reason}) async {
    if (_endingInFlight) return state.loopId;
    if (state.phase != InterviewCallPhase.inCall) return state.loopId;
    _endingInFlight = true;
    _endAfterSpeech = false;
    final loopId = state.loopId;
    final trackId = state.trackId;
    final elapsed = state.elapsedSeconds;
    final isPrep = state.isPrep;
    final transcript = List.of(state.transcript);
    emit(state.copyWith(phase: InterviewCallPhase.ending));
    await _stopRealtime();

    if (loopId == null || trackId == null || trackId.isEmpty) {
      _endingInFlight = false;
      await _fail(const GeminiLiveException('La llamada no tiene sesión.'));
      return null;
    }

    final tooShort = elapsed < kMinReportSeconds;
    if (transcript.isEmpty || tooShort) {
      await _loops.abandonLoop(trackId: trackId, loopId: loopId);
      _endingInFlight = false;
      emit(const InterviewCallState.initial());
      return null;
    }

    if (isPrep) {
      await _loops.completePrepLoop(
        trackId: trackId,
        loopId: loopId,
        transcript: transcript,
        durationSeconds: elapsed,
      );
      await _tracks.markPrepCompleted(trackId);
      _endingInFlight = false;
      emit(
        state.copyWith(
          phase: InterviewCallPhase.completed,
          isAiSpeaking: false,
          transcript: transcript,
          endReason: reason,
        ),
      );
      return trackId;
    }

    try {
      final report = await _reports.generateReport(
        transcript: transcript,
        language: _settings.state.language,
      );
      await _loops.completeLoop(
        trackId: trackId,
        loopId: loopId,
        transcript: transcript,
        report: report,
        durationSeconds: elapsed,
      );
      await _tracks.incrementCycle(trackId);
      _endingInFlight = false;
      emit(
        state.copyWith(
          phase: InterviewCallPhase.completed,
          report: report,
          isAiSpeaking: false,
          transcript: transcript,
          endReason: reason,
        ),
      );
      return loopId;
    } catch (error) {
      _endingInFlight = false;
      await _fail(error, abandon: false);
      return null;
    }
  }

  Future<void> cancel() async {
    final loopId = state.loopId;
    final trackId = state.trackId;
    _endAfterSpeech = false;
    _endingInFlight = false;
    _micOpensAt = null;
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
          if (isClosed) return;
          _scheduleMicOpen();
          emit(state.copyWith(isAiSpeaking: false));
          if (_endAfterSpeech && state.phase == InterviewCallPhase.inCall) {
            _endAfterSpeech = false;
            unawaited(end(reason: CallEndReason.closingPhraseDetected));
          }
        };
        await _audio.startMic((pcm) {
          if (state.phase == InterviewCallPhase.inCall &&
              state.isMicEnabled &&
              _canSendCandidateAudio) {
            _live.sendAudio(pcm);
          }
        });
        _live.startConversation(
          message: state.isPrep
              ? prepStartMessage(
                  language,
                  title: _activeTrack?.title,
                  company: _activeTrack?.company,
                )
              : liveStartMessage(
                  language,
                  title: _activeTrack?.title,
                  company: _activeTrack?.company,
                  isFollowUp: _isFollowUpInterview,
                ),
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
        _scheduleMicOpen(delay: _audio.estimatedPlaybackDelay(pcm));
        _audio.play(pcm);
        emit(state.copyWith(isAiSpeaking: true));
      case LiveInterrupted():
        _audio.clearPlayback();
        _scheduleMicOpen();
        emit(state.copyWith(isAiSpeaking: false));
      case LiveTranscriptUpdated(:final transcript):
        emit(state.copyWith(transcript: transcript));
      case LiveTurnComplete():
        // Only a fully finished turn can carry a genuine closing phrase —
        // interim streamed fragments must not trigger an early end.
        _maybeAutoEnd();
      case LiveClosed(:final reason):
        if (state.phase != InterviewCallPhase.inCall) return;
        // A disconnect only counts as a legitimate finish if the model had
        // actually said the closing phrase; otherwise it's a dropped call
        // and must surface as a retryable error, not a silent "completed".
        if (isSessionClosingTranscript(state.transcript, isPrep: state.isPrep)) {
          await end(reason: CallEndReason.closingPhraseDetected);
          return;
        }
        await _fail(GeminiLiveException(reason));
    }
  }

  void _maybeAutoEnd() {
    if (state.phase != InterviewCallPhase.inCall || _endingInFlight) return;
    if (!isSessionClosingTranscript(
      state.transcript,
      isPrep: state.isPrep,
    )) {
      return;
    }
    if (_audio.isPlaying || state.isAiSpeaking) {
      _endAfterSpeech = true;
      return;
    }
    unawaited(end(reason: CallEndReason.closingPhraseDetected));
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
