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
  String get welcomeLanguage => _es ? 'Español' : 'English';
  String get welcomeHeadline => _es
      ? 'Domina la entrevista,\nconsigue la oportunidad'
      : 'Master the interview,\nland the opportunity';
  String get tapToContinue => _es ? 'Toca para continuar' : 'Tap to continue';
  String get welcomeLogin => _es
      ? '¿Ya tienes cuenta? Inicia sesión'
      : 'Already have an account? Sign in';
  String get loginTitle => _es ? 'Bienvenido' : 'Welcome';
  String get loginDescription => _es
      ? 'Continúa donde lo dejaste y sigue mejorando.'
      : 'Pick up where you left off and keep improving.';
  String get emailLabel => _es ? 'Email' : 'Email';
  String get emailHint => _es ? 'Ingresa tu email' : 'Enter your email';
  String get passwordLabel => _es ? 'Contraseña' : 'Password';
  String get passwordHint =>
      _es ? 'Ingresa tu contraseña' : 'Enter your password';
  String get confirmPasswordLabel =>
      _es ? 'Confirmar contraseña' : 'Confirm password';
  String get confirmPasswordHint =>
      _es ? 'Repite tu contraseña' : 'Repeat your password';
  String get forgotPassword =>
      _es ? '¿Olvidaste tu contraseña?' : 'Forgot your password?';
  String get forgotPasswordTitle =>
      _es ? 'Recupera tu cuenta' : 'Recover your account';
  String get forgotPasswordDescription => _es
      ? 'Ingresa tu email y te enviaremos instrucciones para crear una nueva contraseña.'
      : 'Enter your email and we will send instructions to create a new password.';
  String get sendResetLink =>
      _es ? 'Enviar instrucciones' : 'Send instructions';
  String get resetLinkSentTitle =>
      _es ? 'Revisa tu correo' : 'Check your email';
  String resetLinkSentDescription(String email) => _es
      ? 'Enviamos las instrucciones a $email. Revisa también tu carpeta de spam.'
      : 'We sent instructions to $email. Check your spam folder too.';
  String get backToLogin => _es ? 'Volver a iniciar sesión' : 'Back to sign in';
  String get signIn => _es ? 'Iniciar sesión' : 'Sign in';
  String get noAccount =>
      _es ? '¿No tienes una cuenta?' : "Don't have an account?";
  String get register => _es ? 'Regístrate' : 'Register';
  String get nameLabel => _es ? 'Nombre completo' : 'Full name';
  String get nameHint => _es ? '¿Cómo te llamas?' : 'What is your name?';
  String get createAccount => _es ? 'Crear cuenta' : 'Create account';
  String get exitOnboarding => _es ? 'Salir' : 'Exit';
  String get customGoalLabel =>
      _es ? 'Describe tu objetivo' : 'Describe your goal';
  String get customGoalHint => _es
      ? 'Ej. Prepararme para una entrevista de diseño'
      : 'E.g. Prepare for a design interview';
  String get accountDetailsTitle =>
      _es ? 'Empecemos contigo' : "Let's start with you";
  String get accountDetailsDescription => _es
      ? 'Cuéntanos un poco para personalizar tu loop.'
      : 'Tell us a little so we can personalize your loop.';
  String get goalTitle => _es ? '¿Cuál es tu objetivo?' : 'What is your goal?';
  String get goalDescription => _es
      ? 'Personalizamos tu ruta según tus elecciones.'
      : 'We personalize your path around your choices.';
  String get experienceTitle => _es
      ? '¿Cuál es tu nivel de\nexperiencia?'
      : 'What is your experience\nlevel?';
  String get experienceDescription => _es
      ? 'Calibraremos tu dificultad y nivel para progresar.'
      : "We'll calibrate your difficulty and level to help you progress.";
  String get finishTitle =>
      _es ? 'Tu loop está en camino' : 'Your loop is on its way';
  String get finishDescription =>
      _es ? 'Construyendo tu mejor camino' : 'Building your best path';
  String get creating => _es ? 'Creando...' : 'Creating...';
  String get next => _es ? 'Continuar' : 'Continue';
  String get buildMyLoop => _es ? 'Crear mi loop' : 'Create my loop';
  String stepProgress(int step, int total) =>
      _es ? 'Paso $step de $total' : 'Step $step of $total';
  String get requiredFieldError =>
      _es ? 'Este campo es obligatorio' : 'This field is required';
  String get invalidEmailError =>
      _es ? 'Ingresa un email válido' : 'Enter a valid email';
  String get shortPasswordError =>
      _es ? 'Ingresa al menos 6 caracteres' : 'Enter at least 6 characters';
  String get passwordsDoNotMatchError =>
      _es ? 'Las contraseñas no coinciden' : 'Passwords do not match';
  String get goalBigTech => 'Faang/BigTech';
  String get goalBigTechDetail =>
      _es ? 'Google · Meta · Amazon' : 'Google · Meta · Amazon';
  String get goalConsulting => _es ? 'Consultoría MBB' : 'MBB Consulting';
  String get goalConsultingDetail => 'McKinsey · BCG · Bain';
  String get goalBanking => _es ? 'Banca de Inversión' : 'Investment Banking';
  String get goalBankingDetail => 'Goldman · JPM · MS';
  String get goalStartup => 'Startup';
  String get goalStartupDetail =>
      _es ? 'SERIE A-D, Scaleups' : 'Series A-D, Scaleups';
  String get goalProductManager => 'Product Manager';
  String get goalProductManagerDetail => _es ? 'Roles PM' : 'PM roles';
  String get goalCustom => _es ? 'Mi Objetivo' : 'My goal';
  String get goalCustomDetail => _es ? 'Lo defino yo' : 'I define it';
  String goalLabel(String id) => switch (id) {
    'bigTech' => goalBigTech,
    'consulting' => goalConsulting,
    'banking' => goalBanking,
    'startup' => goalStartup,
    'productManager' => goalProductManager,
    'custom' => goalCustom,
    _ => id,
  };
  String get experienceNone => _es ? 'Sin experiencia' : 'No experience';
  String get experienceNoneDetail =>
      _es ? '0 - 1, Estudiante o graduado' : '0 - 1, Student or graduate';
  String get experienceSome => _es ? 'Algo de experiencia' : 'Some experience';
  String get experienceSomeDetail => _es
      ? '2 - 4 años, He tenido algunas entrevistas'
      : '2 - 4 years, I have had some interviews';
  String get experienceAdvanced =>
      _es ? 'Tengo experiencia' : 'I have experience';
  String get experienceAdvancedDetail => _es
      ? '+ 5 años, Tengo trabajo pero quiero mejorar'
      : '+ 5 years, I have a job but want to improve';
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

  String get logout => _es ? 'Cerrar sesión' : 'Sign out';
  String get logoutConfirmTitle =>
      _es ? '¿Cerrar sesión?' : 'Sign out?';
  String get logoutConfirmMessage => _es
      ? 'Tendrás que iniciar sesión de nuevo.'
      : "You'll need to sign in again.";

  String get authErrorEmailInUse =>
      _es ? 'Ese correo ya está registrado.' : 'That email is already registered.';
  String get authErrorInvalidCredential => _es
      ? 'Correo o contraseña incorrectos.'
      : 'Incorrect email or password.';
  String get authErrorWeakPassword =>
      _es ? 'La contraseña es demasiado débil.' : 'Password is too weak.';
  String get authErrorNetwork =>
      _es ? 'Sin conexión. Inténtalo de nuevo.' : 'No connection. Try again.';
  String get authErrorUnknown => _es
      ? 'Ocurrió un error. Inténtalo de nuevo.'
      : 'Something went wrong. Try again.';
  String get authErrorEmailNotVerified => _es
      ? 'Debes verificar tu correo antes de iniciar sesión. Te reenviamos el enlace.'
      : 'You need to verify your email before signing in. We resent the link.';

  String get verifyEmailTitle =>
      _es ? 'Verifica tu correo' : 'Verify your email';
  String verifyEmailMessage(String email) => _es
      ? 'Te enviamos un enlace de verificación a $email. Confírmalo y luego inicia sesión.'
      : 'We sent a verification link to $email. Confirm it and then sign in.';

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
