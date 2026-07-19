import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../config/app_env.dart';

class GeminiException implements Exception {
  const GeminiException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Cliente REST para `generateContent` con respuesta JSON estructurada.
///
/// Reintenta entre modelos flash ante 429/503, igual que
/// `InterviewReportService`.
class GeminiJsonClient {
  GeminiJsonClient({http.Client? client, String? apiKey})
      : _client = client ?? http.Client(),
        _apiKeyOverride = apiKey;

  static const _models = [
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
    'gemini-2.0-flash',
  ];
  static const _attemptsPerModel = 2;

  final http.Client _client;
  final String? _apiKeyOverride;

  String get _apiKey => _apiKeyOverride ?? AppEnv.geminiApiKey;

  Future<Map<String, dynamic>> generateJson({
    required String prompt,
    Uint8List? inlineBytes,
    String? inlineMimeType,
  }) async {
    if (_apiKey.isEmpty) {
      throw const GeminiException(
        'Falta GEMINI_API_KEY. Copia env.example.json a env.json en la raíz del proyecto.',
      );
    }

    Object? lastError;
    for (final model in _models) {
      for (var attempt = 0; attempt < _attemptsPerModel; attempt++) {
        try {
          return await _callModel(
            model: model,
            prompt: prompt,
            inlineBytes: inlineBytes,
            inlineMimeType: inlineMimeType,
          );
        } catch (error) {
          lastError = error;
          final overloaded = error is _HttpException &&
              (error.statusCode == 503 || error.statusCode == 429);
          if (!overloaded) break;
          await Future<void>.delayed(Duration(seconds: 2 * (attempt + 1)));
        }
      }
    }

    throw GeminiException(
      lastError?.toString() ?? 'No se pudo generar la respuesta.',
    );
  }

  Future<Map<String, dynamic>> _callModel({
    required String model,
    required String prompt,
    Uint8List? inlineBytes,
    String? inlineMimeType,
  }) async {
    final parts = <Map<String, dynamic>>[
      if (inlineBytes != null)
        {
          'inline_data': {
            'mime_type': inlineMimeType ?? 'application/pdf',
            'data': base64Encode(inlineBytes),
          },
        },
      {'text': prompt},
    ];

    final response = await _client.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:generateContent?key=$_apiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {'parts': parts},
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw _HttpException(response.statusCode, response.body);
    }

    final json =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final text =
        json['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw const GeminiException('Gemini no devolvió una respuesta.');
    }
    final decoded = jsonDecode(text);
    if (decoded is! Map<String, dynamic>) {
      throw const GeminiException('Gemini devolvió un JSON inesperado.');
    }
    return decoded;
  }

  void dispose() => _client.close();
}

class _HttpException implements Exception {
  _HttpException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'HTTP $statusCode: $body';
}
