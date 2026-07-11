import '../../domain/entities/interview_report.dart';
import '../../domain/entities/transcript_turn.dart';

const int kLoopDurationSeconds = 300;
const int kMinReportSeconds = 10;

enum InterviewCallPhase {
  idle,
  connecting,
  inCall,
  ending,
  completed,
  error,
}

class InterviewCallState {
  const InterviewCallState({
    required this.phase,
    required this.isMicEnabled,
    required this.isPaused,
    required this.isAiSpeaking,
    required this.remainingSeconds,
    required this.transcript,
    this.loopId,
    this.trackId,
    this.isPrep = false,
    this.report,
    this.errorMessage,
  });

  const InterviewCallState.initial()
    : phase = InterviewCallPhase.idle,
      isMicEnabled = true,
      isPaused = false,
      isAiSpeaking = false,
      remainingSeconds = kLoopDurationSeconds,
      transcript = const [],
      loopId = null,
      trackId = null,
      isPrep = false,
      report = null,
      errorMessage = null;

  final InterviewCallPhase phase;
  final bool isMicEnabled;
  final bool isPaused;
  final bool isAiSpeaking;
  final int remainingSeconds;
  final List<TranscriptTurn> transcript;
  final String? loopId;
  final String? trackId;
  final bool isPrep;
  final InterviewReport? report;
  final String? errorMessage;

  int get elapsedSeconds => kLoopDurationSeconds - remainingSeconds;

  String get timerLabel {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  InterviewCallState copyWith({
    InterviewCallPhase? phase,
    bool? isMicEnabled,
    bool? isPaused,
    bool? isAiSpeaking,
    int? remainingSeconds,
    List<TranscriptTurn>? transcript,
    String? loopId,
    String? trackId,
    bool? isPrep,
    InterviewReport? report,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InterviewCallState(
      phase: phase ?? this.phase,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isPaused: isPaused ?? this.isPaused,
      isAiSpeaking: isAiSpeaking ?? this.isAiSpeaking,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      transcript: transcript ?? this.transcript,
      loopId: loopId ?? this.loopId,
      trackId: trackId ?? this.trackId,
      isPrep: isPrep ?? this.isPrep,
      report: report ?? this.report,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
