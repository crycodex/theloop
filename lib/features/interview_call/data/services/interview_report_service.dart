import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/settings/cubit/settings_state.dart';
import '../../domain/entities/interview_report.dart';
import '../../domain/entities/transcript_turn.dart';
import 'gemini_config.dart';

class InterviewReportException implements Exception {
  const InterviewReportException(this.message);

  final String message;

  @override
  String toString() => message;
}

class InterviewReportService {
  InterviewReportService({http.Client? client})
    : _client = client ?? http.Client();

  static const _models = [
    'gemini-flash-latest',
    'gemini-flash-lite-latest',
    'gemini-2.0-flash',
  ];
  static const _attemptsPerModel = 2;

  final http.Client _client;

  Future<InterviewReport> generateReport({
    required List<TranscriptTurn> transcript,
    AppLanguage language = AppLanguage.spanish,
  }) async {
    if (kGeminiApiKey.isEmpty) {
      throw const InterviewReportException(
        'Falta GEMINI_API_KEY. Copia env.example.json a env.json en la raíz del proyecto.',
      );
    }
    if (transcript.isEmpty) {
      throw const InterviewReportException('La transcripción está vacía.');
    }

    final conversation = transcript
        .map(
          (turn) =>
              '${turn.speaker == TranscriptSpeaker.candidate ? 'Candidato' : 'Reclutador'}: ${turn.text}',
        )
        .join('\n');
    final prompt = [
      language == AppLanguage.spanish
          ? 'Analiza esta entrevista y responde exclusivamente con JSON válido.'
          : 'Analyze this interview and reply only with valid JSON.',
      'Esquema: {"role":string,"summary":string,"strengths":string[],"improvements":string[],"score":number,"recommendation":string,"memorySummary":string}.',
      language == AppLanguage.spanish ? 'Reglas de brevedad (obligatorio):' : 'Brevity rules (required):',
      language == AppLanguage.spanish
          ? '- summary: máximo 2 frases cortas.'
          : '- summary: max 2 short sentences.',
      language == AppLanguage.spanish
          ? '- strengths: máximo 2 ítems, cada uno máximo 10 palabras.'
          : '- strengths: max 2 items, 10 words each.',
      language == AppLanguage.spanish
          ? '- improvements: máximo 2 ítems, cada uno máximo 10 palabras.'
          : '- improvements: max 2 items, 10 words each.',
      language == AppLanguage.spanish
          ? '- recommendation: 1 frase corta.'
          : '- recommendation: 1 short sentence.',
      language == AppLanguage.spanish
          ? '- memorySummary: 1 frase corta para repetir la práctica.'
          : '- memorySummary: 1 short sentence for future practice.',
      language == AppLanguage.spanish
          ? 'El puntaje debe estar entre 1 y 10. Escribe todo en español.'
          : 'Score must be between 1 and 10. Write everything in English.',
      '',
      conversation,
    ].join('\n');

    Object? lastError;
    for (final model in _models) {
      for (var attempt = 0; attempt < _attemptsPerModel; attempt++) {
        try {
          return await _callModel(model: model, prompt: prompt);
        } catch (error) {
          lastError = error;
          final overloaded = error is _HttpException &&
              (error.statusCode == 503 || error.statusCode == 429);
          if (!overloaded) break;
          await Future<void>.delayed(Duration(seconds: 2 * (attempt + 1)));
        }
      }
    }

    throw InterviewReportException(
      lastError?.toString() ?? 'No se pudo generar el reporte.',
    );
  }

  Future<InterviewReport> _callModel({
    required String model,
    required String prompt,
  }) async {
    final response = await _client.post(
      Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/'
        '$model:generateContent?key=$kGeminiApiKey',
      ),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
        'generationConfig': {
          'responseMimeType': 'application/json',
        },
      }),
    );

    if (response.statusCode != 200) {
      throw _HttpException(response.statusCode, response.body);
    }

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final text =
        json['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
    if (text == null || text.trim().isEmpty) {
      throw const InterviewReportException('Gemini no devolvió un reporte.');
    }
    return _parseReport(text);
  }

  InterviewReport _parseReport(String raw) {
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    List<String> strings(String key, {int maxItems = 2}) =>
        (decoded[key] as List<dynamic>? ?? const [])
            .whereType<String>()
            .map((item) => item.trim())
            .where((item) => item.isNotEmpty)
            .take(maxItems)
            .toList(growable: false);

    return InterviewReport(
      role: _shortText(decoded['role'] as String? ?? '', maxLength: 60),
      summary: _shortText(decoded['summary'] as String? ?? '', maxLength: 220),
      strengths: strings('strengths'),
      improvements: strings('improvements'),
      score: (decoded['score'] as num?)?.toDouble() ?? 0,
      recommendation: _shortText(
        decoded['recommendation'] as String? ?? '',
        maxLength: 140,
      ),
      memorySummary: _shortText(
        decoded['memorySummary'] as String? ?? '',
        maxLength: 120,
      ),
    );
  }

  String _shortText(String value, {required int maxLength}) {
    final text = value.trim();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trimRight()}…';
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
