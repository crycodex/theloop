import '../../../../core/localization/app_strings.dart';
import '../../../../core/settings/cubit/settings_state.dart';
import '../../../profile/domain/entities/profile.dart';
import '../../domain/entities/interview_loop.dart';
import '../../../loops/domain/entities/interview_track.dart';
import 'gemini_config.dart';

String buildInterviewSystemPrompt({
  required Profile profile,
  required AppLanguage language,
  InterviewLoop? previousLoop,
  InterviewTrack? track,
}) {
  final name = profile.name.trim().isEmpty
      ? (language == AppLanguage.spanish ? 'el candidato' : 'the candidate')
      : profile.name.trim();
  final strings = AppStrings(language);
  final goal = profile.target == 'custom'
      ? (profile.customGoal?.trim().isNotEmpty == true
            ? profile.customGoal!.trim()
            : language == AppLanguage.spanish
            ? 'un nuevo puesto'
            : 'a new role')
      : (profile.target.trim().isEmpty
            ? (language == AppLanguage.spanish ? 'un nuevo puesto' : 'a new role')
            : strings.goalLabel(profile.target));
  final experience = profile.experience.trim().isEmpty
      ? 'none'
      : profile.experience.trim();

  final cycleNumber = (track?.cyclesCompleted ?? 0) + 1;
  final isFollowUp = previousLoop?.report != null;

  final memory = !isFollowUp
      ? ''
      : language == AppLanguage.spanish
      ? [
          '',
          '--- CONTEXTO DEL CICLO ANTERIOR (ciclo ${cycleNumber - 1}) ---',
          'Memoria: ${previousLoop!.report!.memorySummary}',
          'Fortalezas: ${previousLoop.report!.strengths.join('; ')}',
          'Áreas a mejorar: ${previousLoop.report!.improvements.join('; ')}',
          'Puntaje previo: ${previousLoop.report!.score.toStringAsFixed(1)}/10',
          'Recomendación previa: ${previousLoop.report!.recommendation}',
          '--- FIN CONTEXTO ---',
          '',
          'Este es el ciclo $cycleNumber. El candidato vuelve a practicar.',
          'Usa el contexto anterior para adaptar la entrevista:',
          '- Haz exactamente 3 preguntas NUEVAS (no repitas las del ciclo anterior).',
          '- Al menos 1 pregunta debe profundizar en las áreas a mejorar.',
          '- Otra puede retar una fortaleza previa o un caso más difícil.',
          '- Comprueba si el candidato mejoró sin citar la memoria literalmente.',
          '- Al cerrar, compara brevemente con su desempeño anterior.',
        ].join('\n')
      : [
          '',
          '--- PREVIOUS CYCLE CONTEXT (cycle ${cycleNumber - 1}) ---',
          'Memory: ${previousLoop!.report!.memorySummary}',
          'Strengths: ${previousLoop.report!.strengths.join('; ')}',
          'Areas to improve: ${previousLoop.report!.improvements.join('; ')}',
          'Previous score: ${previousLoop.report!.score.toStringAsFixed(1)}/10',
          'Previous recommendation: ${previousLoop.report!.recommendation}',
          '--- END CONTEXT ---',
          '',
          'This is cycle $cycleNumber. The candidate is practicing again.',
          'Use the previous context to adapt the interview:',
          '- Ask exactly 3 NEW questions (do not repeat the previous cycle).',
          '- At least 1 question must probe the improvement areas.',
          '- Another may challenge a previous strength or raise difficulty.',
          '- Check if the candidate improved without quoting the memory literally.',
          '- When closing, briefly compare with their previous performance.',
        ].join('\n');

  final trackContext = track == null
      ? ''
      : language == AppLanguage.spanish
      ? [
          '',
          'Puesto objetivo: ${track.title} en ${track.company}.',
          'Descripción: ${track.jobDescription}',
          'Ciclo $cycleNumber del trayecto.',
        ].join('\n')
      : [
          '',
          'Target role: ${track.title} at ${track.company}.',
          'Description: ${track.jobDescription}',
          'Cycle $cycleNumber of this track.',
        ].join('\n');

  final profileLine = language == AppLanguage.spanish
      ? 'El candidato se llama $name, su objetivo es $goal y su nivel de experiencia registrado es $experience.'
      : 'The candidate is $name, their goal is $goal and their registered experience level is $experience.';

  final trackDirective = track == null || track.title.trim().isEmpty
      ? ''
      : language == AppLanguage.spanish
      ? 'IMPORTANTE: El candidato aplica a ${track.title} en ${track.company}. '
          'NO preguntes a qué puesto aplica; ya lo sabes. Haz preguntas relevantes '
          'SOLO para ese puesto y responde directamente a lo que el candidato diga.'
      : 'IMPORTANT: The candidate is applying for ${track.title} at ${track.company}. '
          'Do NOT ask which role they apply for. Ask questions specific to that role '
          'and respond directly to what the candidate says.';

  final basePrompt = isFollowUp
      ? followUpRecruiterPrompt(language)
      : defaultRecruiterPrompt(language);

  return [
    basePrompt,
    profileLine,
    trackContext,
    trackDirective,
    memory,
  ].join('\n');
}

String buildPrepSystemPrompt({
  required Profile profile,
  required AppLanguage language,
  required InterviewTrack track,
}) {
  final name = profile.name.trim().isEmpty
      ? (language == AppLanguage.spanish ? 'el candidato' : 'the candidate')
      : profile.name.trim();
  final trackContext = language == AppLanguage.spanish
      ? 'Puesto: ${track.title} en ${track.company}. Descripción: ${track.jobDescription}'
      : 'Role: ${track.title} at ${track.company}. Description: ${track.jobDescription}';

  final intro = language == AppLanguage.spanish
      ? 'El candidato se llama $name. $trackContext'
      : 'The candidate is $name. $trackContext';

  final trackDirective = language == AppLanguage.spanish
      ? 'IMPORTANTE: Usa el puesto indicado arriba. NO preguntes a qué rol aplica. '
          'Responde a lo que el candidato diga sobre ese puesto concreto.'
      : 'IMPORTANT: Use the role above. Do NOT ask which role they apply for. '
          'Respond to what the candidate says about that specific role.';

  return '${prepRecruiterPrompt(language)}\n$intro\n$trackDirective';
}
