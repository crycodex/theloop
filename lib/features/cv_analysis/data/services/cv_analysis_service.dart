import 'dart:typed_data';

import '../../../../core/services/gemini_json_client.dart';
import '../../../../core/settings/cubit/settings_state.dart';
import '../../../loops/domain/entities/interview_track.dart';
import '../../domain/entities/cv_analysis.dart';

class CvAnalysisService {
  const CvAnalysisService(this._gemini);

  final GeminiJsonClient _gemini;

  Future<CvAnalysis> analyze({
    required Uint8List pdfBytes,
    required String goalLabel,
    required String experience,
    InterviewTrack? track,
    AppLanguage language = AppLanguage.spanish,
  }) async {
    final es = language == AppLanguage.spanish;
    final prompt = [
      es
          ? 'Eres un experto en revisión de CVs. Analiza el CV adjunto (PDF) '
              'para el objetivo profesional "$goalLabel" '
              '(nivel de experiencia: $experience). '
              'Responde exclusivamente con JSON válido.'
          : 'You are an expert resume reviewer. Analyze the attached resume (PDF) '
              'for the career goal "$goalLabel" '
              '(experience level: $experience). '
              'Reply only with valid JSON.',
      'Esquema: {"score":number,"qualification":string,"summary":string,'
          '"criteria":[{"name":string,"score":number,"feedback":string}]'
          '${track != null ? ',"matchScore":number,"matchSummary":string' : ''}}.',
      es ? 'Reglas (obligatorio):' : 'Rules (required):',
      es
          ? '- score: número entre 0 y 100 evaluando el CV frente al objetivo.'
          : '- score: number between 0 and 100 rating the resume against the goal.',
      es
          ? '- qualification: calificación de 1 a 3 palabras (p.ej. "Sólido").'
          : '- qualification: 1 to 3 word rating (e.g. "Solid").',
      es
          ? '- summary: máximo 2 frases cortas.'
          : '- summary: max 2 short sentences.',
      es
          ? '- criteria: exactamente 4 ítems, en este orden: '
              '"Experiencia relevante", "Logros medibles", "Claridad narrativa", "Formato ATS". '
              'Cada uno con score entre 0 y 1 y feedback de máximo 12 palabras.'
          : '- criteria: exactly 4 items, in this order: '
              '"Relevant experience", "Measurable achievements", "Narrative clarity", "ATS format". '
              'Each with a score between 0 and 1 and feedback of max 12 words.',
      if (track != null) ...[
        es
            ? '- matchScore: número entre 0 y 100 midiendo el match del CV con esta oferta.'
            : '- matchScore: number between 0 and 100 rating resume fit for this job.',
        es
            ? '- matchSummary: máximo 2 frases comparando el CV con la oferta.'
            : '- matchSummary: max 2 sentences comparing the resume to the job.',
        es ? 'Oferta objetivo:' : 'Target job:',
        '${track.title}${track.company.isNotEmpty ? ' · ${track.company}' : ''}',
        track.jobDescription,
      ],
      es ? 'Escribe todo en español.' : 'Write everything in English.',
    ].join('\n');

    final decoded = await _gemini.generateJson(
      prompt: prompt,
      inlineBytes: pdfBytes,
      inlineMimeType: 'application/pdf',
    );

    final criteria = (decoded['criteria'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => CvCriterion(
            name: _shortText(item['name'] as String? ?? '', maxLength: 40),
            score: ((item['score'] as num?)?.toDouble() ?? 0)
                .clamp(0, 1)
                .toDouble(),
            feedback: _shortText(
              item['feedback'] as String? ?? '',
              maxLength: 120,
            ),
          ),
        )
        .take(4)
        .toList(growable: false);

    return CvAnalysis(
      score: (((decoded['score'] as num?)?.toDouble() ?? 0).clamp(0, 100))
          .round(),
      qualification: _shortText(
        decoded['qualification'] as String? ?? '',
        maxLength: 40,
      ),
      summary: _shortText(decoded['summary'] as String? ?? '', maxLength: 220),
      analyzedAt: DateTime.now(),
      criteria: criteria,
      matchScore: track == null
          ? null
          : (((decoded['matchScore'] as num?)?.toDouble() ?? 0).clamp(0, 100))
              .round(),
      matchSummary: track == null
          ? null
          : _shortText(
              decoded['matchSummary'] as String? ?? '',
              maxLength: 220,
            ),
      matchTrackTitle: track?.title,
    );
  }

  String _shortText(String value, {required int maxLength}) {
    final text = value.trim();
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength).trimRight()}…';
  }
}
