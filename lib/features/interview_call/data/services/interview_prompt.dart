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
  final goal = profile.target == 'custom'
      ? (profile.customGoal?.trim().isNotEmpty == true
            ? profile.customGoal!.trim()
            : language == AppLanguage.spanish
            ? 'un nuevo puesto'
            : 'a new role')
      : (profile.target.trim().isEmpty
            ? (language == AppLanguage.spanish ? 'un nuevo puesto' : 'a new role')
            : profile.target.trim());
  final experience = profile.experience.trim().isEmpty
      ? 'none'
      : profile.experience.trim();

  final memory = previousLoop?.report == null
      ? ''
      : language == AppLanguage.spanish
      ? [
          '',
          'Esta práctica repite una entrevista anterior.',
          'Memoria previa: ${previousLoop!.report!.memorySummary}',
          'Fortalezas previas: ${previousLoop.report!.strengths.join('; ')}',
          'Áreas a mejorar: ${previousLoop.report!.improvements.join('; ')}',
          'Comprueba si el candidato mejoró, sin revelar esta memoria literalmente.',
        ].join('\n')
      : [
          '',
          'This practice repeats a previous interview.',
          'Previous memory: ${previousLoop!.report!.memorySummary}',
          'Previous strengths: ${previousLoop.report!.strengths.join('; ')}',
          'Areas to improve: ${previousLoop.report!.improvements.join('; ')}',
          'Check if the candidate improved without revealing this memory literally.',
        ].join('\n');

  final trackContext = track == null
      ? ''
      : language == AppLanguage.spanish
      ? [
          '',
          'Puesto objetivo: ${track.title} en ${track.company}.',
          'Descripción: ${track.jobDescription}',
          'Ciclo ${track.cyclesCompleted + 1} del trayecto.',
        ].join('\n')
      : [
          '',
          'Target role: ${track.title} at ${track.company}.',
          'Description: ${track.jobDescription}',
          'Cycle ${track.cyclesCompleted + 1} of this track.',
        ].join('\n');

  final profileLine = language == AppLanguage.spanish
      ? 'El candidato se llama $name, su objetivo es $goal y su nivel de experiencia registrado es $experience.'
      : 'The candidate is $name, their goal is $goal and their registered experience level is $experience.';

  return [
    defaultRecruiterPrompt(language),
    profileLine,
    trackContext,
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

  return '${prepRecruiterPrompt(language)}\n$intro';
}
