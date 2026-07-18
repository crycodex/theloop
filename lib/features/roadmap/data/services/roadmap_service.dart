import '../../../../core/services/gemini_json_client.dart';
import '../../../../core/settings/cubit/settings_state.dart';
import '../../../loops/domain/entities/interview_track.dart';
import '../../domain/entities/roadmap.dart';

class RoadmapService {
  const RoadmapService(this._gemini);

  final GeminiJsonClient _gemini;

  Future<Roadmap> generate({
    required String goalLabel,
    required String experience,
    required List<InterviewTrack> tracks,
    AppLanguage language = AppLanguage.spanish,
  }) async {
    final es = language == AppLanguage.spanish;
    final tracksSummary = tracks.isEmpty
        ? (es ? 'sin loops aún' : 'no loops yet')
        : tracks
            .map(
              (track) => es
                  ? '${track.title} — ciclos: ${track.cyclesCompleted}, último puntaje: ${track.latestScore.toStringAsFixed(1)}'
                  : '${track.title} — cycles: ${track.cyclesCompleted}, latest score: ${track.latestScore.toStringAsFixed(1)}',
            )
            .join('; ');

    final prompt = [
      es
          ? 'Eres un coach de carrera. Crea una trayectoria de preparación de '
              'entrevistas para el objetivo "$goalLabel" '
              '(nivel de experiencia: $experience).'
          : 'You are a career coach. Create an interview preparation roadmap '
              'for the goal "$goalLabel" (experience level: $experience).',
      es
          ? 'Progreso actual del usuario: $tracksSummary.'
          : "User's current progress: $tracksSummary.",
      es
          ? 'Responde exclusivamente con JSON válido.'
          : 'Reply only with valid JSON.',
      'Esquema: {"target":string,"finalGoal":string,'
          '"steps":[{"title":string,"category":string,"guide":string,"tips":string[],'
          '"lesson":{"sections":[{"title":string,"body":string}],'
          '"quiz":[{"question":string,"options":string[4],"correctIndex":int,"explanation":string}]}}]}.',
      es ? 'Reglas (obligatorio):' : 'Rules (required):',
      es
          ? '- target: nombre corto del objetivo (máximo 5 palabras).'
          : '- target: short goal name (max 5 words).',
      es
          ? '- finalGoal: 1 frase con la meta final.'
          : '- finalGoal: 1 sentence with the final goal.',
      es
          ? '- steps: exactamente 5 pasos ordenados de básico a avanzado, adaptados al progreso actual.'
          : '- steps: exactly 5 steps ordered from basic to advanced, adapted to current progress.',
      es
          ? '- title: máximo 6 palabras. category: 1 palabra (p.ej. Behavioral, Técnica).'
          : '- title: max 6 words. category: 1 word (e.g. Behavioral, Technical).',
      es
          ? '- guide: máximo 2 frases explicando cómo practicarlo.'
          : '- guide: max 2 sentences explaining how to practice it.',
      es
          ? '- tips: 2 o 3 consejos prácticos de máximo 10 palabras cada uno.'
          : '- tips: 2 or 3 practical tips of max 10 words each.',
      es
          ? '- lesson: incluye este objeto SOLO en los primeros 4 pasos (el paso 5 es la práctica final por llamada y no lleva lesson).'
          : '- lesson: include this object ONLY on the first 4 steps (step 5 is the final call practice and has no lesson).',
      es
          ? '- lesson.sections: exactamente 3 tarjetas de teoría, title máximo 4 palabras, body máximo 40 palabras.'
          : '- lesson.sections: exactly 3 theory cards, title max 4 words, body max 40 words.',
      es
          ? '- lesson.quiz: exactamente 3 preguntas de opción múltiple con 4 opciones cada una, correctIndex entre 0 y 3, explanation máximo 20 palabras.'
          : '- lesson.quiz: exactly 3 multiple-choice questions with 4 options each, correctIndex between 0 and 3, explanation max 20 words.',
      es ? 'Escribe todo en español.' : 'Write everything in English.',
    ].join('\n');

    final decoded = await _gemini.generateJson(prompt: prompt);

    final rawSteps = (decoded['steps'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .take(5)
        .toList(growable: false);

    final steps = <RoadmapStep>[
      for (var i = 0; i < rawSteps.length; i++)
        _parseStep(rawSteps[i], index: i, isLastStep: i == rawSteps.length - 1),
    ];

    if (steps.isEmpty) {
      throw const GeminiException('Gemini no devolvió pasos de trayectoria.');
    }

    return Roadmap(
      target: _shortText(decoded['target'] as String? ?? '', maxLength: 60),
      finalGoal: _shortText(
        decoded['finalGoal'] as String? ?? '',
        maxLength: 160,
      ),
      generatedAt: DateTime.now(),
      steps: steps,
    );
  }

  RoadmapStep _parseStep(
    Map<String, dynamic> item, {
    required int index,
    required bool isLastStep,
  }) {
    final lessonMap = item['lesson'] as Map<String, dynamic>?;
    return RoadmapStep(
      id: 'step_${index + 1}',
      title: _shortText(item['title'] as String? ?? '', maxLength: 60),
      category: _shortText(
        item['category'] as String? ?? '',
        maxLength: 24,
      ),
      guide: _shortText(item['guide'] as String? ?? '', maxLength: 220),
      tips: (item['tips'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .map((tip) => _shortText(tip, maxLength: 90))
          .where((tip) => tip.isNotEmpty)
          .take(3)
          .toList(growable: false),
      type: isLastStep ? RoadmapStepType.call : RoadmapStepType.lesson,
      lesson: isLastStep || lessonMap == null
          ? null
          : _parseLesson(lessonMap),
    );
  }

  RoadmapLesson _parseLesson(Map<String, dynamic> map) {
    final sections = (map['sections'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (section) => LessonSection(
            title: _shortText(section['title'] as String? ?? '', maxLength: 40),
            body: _shortText(section['body'] as String? ?? '', maxLength: 260),
          ),
        )
        .take(3)
        .toList(growable: false);

    final quiz = (map['quiz'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (question) => QuizQuestion(
            question: _shortText(
              question['question'] as String? ?? '',
              maxLength: 160,
            ),
            options: (question['options'] as List<dynamic>? ?? const [])
                .whereType<String>()
                .map((option) => _shortText(option, maxLength: 90))
                .take(4)
                .toList(growable: false),
            correctIndex: (question['correctIndex'] as int? ?? 0).clamp(0, 3),
            explanation: _shortText(
              question['explanation'] as String? ?? '',
              maxLength: 140,
            ),
          ),
        )
        .where((question) => question.options.length == 4)
        .take(3)
        .toList(growable: false);

    return RoadmapLesson(sections: sections, quiz: quiz);
  }

  String _shortText(String value, {required int maxLength}) {
    final text = value.trim();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trimRight()}…';
  }
}
