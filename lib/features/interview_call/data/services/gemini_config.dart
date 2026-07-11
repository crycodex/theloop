import '../../../../core/settings/cubit/settings_state.dart';

const String kGeminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

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

  String label(AppLanguage language) => switch (this) {
    RecruiterVoice.sadaltager =>
      language == AppLanguage.spanish ? 'Profesional (Sadaltager)' : 'Professional (Sadaltager)',
    RecruiterVoice.puck =>
      language == AppLanguage.spanish ? 'Cálido (Puck)' : 'Warm (Puck)',
    RecruiterVoice.kore =>
      language == AppLanguage.spanish ? 'Claro (Kore)' : 'Clear (Kore)',
    RecruiterVoice.fenrir =>
      language == AppLanguage.spanish ? 'Directo (Fenrir)' : 'Direct (Fenrir)',
  };
}

String defaultRecruiterPrompt(AppLanguage language) =>
    language == AppLanguage.spanish ? _defaultRecruiterPromptEs : _defaultRecruiterPromptEn;

const String _defaultRecruiterPromptEs =
    'Eres un reclutador profesional realizando una entrevista de trabajo '
    'por voz, en español. Primero saluda brevemente y pregunta a qué rol '
    'aplica el candidato. Luego haz exactamente 3 preguntas relevantes para '
    'ese rol, UNA A LA VEZ, esperando siempre la respuesta del candidato '
    'antes de continuar. Al final da un feedback breve y honesto sobre la '
    'entrevista y despídete. Sé cordial pero profesional, y mantén tus '
    'intervenciones cortas.';

const String _defaultRecruiterPromptEn =
    'You are a professional recruiter conducting a job interview by voice, '
    'in English. First greet briefly and confirm the target role. Then ask '
    'exactly 3 relevant questions for that role, ONE AT A TIME, always '
    'waiting for the candidate to answer before continuing. At the end give '
    'brief honest feedback and say goodbye. Be cordial but professional, '
    'and keep your turns short.';

String prepRecruiterPrompt(AppLanguage language) =>
    language == AppLanguage.spanish ? _prepPromptEs : _prepPromptEn;

const String _prepPromptEs =
    'Eres un coach de entrevistas por voz, en español. Ayuda al candidato '
    'a prepararse para un puesto concreto: explica el rol, qué suelen '
    'evaluar, 2 consejos prácticos y 1 pregunta de práctica. Mantén cada '
    'intervención corta. No hagas la entrevista completa todavía.';

const String _prepPromptEn =
    'You are an interview coach by voice, in English. Help the candidate '
    'prepare for a specific role: explain the role, what is usually assessed, '
    '2 practical tips and 1 practice question. Keep each turn short. '
    'Do not run the full interview yet.';

String liveStartMessage(AppLanguage language) => language == AppLanguage.spanish
    ? 'Hola, estoy listo para comenzar la entrevista.'
    : 'Hi, I am ready to start the interview.';

String prepStartMessage(AppLanguage language) => language == AppLanguage.spanish
    ? 'Hola, quiero prepararme para este puesto.'
    : 'Hi, I want to prepare for this role.';
