class InterviewCallState {
  const InterviewCallState({
    required this.isMicEnabled,
    required this.isPaused,
    required this.elapsedLabel,
    required this.prompt,
  });

  const InterviewCallState.initial()
      : isMicEnabled = true,
        isPaused = false,
        elapsedLabel = '04:32',
        prompt =
            'Cuéntame de una vez en la que tuviste que liderar una decisión técnica con información incompleta.';

  final bool isMicEnabled;
  final bool isPaused;
  final String elapsedLabel;
  final String prompt;

  InterviewCallState copyWith({
    bool? isMicEnabled,
    bool? isPaused,
    String? elapsedLabel,
    String? prompt,
  }) {
    return InterviewCallState(
      isMicEnabled: isMicEnabled ?? this.isMicEnabled,
      isPaused: isPaused ?? this.isPaused,
      elapsedLabel: elapsedLabel ?? this.elapsedLabel,
      prompt: prompt ?? this.prompt,
    );
  }
}
