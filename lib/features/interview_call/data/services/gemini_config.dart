import '../../../../core/config/app_env.dart';
import '../../../../core/settings/cubit/settings_state.dart';

String get kGeminiApiKey => AppEnv.geminiApiKey;

const String kGeminiLiveModel = 'models/gemini-3.1-flash-live-preview';

const String kGeminiLiveWsUrl =
    'wss://generativelanguage.googleapis.com/ws/'
    'google.ai.generativelanguage.v1beta.GenerativeService.'
    'BidiGenerateContent';

enum RecruiterVoice {
  sadaltager('Sadaltager'),
  puck('Puck'),
  kore('Kore'),
  fenrir('Fenrir');

  const RecruiterVoice(this.apiName);

  final String apiName;

  String label(AppLanguage language) => '${styleName(language)} ($apiName)';

  String styleName(AppLanguage language) => switch (this) {
    RecruiterVoice.sadaltager =>
      language == AppLanguage.spanish ? 'Profesional' : 'Professional',
    RecruiterVoice.puck => language == AppLanguage.spanish ? 'Cálido' : 'Warm',
    RecruiterVoice.kore => language == AppLanguage.spanish ? 'Claro' : 'Clear',
    RecruiterVoice.fenrir =>
      language == AppLanguage.spanish ? 'Directo' : 'Direct',
  };

  String description(AppLanguage language) => switch (this) {
    RecruiterVoice.sadaltager => language == AppLanguage.spanish
        ? 'Tono formal y neutro'
        : 'Formal, neutral tone',
    RecruiterVoice.puck => language == AppLanguage.spanish
        ? 'Cercano y relajado'
        : 'Friendly and relaxed',
    RecruiterVoice.kore => language == AppLanguage.spanish
        ? 'Articulado y pausado'
        : 'Articulate and measured',
    RecruiterVoice.fenrir => language == AppLanguage.spanish
        ? 'Enérgico y al grano'
        : 'Energetic, to the point',
  };
}

String defaultRecruiterPrompt(AppLanguage language) =>
    language == AppLanguage.spanish ? _defaultRecruiterPromptEs : _defaultRecruiterPromptEn;

String followUpRecruiterPrompt(AppLanguage language) =>
    language == AppLanguage.spanish
        ? _followUpRecruiterPromptEs
        : _followUpRecruiterPromptEn;

const String _defaultRecruiterPromptEs =
    'Eres un reclutador profesional realizando una entrevista de trabajo '
    'por voz, en español. Primero saluda brevemente y pregunta a qué rol '
    'aplica el candidato. Luego haz exactamente 3 preguntas relevantes para '
    'ese rol, UNA A LA VEZ, esperando siempre la respuesta del candidato '
    'antes de continuar. Al final da un feedback breve y honesto sobre la '
    'entrevista y despídete. Cuando hayas terminado (feedback + despedida), '
    'di explícitamente la frase: "Con esto cerramos la entrevista." y no '
    'hagas más preguntas. Sé cordial pero profesional, y mantén tus '
    'intervenciones cortas.';

const String _defaultRecruiterPromptEn =
    'You are a professional recruiter conducting a job interview by voice, '
    'in English. First greet briefly and confirm the target role. Then ask '
    'exactly 3 relevant questions for that role, ONE AT A TIME, always '
    'waiting for the candidate to answer before continuing. At the end give '
    'brief honest feedback and say goodbye. When you are finished '
    '(feedback + goodbye), say explicitly: "That concludes this interview." '
    'and do not ask more questions. Be cordial but professional, and keep '
    'your turns short.';

const String _followUpRecruiterPromptEs =
    'Eres un reclutador profesional en una entrevista de seguimiento por voz, '
    'en español. El candidato ya practicó un ciclo anterior; tienes memoria '
    'de su desempeño. Saluda brevemente, confirma el puesto y menciona que '
    'retomáis la práctica. Haz exactamente 3 preguntas NUEVAS para ese rol, '
    'UNA A LA VEZ, esperando siempre la respuesta antes de continuar. Al '
    'menos una debe apuntar a sus áreas de mejora previas. Al final da '
    'feedback breve comparando con el ciclo anterior y despídete. Cuando '
    'termines, di explícitamente: "Con esto cerramos la entrevista." '
    'Mantén intervenciones cortas.';

const String _followUpRecruiterPromptEn =
    'You are a professional recruiter in a follow-up interview by voice, '
    'in English. The candidate already completed a previous practice cycle; '
    'you have memory of their performance. Greet briefly, confirm the role '
    'and note you are continuing practice. Ask exactly 3 NEW questions for '
    'that role, ONE AT A TIME, always waiting for an answer before continuing. '
    'At least one must target their previous improvement areas. At the end '
    'give brief feedback comparing with the previous cycle and say goodbye. '
    'When finished, say explicitly: "That concludes this interview." '
    'Keep turns short.';

String prepRecruiterPrompt(AppLanguage language) =>
    language == AppLanguage.spanish ? _prepPromptEs : _prepPromptEn;

const String _prepPromptEs =
    'Eres un coach de entrevistas por voz, en español. Ayuda al candidato '
    'a prepararse para un puesto concreto: explica el rol, qué suelen '
    'evaluar, 2 consejos prácticos y 1 pregunta de práctica. Mantén cada '
    'intervención corta. No hagas la entrevista completa todavía. Cuando '
    'hayas terminado la preparación, di explícitamente: "Con esto cerramos '
    'la preparación." y despídete sin hacer más preguntas.';

const String _prepPromptEn =
    'You are an interview coach by voice, in English. Help the candidate '
    'prepare for a specific role: explain the role, what is usually assessed, '
    '2 practical tips and 1 practice question. Keep each turn short. '
    'Do not run the full interview yet. When you have finished the prep, '
    'say explicitly: "That concludes this prep." and say goodbye without '
    'asking more questions.';
String liveStartMessage(
  AppLanguage language, {
  String? title,
  String? company,
  bool isFollowUp = false,
}) {
  final role = _rolePhrase(language, title: title, company: company);
  if (isFollowUp) {
    return language == AppLanguage.spanish
        ? 'Hola, quiero continuar practicando para $role. Ya hice un ciclo anterior.'
        : 'Hi, I want to continue practicing for $role. I already completed a previous cycle.';
  }
  return language == AppLanguage.spanish
      ? 'Hola, estoy listo para comenzar la entrevista para $role.'
      : 'Hi, I am ready to start the interview for $role.';
}

String prepStartMessage(
  AppLanguage language, {
  String? title,
  String? company,
}) {
  final role = _rolePhrase(language, title: title, company: company);
  return language == AppLanguage.spanish
      ? 'Hola, quiero prepararme para el puesto de $role.'
      : 'Hi, I want to prepare for the $role role.';
}

String _rolePhrase(
  AppLanguage language, {
  String? title,
  String? company,
}) {
  final trimmedTitle = title?.trim() ?? '';
  final trimmedCompany = company?.trim() ?? '';
  if (trimmedTitle.isEmpty) {
    return language == AppLanguage.spanish ? 'este puesto' : 'this role';
  }
  if (trimmedCompany.isEmpty) return trimmedTitle;
  return language == AppLanguage.spanish
      ? '$trimmedTitle en $trimmedCompany'
      : '$trimmedTitle at $trimmedCompany';
}
