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
          '"steps":[{"title":string,"category":string,"guide":string,"tips":string[]}]}.',
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
      es ? 'Escribe todo en español.' : 'Write everything in English.',
    ].join('\n');

    final decoded = await _gemini.generateJson(prompt: prompt);

    final steps = (decoded['steps'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => RoadmapStep(
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
          ),
        )
        .take(5)
        .toList(growable: false);

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

  String _shortText(String value, {required int maxLength}) {
    final text = value.trim();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trimRight()}…';
  }
}
