import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/interview_loop.dart';
import 'gemini_config.dart';

String buildInterviewSystemPrompt({
  required Profile profile,
  InterviewLoop? previousLoop,
}) {
  final name = profile.name.trim().isEmpty ? 'el candidato' : profile.name.trim();
  final goal = profile.target == 'custom'
      ? (profile.customGoal?.trim().isNotEmpty == true
            ? profile.customGoal!.trim()
            : 'un nuevo puesto')
      : (profile.target.trim().isEmpty ? 'un nuevo puesto' : profile.target.trim());
  final experience =
      profile.experience.trim().isEmpty ? 'none' : profile.experience.trim();

  final memory = previousLoop?.report == null
      ? ''
      : [
          '',
          'Esta práctica repite una entrevista anterior.',
          'Memoria previa: ${previousLoop!.report!.memorySummary}',
          'Fortalezas previas: ${previousLoop.report!.strengths.join('; ')}',
          'Áreas a mejorar: ${previousLoop.report!.improvements.join('; ')}',
          'Comprueba si el candidato mejoró, sin revelar esta memoria literalmente.',
        ].join('\n');

  return [
    kDefaultRecruiterPrompt,
    'El candidato se llama $name, su objetivo es $goal y su nivel de experiencia registrado es $experience.',
    'Saluda brevemente usando su nombre y confirma el rol objetivo.',
    memory,
  ].join('\n');
}
