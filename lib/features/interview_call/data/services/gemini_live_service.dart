import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/transcript_turn.dart';
import 'gemini_config.dart';

sealed class LiveEvent {
  const LiveEvent();
}

class LiveSetupComplete extends LiveEvent {
  const LiveSetupComplete();
}

class LiveAudioChunk extends LiveEvent {
  const LiveAudioChunk(this.pcm);
  final Uint8List pcm;
}

class LiveInterrupted extends LiveEvent {
  const LiveInterrupted();
}

class LiveTurnComplete extends LiveEvent {
  const LiveTurnComplete();
}

class LiveTranscriptUpdated extends LiveEvent {
  const LiveTranscriptUpdated(this.transcript);
  final List<TranscriptTurn> transcript;
}

class LiveClosed extends LiveEvent {
  const LiveClosed(this.reason);
  final String reason;
}

class GeminiLiveException implements Exception {
  const GeminiLiveException(this.message);

  final String message;

  @override
  String toString() => message;
}

class GeminiLiveService {
  final StreamController<LiveEvent> _events =
      StreamController<LiveEvent>.broadcast();
  final List<TranscriptTurn> _transcript = [];
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  bool _disconnecting = false;

  Stream<LiveEvent> get events => _events.stream;
  List<TranscriptTurn> get transcript => List.unmodifiable(_transcript);

  Future<void> connect({String? systemPrompt}) async {
    if (kGeminiApiKey.isEmpty) {
      throw const GeminiLiveException(
        'Falta GEMINI_API_KEY. Corre con --dart-define=GEMINI_API_KEY=...',
      );
    }

    await disconnect();
    _disconnecting = false;
    _transcript.clear();

    final uri = Uri.parse('$kGeminiLiveWsUrl?key=$kGeminiApiKey');
    final channel = WebSocketChannel.connect(uri);
    _channel = channel;
    await channel.ready;

    _subscription = channel.stream.listen(
      _onData,
      onError: (Object error) {
        if (_disconnecting) return;
        _events.add(LiveClosed(error.toString()));
      },
      onDone: () {
        if (_disconnecting) return;
        _events.add(const LiveClosed('Conexión cerrada'));
      },
    );

    _send({
      'setup': {
        'model': kGeminiLiveModel,
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'speechConfig': {
            'voiceConfig': {
              'prebuiltVoiceConfig': {'voiceName': 'Sadaltager'},
            },
          },
        },
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt?.trim().isNotEmpty == true ? systemPrompt!.trim() : kDefaultRecruiterPrompt},
          ],
        },
        'inputAudioTranscription': {},
        'outputAudioTranscription': {},
        'realtimeInputConfig': {
          'automaticActivityDetection': {
            'startOfSpeechSensitivity': 'START_SENSITIVITY_LOW',
            'endOfSpeechSensitivity': 'END_SENSITIVITY_LOW',
            'prefixPaddingMs': 100,
            'silenceDurationMs': 800,
          },
        },
      },
    });
  }

  void startConversation() {
    _send({
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {'text': 'Hola, estoy listo para comenzar la entrevista.'},
            ],
          },
        ],
        'turnComplete': true,
      },
    });
  }

  void sendAudio(Uint8List pcm) {
    if (pcm.isEmpty || _channel == null) return;
    _send({
      'realtimeInput': {
        'audio': {
          'data': base64Encode(pcm),
          'mimeType': 'audio/pcm;rate=16000',
        },
      },
    });
  }

  void handleServerMessage(dynamic raw) {
    final text = _decodeRawMessage(raw);
    final message = jsonDecode(text) as Map<String, dynamic>;

    if (message.containsKey('setupComplete')) {
      _events.add(const LiveSetupComplete());
      return;
    }

    final server = message['serverContent'] as Map<String, dynamic>?;
    if (server == null) return;

    if (server['interrupted'] == true) {
      _events.add(const LiveInterrupted());
    }

    _appendTranscription(
      server['inputTranscription'],
      TranscriptSpeaker.candidate,
    );
    _appendTranscription(
      server['outputTranscription'],
      TranscriptSpeaker.interviewer,
    );

    final parts = server['modelTurn']?['parts'] as List<dynamic>? ?? const [];
    for (final part in parts.whereType<Map>()) {
      final inline = part['inlineData'] as Map?;
      final data = inline?['data'] as String?;
      if (data != null && data.isNotEmpty) {
        _events.add(LiveAudioChunk(base64Decode(data)));
      }
    }

    if (server['turnComplete'] == true) {
      _events.add(const LiveTurnComplete());
    }
  }

  String transcriptAsText() => _transcript
      .map(
        (turn) =>
            '${turn.speaker == TranscriptSpeaker.candidate ? 'Candidato' : 'Reclutador'}: ${turn.text.trim()}',
      )
      .join('\n');

  Future<void> disconnect() async {
    _disconnecting = true;
    await _subscription?.cancel();
    _subscription = null;
    await _channel?.sink.close();
    _channel = null;
    _disconnecting = false;
  }

  Future<void> dispose() async {
    await disconnect();
    await _events.close();
  }

  void _onData(dynamic raw) {
    try {
      handleServerMessage(raw);
    } catch (error) {
      if (!_disconnecting) {
        _events.add(LiveClosed('Respuesta Live inválida: $error'));
      }
    }
  }

  String _decodeRawMessage(dynamic raw) {
    if (raw is String) return raw;
    if (raw is Uint8List) return utf8.decode(raw);
    if (raw is List<int>) return utf8.decode(raw);
    throw const FormatException('Formato de mensaje Live no soportado.');
  }

  void _appendTranscription(dynamic raw, TranscriptSpeaker speaker) {
    if (raw is! Map) return;
    final fragment = raw['text'] as String? ?? '';
    if (fragment.isEmpty) return;
    if (_transcript.isNotEmpty && _transcript.last.speaker == speaker) {
      final previous = _transcript.removeLast();
      _transcript.add(
        TranscriptTurn(speaker: speaker, text: previous.text + fragment),
      );
    } else {
      _transcript.add(TranscriptTurn(speaker: speaker, text: fragment));
    }
    _events.add(LiveTranscriptUpdated(List.unmodifiable(_transcript)));
  }

  void _send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }
}
