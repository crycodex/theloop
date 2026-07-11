enum TranscriptSpeaker { candidate, interviewer }

class TranscriptTurn {
  const TranscriptTurn({required this.speaker, required this.text});

  final TranscriptSpeaker speaker;
  final String text;

  String get role => switch (speaker) {
    TranscriptSpeaker.candidate => 'candidate',
    TranscriptSpeaker.interviewer => 'interviewer',
  };

  Map<String, dynamic> toJson() => {'role': role, 'text': text};

  factory TranscriptTurn.fromJson(Map<String, dynamic> json) {
    return TranscriptTurn(
      speaker: json['role'] == 'candidate'
          ? TranscriptSpeaker.candidate
          : TranscriptSpeaker.interviewer,
      text: json['text'] as String? ?? '',
    );
  }
}
