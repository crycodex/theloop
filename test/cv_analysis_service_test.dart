import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theloop/core/services/gemini_json_client.dart';
import 'package:theloop/features/cv_analysis/data/services/cv_analysis_service.dart';
import 'package:theloop/features/loops/domain/entities/interview_track.dart';

http.Response _geminiResponse(Map<String, dynamic> payload) {
  return http.Response(
    jsonEncode({
      'candidates': [
        {
          'content': {
            'parts': [
              {'text': jsonEncode(payload)},
            ],
          },
        },
      ],
    }),
    200,
    headers: {'content-type': 'application/json'},
  );
}

void main() {
  final pdfBytes = Uint8List.fromList([1, 2, 3]);

  test('parsea el análisis de CV y limita criterios a 4', () async {
    final client = MockClient((request) async {
      return _geminiResponse({
        'score': 87.6,
        'qualification': 'Sólido',
        'summary': 'Buen CV.',
        'criteria': [
          for (var i = 0; i < 6; i++)
            {'name': 'Criterio $i', 'score': 0.8, 'feedback': 'ok'},
        ],
      });
    });
    final service = CvAnalysisService(GeminiJsonClient(client: client, apiKey: 'test-key'));

    final analysis = await service.analyze(
      pdfBytes: pdfBytes,
      goalLabel: 'Faang/BigTech',
      experience: 'some',
    );

    expect(analysis.score, 88);
    expect(analysis.qualification, 'Sólido');
    expect(analysis.criteria, hasLength(4));
    expect(analysis.matchScore, isNull);
    expect(analysis.matchSummary, isNull);
  });

  test('incluye match cuando hay track y ajusta scores fuera de rango',
      () async {
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      final parts = (body['contents'] as List).first['parts'] as List;
      expect(parts, hasLength(2));
      expect((parts.first as Map).containsKey('inline_data'), isTrue);
      return _geminiResponse({
        'score': 140,
        'qualification': 'Excelente',
        'summary': 'Muy bueno.',
        'criteria': [
          {'name': 'Experiencia relevante', 'score': 1.4, 'feedback': 'top'},
        ],
        'matchScore': 76,
        'matchSummary': 'Encaja bien.',
      });
    });
    final service = CvAnalysisService(GeminiJsonClient(client: client, apiKey: 'test-key'));
    final track = InterviewTrack(
      id: 't1',
      title: 'iOS Engineer',
      company: 'Meta',
      jobDescription: 'Swift y SwiftUI',
      prepCompleted: true,
      cyclesCompleted: 2,
      createdAt: DateTime(2026),
    );

    final analysis = await service.analyze(
      pdfBytes: pdfBytes,
      goalLabel: 'Faang/BigTech',
      experience: 'some',
      track: track,
    );

    expect(analysis.score, 100);
    expect(analysis.criteria.single.score, 1.0);
    expect(analysis.matchScore, 76);
    expect(analysis.matchSummary, 'Encaja bien.');
    expect(analysis.matchTrackTitle, 'iOS Engineer');
  });
}
