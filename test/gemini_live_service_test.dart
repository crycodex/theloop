import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:theloop/features/interview_call/data/services/gemini_live_service.dart';
import 'package:theloop/features/interview_call/domain/entities/transcript_turn.dart';

void main() {
  test('parsea eventos Live y concatena fragmentos del mismo hablante', () async {
    final service = GeminiLiveService();
    final eventsFuture = service.events.take(6).toList();

    service.handleServerMessage(
      jsonEncode({
        'setupComplete': {},
        'serverContent': {
          'inputTranscription': {'text': 'Hola '},
          'modelTurn': {
            'parts': [
              {
                'inlineData': {'data': base64Encode([1, 2, 3])},
              },
            ],
          },
          'turnComplete': true,
        },
      }),
    );
    service.handleServerMessage(
      jsonEncode({
        'serverContent': {
          'inputTranscription': {'text': 'mundo'},
          'interrupted': true,
        },
      }),
    );

    final events = await eventsFuture;
    expect(events.whereType<LiveSetupComplete>(), hasLength(1));
    expect(events.whereType<LiveAudioChunk>().single.pcm, [1, 2, 3]);
    expect(events.whereType<LiveTurnComplete>(), hasLength(1));
    expect(events.whereType<LiveInterrupted>(), hasLength(1));
    expect(service.transcript, hasLength(1));
    expect(service.transcript.single.speaker, TranscriptSpeaker.candidate);
    expect(service.transcript.single.text, 'Hola mundo');
    expect(service.transcriptAsText(), 'Candidato: Hola mundo');

    await service.dispose();
  });
}
