import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../domain/entities/transcript_turn.dart';
import 'interview_api_service.dart';

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

class GeminiLiveService {
  final StreamController<LiveEvent> _events =
      StreamController<LiveEvent>.broadcast();
  final List<TranscriptTurn> _transcript = [];
  WebSocket? _socket;
  StreamSubscription<dynamic>? _subscription;
  bool _disconnecting = false;
  Completer<void>? _setupCompleter;
  String? _lastServerPayload;

  Stream<LiveEvent> get events => _events.stream;
  List<TranscriptTurn> get transcript => List.unmodifiable(_transcript);

  Future<void> connect(LiveSessionCredentials credentials) async {
    await disconnect();
    _disconnecting = false;
    _transcript.clear();
    _lastServerPayload = null;
    if (credentials.token.isEmpty) {
      throw const InterviewApiException('No se recibió un token de sesión.');
    }

    final uri =
        'wss://generativelanguage.googleapis.com/ws/'
        'google.ai.generativelanguage.v1alpha.GenerativeService.'
        'BidiGenerateContentConstrained?access_token=${credentials.token}';

    _setupCompleter = Completer<void>();
    try {
      final socket = await WebSocket.connect(uri).timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw const InterviewApiException(
            'No se pudo conectar con Gemini Live. Revisa tu red e inténtalo de nuevo.',
          );
        },
      );
      _socket = socket;

      _subscription = socket.listen(
        _onRawMessage,
        onError: (Object error, StackTrace stackTrace) {
          _completeSetupWithError(_liveErrorMessage(error));
        },
        onDone: () {
          if (_disconnecting) return;
          final reason = _humanizeCloseReason(socket.closeReason);
          final completer = _setupCompleter;
          if (completer != null && !completer.isCompleted) {
            _completeSetupWithError(reason);
            return;
          }
          _events.add(LiveClosed(reason));
        },
      );

      _send({
        'setup': {
          'model': 'models/${credentials.model}',
          'generationConfig': {
            'responseModalities': ['AUDIO'],
            'mediaResolution': 'MEDIA_RESOLUTION_MEDIUM',
            'translationConfig': {
              'targetLanguageCode': 'es',
            },
          },
          'contextWindowCompression': {
            'triggerTokens': '0',
            'slidingWindow': {'targetTokens': '0'},
          },
        },
      });

      await _setupCompleter!.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw InterviewApiException(
            _humanizeCloseReason(_lastServerPayload) ==
                    'La conexión con Gemini se cerró antes de iniciar la llamada.'
                ? 'Gemini Live no confirmó la sesión a tiempo.'
                : _humanizeCloseReason(_lastServerPayload),
          );
        },
      );
    } catch (error) {
      await disconnect();
      if (error is InterviewApiException) rethrow;
      throw InterviewApiException(_liveErrorMessage(error));
    } finally {
      _setupCompleter = null;
    }
  }

  String _humanizeCloseReason(String? raw) {
    final reason = raw?.trim() ?? '';
    if (reason.isEmpty) {
      return 'La conexión con Gemini se cerró antes de iniciar la llamada.';
    }
    final lower = reason.toLowerCase();
    if (lower.contains('prepayment credits') ||
        lower.contains('credits are depleted') ||
        lower.contains('billing')) {
      return 'Los créditos de Gemini se agotaron. Añade saldo en Google AI Studio.';
    }
    if (lower.contains('quota') || lower.contains('rate limit')) {
      return 'Gemini rechazó la llamada por límite de uso. Intenta más tarde.';
    }
    return reason.length > 180 ? '${reason.substring(0, 180)}…' : reason;
  }

  void _completeSetupWithError(String message) {
    final completer = _setupCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(InterviewApiException(message));
      return;
    }
    if (!_disconnecting) {
      _events.add(LiveClosed(message));
    }
  }

  void _onRawMessage(dynamic raw) {
    try {
      handleServerMessage(raw);
    } catch (error) {
      _completeSetupWithError('Respuesta Live inválida: $error');
    }
  }

  String _liveErrorMessage(Object error) {
    final message = error.toString();
    if (message.contains('401') || message.contains('403')) {
      return 'El token de sesión de Gemini no es válido.';
    }
    if (message.contains('404')) {
      return 'Gemini Live no está disponible para este modelo.';
    }
    return 'No se pudo iniciar la llamada con Gemini Live.';
  }

  void startConversation({required String systemPrompt}) {
    _send({
      'clientContent': {
        'turns': [
          {
            'role': 'user',
            'parts': [
              {
                'text':
                    '$systemPrompt\n\nHola, estoy listo para comenzar la entrevista.',
              },
            ],
          },
        ],
        'turnComplete': true,
      },
    });
  }

  void sendAudio(Uint8List pcm) {
    if (pcm.isEmpty || _socket == null) return;
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
    _lastServerPayload = text;
    final message = jsonDecode(text) as Map<String, dynamic>;

    if (message.containsKey('goAway')) {
      final goAway = message['goAway'];
      final detail = goAway is Map ? goAway['reason'] as String? : null;
      _completeSetupWithError(
        _humanizeCloseReason(detail) ==
                'La conexión con Gemini se cerró antes de iniciar la llamada.'
            ? 'Gemini Live finalizó la sesión.'
            : _humanizeCloseReason(detail),
      );
      return;
    }

    if (message.containsKey('setupComplete')) {
      if (_setupCompleter != null && !_setupCompleter!.isCompleted) {
        _setupCompleter!.complete();
      }
      _events.add(const LiveSetupComplete());
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

    final modelTurn = server['modelTurn'] as Map<String, dynamic>?;
    final parts = modelTurn?['parts'] as List<dynamic>? ?? const [];
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

  String transcriptAsText() => _transcript
      .map(
        (turn) =>
            '${turn.speaker == TranscriptSpeaker.candidate ? 'Candidato' : 'Reclutador'}: ${turn.text}',
      )
      .join('\n');

  void _send(Map<String, dynamic> message) {
    _socket?.add(jsonEncode(message));
  }

  Future<void> disconnect() async {
    _disconnecting = true;
    final completer = _setupCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.completeError(
        const InterviewApiException('Conexión cancelada.'),
      );
    }
    await _subscription?.cancel();
    _subscription = null;
    await _socket?.close();
    _socket = null;
    _setupCompleter = null;
    _disconnecting = false;
  }

  Future<void> dispose() async {
    await disconnect();
    await _events.close();
  }
}
