import '../../domain/entities/transcript_turn.dart';

/// Detects when the interviewer/coach has wrapped up the session.
bool isSessionClosingTranscript(
  List<TranscriptTurn> transcript, {
  required bool isPrep,
}) {
  TranscriptTurn? lastInterviewer;
  for (var i = transcript.length - 1; i >= 0; i--) {
    if (transcript[i].speaker == TranscriptSpeaker.interviewer) {
      lastInterviewer = transcript[i];
      break;
    }
  }
  if (lastInterviewer == null) return false;
  final lastText = _normalize(lastInterviewer.text);
  if (lastText.length < 12) return false;

  final explicit = isPrep
      ? const [
          'cerramos la preparacion',
          'that concludes this prep',
          'that concludes the prep',
        ]
      : const [
          'cerramos la entrevista',
          'that concludes this interview',
          'that concludes the interview',
        ];

  return explicit.any(lastText.contains);
}

String _normalize(String raw) {
  return raw
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
