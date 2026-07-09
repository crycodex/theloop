import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../settings/cubit/settings_cubit.dart';
import '../settings/cubit/settings_state.dart';

class AppStrings {
  const AppStrings(this.language);

  final AppLanguage language;

  static AppStrings of(BuildContext context) {
    final language = context.select<SettingsCubit, AppLanguage>(
      (cubit) => cubit.state.language,
    );
    return AppStrings(language);
  }

  bool get _es => language == AppLanguage.spanish;

  String get appTitle => 'Loop';
  String get homePreparingFor => _es ? 'Tu preparación para' : 'Your prep for';
  String get generalLevel => _es ? 'Nivel general' : 'General level';
  String get generalLevelSummary => _es
      ? 'Listo para sostener una entrevista conductual exigente, con oportunidad de profundizar resultados.'
      : 'Ready for a demanding behavioral interview, with room to deepen impact and outcomes.';
  String get streak => _es ? 'Racha' : 'Streak';
  String days(int count) => _es ? '$count dias' : '$count days';
  String get loops => 'Loops';
  String get continueLabel => _es ? 'Continuar' : 'Continue';
  String get seeLoops => _es ? 'Ver loops' : 'See loops';
  String nextFocus(String focus) => _es
      ? 'Siguiente foco: ${trackFocus(focus)}'
      : 'Next focus: ${trackFocus(focus)}';
  String cyclesCompleted(int count) =>
      _es ? '$count ciclos completados' : '$count cycles completed';
  String cycles(int count) => _es ? '$count ciclos' : '$count cycles';
  String get criteriaEvolution =>
      _es ? 'Evolución por criterio' : 'Progress by criterion';

  String get tracks => _es ? 'Trayectos' : 'Tracks';
  String get tracksDescription => _es
      ? 'Cada loop mide tu progreso frente a un puesto objetivo concreto.'
      : 'Each loop measures your progress against a specific target role.';
  String get createCustomTrack => _es
      ? 'Crear trayecto a medida pegando una descripción de oferta'
      : 'Create a custom track by pasting a job description';

  String get cvAnalysis => 'CV Analysis';
  String get cvDescription => _es
      ? 'Tu hoja de vida medida contra claridad, impacto y match con ofertas.'
      : 'Your resume measured against clarity, impact, and job fit.';
  String scoreCurrent(int score) =>
      _es ? 'Score actual: $score/100' : 'Current score: $score/100';
  String lastAnalysis(String value) => _es
      ? 'Ultimo analisis: ${dateLabel(value)}'
      : 'Last analysis: ${dateLabel(value)}';
  String get newScore => _es ? 'Nuevo score' : 'New score';
  String get breakdown => _es ? 'Desglose' : 'Breakdown';
  String get matchVsJob => _es ? 'Match vs oferta' : 'Match vs job';

  String get roadmap => _es ? 'Ruta' : 'Roadmap';
  String roadmapDescription(String target) => _es
      ? 'Preparación paso a paso para $target.'
      : 'Step-by-step preparation for $target.';
  String finalGoal(String value) => _es
      ? 'Meta final: ${roadmapText(value)}'
      : 'Final goal: ${roadmapText(value)}';
  String levelAchieved(double level) => _es
      ? 'Nivel logrado ${level.toStringAsFixed(1)} de 5'
      : 'Level achieved ${level.toStringAsFixed(1)} of 5';
  String get practiceNow => _es ? 'Practicar ahora' : 'Practice now';

  String get profile => _es ? 'Perfil' : 'Profile';
  String get careerGoal => _es ? 'Objetivo profesional' : 'Career goal';
  String get careerGoalSubtitle => _es
      ? 'Rol, nivel, empresas e idioma'
      : 'Role, level, companies, and language';
  String get subscription => _es ? 'Suscripción' : 'Subscription';
  String subscriptionPlan(String value) {
    if (_es) return value;
    if (value.startsWith('Plan Pro mock')) {
      return 'Mock Pro plan · \$50/month';
    }
    return value;
  }

  String get privacy => _es ? 'Privacidad' : 'Privacy';
  String get privacySubtitle => _es
      ? 'Exportar datos o eliminar cuenta'
      : 'Export data or delete account';
  String get preferences => _es ? 'Preferencias' : 'Preferences';
  String get preferencesSubtitle =>
      _es ? 'Tema e idioma' : 'Theme and language';
  String get darkMode => _es ? 'Modo oscuro' : 'Dark mode';
  String get languageLabel => _es ? 'Idioma' : 'Language';

  String get recapTitle => _es ? 'Reporte final' : 'Final report';
  String get strength => _es ? 'Fortaleza' : 'Strength';
  String get improvement => _es ? 'Mejora' : 'Improvement';
  String get practiceAgain => _es ? 'Practicar de nuevo' : 'Practice again';
  String get viewTranscript => _es ? 'Ver transcripción' : 'View transcript';

  String get interviewerAi => 'Interviewer AI';
  String get live => _es ? 'EN VIVO' : 'LIVE';
  String get interviewPaused =>
      _es ? 'Entrevista pausada.' : 'Interview paused.';
  String get mic => 'Mic';
  String get mute => 'Mute';
  String get pause => _es ? 'Pausar' : 'Pause';
  String get resume => _es ? 'Seguir' : 'Resume';
  String get endCall => _es ? 'Terminar' : 'End';

  String criterion(String value) {
    if (_es) return value;
    return switch (value) {
      'Estructura STAR' => 'STAR structure',
      'Impacto medible' => 'Measurable impact',
      'Claridad' => 'Clarity',
      'Profundidad' => 'Depth',
      _ => value,
    };
  }

  String trackFocus(String value) {
    if (_es) return value;
    return switch (value) {
      'Ownership y conflictos técnicos' => 'Ownership and technical conflict',
      'Colaboración cross-functional' => 'Cross-functional collaboration',
      'Ambiguedad y toma de decisiones' => 'Ambiguity and decision-making',
      _ => value,
    };
  }

  String cvCriterion(String value) {
    if (_es) return value;
    return switch (value) {
      'Experiencia relevante' => 'Relevant experience',
      'Logros medibles' => 'Measurable achievements',
      'Claridad narrativa' => 'Narrative clarity',
      'Formato ATS' => 'ATS format',
      _ => value,
    };
  }

  String roadmapText(String value) {
    if (_es) return value;
    return switch (value) {
      'simulación behavioral para Meta' => 'behavioral simulation for Meta',
      'Define tu historia profesional' => 'Define your professional story',
      'Practica ownership con STAR' => 'Practice ownership with STAR',
      'Mejora resultados cuantificados' => 'Improve quantified outcomes',
      'Simulación final Meta' => 'Final Meta simulation',
      'Foundation' => 'Foundation',
      'Behavioral' => 'Behavioral',
      'Mock interview' => 'Mock interview',
      _ => value,
    };
  }

  String recapText(String value) {
    if (_es) return value;
    return switch (value) {
      'Buen avance' => 'Good progress',
      'Tu respuesta fue más concreta y conectó mejor decisiones con resultados.' =>
        'Your answer was more concrete and connected decisions to outcomes more clearly.',
      'Explicaste el contexto sin perder el foco del problema.' =>
        'You explained the context without losing focus on the problem.',
      'Cierra con una métrica antes de pasar a aprendizajes.' =>
        'Close with a metric before moving into learnings.',
      _ => value,
    };
  }

  String cvSummary(String value) {
    if (_es) return value;
    if (value.startsWith('Tu CV ya comunica')) {
      return 'Your resume already communicates strong mobile experience. Quantify impact in performance, quality, and technical leadership.';
    }
    return value;
  }

  String interviewPrompt(String value) {
    if (_es) return value;
    if (value.startsWith('Cuéntame de una vez')) {
      return 'Tell me about a time when you had to lead a technical decision with incomplete information.';
    }
    return value;
  }

  String dateLabel(String value) {
    if (_es) return value;
    return switch (value) {
      'hoy' => 'today',
      _ => value,
    };
  }
}
