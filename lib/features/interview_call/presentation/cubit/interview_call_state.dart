import '../../domain/entities/interview_report.dart';
import '../../domain/entities/transcript_turn.dart';

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
    required this.elapsedSeconds,
    required this.transcript,
    this.loopId,
    this.report,
    this.errorMessage,
  });

  const InterviewCallState.initial()
    : phase = InterviewCallPhase.idle,
      isMicEnabled = true,
      isPaused = false,
      isAiSpeaking = false,
      elapsedSeconds = 0,
      transcript = const [],
      loopId = null,
      report = null,
      errorMessage = null;

  final InterviewCallPhase phase;
  final bool isMicEnabled;
  final bool isPaused;
  final bool isAiSpeaking;
  final int elapsedSeconds;
  final List<TranscriptTurn> transcript;
  final String? loopId;
  final InterviewReport? report;
  final String? errorMessage;

  String get elapsedLabel {
    final minutes = elapsedSeconds ~/ 60;
    final seconds = elapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  InterviewCallState copyWith({
    InterviewCallPhase? phase,
    bool? isMicEnabled,
    bool? isPaused,
    bool? isAiSpeaking,
    int? elapsedSeconds,
    List<TranscriptTurn>? transcript,
    String? loopId,
    InterviewReport? report,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InterviewCallState(
      phase: phase ?? this.phase,
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isPaused: isPaused ?? this.isPaused,
      isAiSpeaking: isAiSpeaking ?? this.isAiSpeaking,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      transcript: transcript ?? this.transcript,
      loopId: loopId ?? this.loopId,
      report: report ?? this.report,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
