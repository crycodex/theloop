import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:theloop/core/services/gemini_json_client.dart';
import 'package:theloop/features/roadmap/data/services/roadmap_service.dart';
import 'package:theloop/features/roadmap/domain/entities/roadmap.dart';

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
  test('parsea la trayectoria, limita pasos a 5 y tips a 3', () async {
    final client = MockClient((request) async {
      return _geminiResponse({
        'target': 'Big Tech',
        'finalGoal': 'Conseguir una oferta en una Big Tech.',
        'steps': [
          for (var i = 0; i < 7; i++)
            {
              'title': 'Paso $i',
              'category': 'Behavioral',
              'guide': 'Practica con loops.',
              'tips': ['uno', 'dos', 'tres', 'cuatro'],
            },
        ],
      });
    });
    final service = RoadmapService(GeminiJsonClient(client: client, apiKey: 'test-key'));

    final roadmap = await service.generate(
      goalLabel: 'Faang/BigTech',
      experience: 'some',
      tracks: const [],
    );

    expect(roadmap.target, 'Big Tech');
    expect(roadmap.steps, hasLength(5));
    expect(roadmap.steps.first.tips, hasLength(3));
    expect(roadmap.steps.first.state, RoadmapStepState.locked);
    expect(roadmap.steps.first.id, 'step_1');
    expect(roadmap.steps.last.type, RoadmapStepType.call);
    expect(roadmap.steps.last.lesson, isNull);
  });

  test('parsea lesson/quiz de los pasos que no son la llamada final', () async {
    final client = MockClient((request) async {
      return _geminiResponse({
        'target': 'Big Tech',
        'finalGoal': 'Conseguir una oferta en una Big Tech.',
        'steps': [
          for (var i = 0; i < 5; i++)
            {
              'title': 'Paso $i',
              'category': 'Behavioral',
              'guide': 'Practica con loops.',
              'tips': ['uno', 'dos'],
              'lesson': {
                'sections': [
                  {'title': 'Sección', 'body': 'Cuerpo de la sección.'},
                ],
                'quiz': [
                  {
                    'question': '¿Pregunta?',
                    'options': ['a', 'b', 'c', 'd'],
                    'correctIndex': 1,
                    'explanation': 'Porque sí.',
                  },
                ],
              },
            },
        ],
      });
    });
    final service = RoadmapService(GeminiJsonClient(client: client, apiKey: 'test-key'));

    final roadmap = await service.generate(
      goalLabel: 'Faang/BigTech',
      experience: 'some',
      tracks: const [],
    );

    final firstStep = roadmap.steps.first;
    expect(firstStep.type, RoadmapStepType.lesson);
    expect(firstStep.hasLesson, isTrue);
    expect(firstStep.lesson!.quiz.single.correctIndex, 1);
    expect(roadmap.steps.last.lesson, isNull);

    final restored = Roadmap.fromMap(roadmap.toMap());
    expect(restored.steps.first.lesson!.sections.single.body, 'Cuerpo de la sección.');
    expect(restored.steps.first.id, 'step_1');
    expect(restored.steps.last.type, RoadmapStepType.call);
  });

  test('falla si Gemini no devuelve pasos', () async {
    final client = MockClient((request) async {
      return _geminiResponse({'target': 'X', 'finalGoal': 'Y', 'steps': []});
    });
    final service = RoadmapService(GeminiJsonClient(client: client, apiKey: 'test-key'));

    expect(
      () => service.generate(
        goalLabel: 'Startup',
        experience: 'none',
        tracks: const [],
      ),
      throwsA(isA<GeminiException>()),
    );
  });

  test('Roadmap serializa y deserializa sin el estado de los pasos', () {
    final roadmap = Roadmap(
      target: 'Big Tech',
      finalGoal: 'Oferta firmada',
      generatedAt: DateTime.utc(2026, 7, 13),
      steps: const [
        RoadmapStep(
          title: 'Historia profesional',
          category: 'Foundation',
          guide: 'Define tu narrativa.',
          tips: ['Usa STAR'],
          state: RoadmapStepState.current,
        ),
      ],
    );

    final restored = Roadmap.fromMap(roadmap.toMap());

    expect(restored.target, roadmap.target);
    expect(restored.steps.single.title, 'Historia profesional');
    expect(restored.steps.single.tips, ['Usa STAR']);
    expect(restored.steps.single.state, RoadmapStepState.locked);
  });
}
