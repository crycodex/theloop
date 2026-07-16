import 'package:flutter_test/flutter_test.dart';
import 'package:theloop/features/roadmap/domain/entities/roadmap.dart';

void main() {
  final catalogMap = <String, dynamic>{
    'goalId': 'bigTech',
    'target': {'es': 'Big Tech ES', 'en': 'Big Tech EN'},
    'finalGoal': {'es': 'Meta ES', 'en': 'Goal EN'},
    'steps': [
      {
        'id': 'step1',
        'type': 'lesson',
        'title': {'es': 'Título ES', 'en': 'Title EN'},
        'category': {'es': 'Técnica', 'en': 'Technical'},
        'guide': {'es': 'Guía ES', 'en': 'Guide EN'},
        'tips': {
          'es': ['tip es'],
          'en': ['tip en'],
        },
        'lesson': {
          'sections': [
            {
              'title': {'es': 'Sección ES', 'en': 'Section EN'},
              'body': {'es': 'Cuerpo ES', 'en': 'Body EN'},
            },
          ],
          'quiz': [
            {
              'question': {'es': '¿Pregunta?', 'en': 'Question?'},
              'options': {
                'es': ['a', 'b', 'c'],
                'en': ['a', 'b', 'c'],
              },
              'correctIndex': 1,
              'explanation': {'es': 'Porque sí', 'en': 'Because'},
            },
          ],
        },
      },
      {
        'id': 'step2',
        'type': 'call',
        'title': {'es': 'Llamada', 'en': 'Call'},
        'category': {'es': 'Práctica', 'en': 'Practice'},
        'guide': {'es': 'Guía', 'en': 'Guide'},
        'tips': {
          'es': <String>[],
          'en': <String>[],
        },
      },
    ],
  };

  test('parsea el catálogo en español con lección, quiz y paso de llamada',
      () {
    final roadmap = Roadmap.fromCatalogMap(catalogMap, es: true);

    expect(roadmap.isCatalog, isTrue);
    expect(roadmap.goalId, 'bigTech');
    expect(roadmap.target, 'Big Tech ES');
    expect(roadmap.steps, hasLength(2));

    final lessonStep = roadmap.steps.first;
    expect(lessonStep.id, 'step1');
    expect(lessonStep.type, RoadmapStepType.lesson);
    expect(lessonStep.hasLesson, isTrue);
    expect(lessonStep.tips, ['tip es']);
    expect(lessonStep.lesson!.sections.single.title, 'Sección ES');
    final question = lessonStep.lesson!.quiz.single;
    expect(question.options, hasLength(3));
    expect(question.correctIndex, 1);

    final callStep = roadmap.steps.last;
    expect(callStep.type, RoadmapStepType.call);
    expect(callStep.hasLesson, isFalse);

    expect(roadmap.stepById('step2'), same(callStep));
    expect(roadmap.stepById('missing'), isNull);
  });

  test('parsea en inglés y cae al otro idioma si falta la traducción', () {
    final roadmap = Roadmap.fromCatalogMap(catalogMap, es: false);
    expect(roadmap.target, 'Big Tech EN');
    expect(roadmap.steps.first.lesson!.sections.single.body, 'Body EN');

    final partial = Roadmap.fromCatalogMap(<String, dynamic>{
      'goalId': 'x',
      'target': {'es': 'Solo ES'},
      'finalGoal': {'es': 'Meta'},
      'steps': catalogMap['steps'],
    }, es: false);
    expect(partial.target, 'Solo ES');
  });
}
