class Roadmap {
  const Roadmap({
    required this.target,
    required this.finalGoal,
    required this.generatedAt,
    required this.steps,
    this.goalId = '',
    this.isCatalog = false,
  });

  final String target;
  final String finalGoal;
  final DateTime generatedAt;
  final List<RoadmapStep> steps;
  final String goalId;

  /// `true` cuando proviene del catálogo predefinido en `roadmap_catalog`
  /// (progreso por lecciones), `false` cuando fue generado con Gemini.
  final bool isCatalog;

  Roadmap copyWith({List<RoadmapStep>? steps}) {
    return Roadmap(
      target: target,
      finalGoal: finalGoal,
      generatedAt: generatedAt,
      steps: steps ?? this.steps,
      goalId: goalId,
      isCatalog: isCatalog,
    );
  }

  RoadmapStep? stepById(String id) {
    for (final step in steps) {
      if (step.id == id) return step;
    }
    return null;
  }

  Map<String, dynamic> toMap() {
    return {
      'target': target,
      'finalGoal': finalGoal,
      'generatedAt': generatedAt.toUtc().toIso8601String(),
      'steps': steps.map((step) => step.toMap()).toList(growable: false),
    };
  }

  factory Roadmap.fromMap(Map<String, dynamic> map) {
    return Roadmap(
      target: map['target'] as String? ?? '',
      finalGoal: map['finalGoal'] as String? ?? '',
      generatedAt:
          DateTime.tryParse(map['generatedAt'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      steps: (map['steps'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(RoadmapStep.fromMap)
          .toList(growable: false),
    );
  }

  /// Documento de `roadmap_catalog/{goalId}` con textos localizados
  /// `{es: ..., en: ...}` resueltos según [es].
  factory Roadmap.fromCatalogMap(Map<String, dynamic> map, {required bool es}) {
    return Roadmap(
      target: localizedText(map['target'], es),
      finalGoal: localizedText(map['finalGoal'], es),
      generatedAt: DateTime.now(),
      goalId: map['goalId'] as String? ?? '',
      isCatalog: true,
      steps: (map['steps'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map((step) => RoadmapStep.fromCatalogMap(step, es: es))
          .toList(growable: false),
    );
  }
}

class RoadmapStep {
  const RoadmapStep({
    required this.title,
    required this.category,
    required this.guide,
    required this.tips,
    this.id = '',
    this.type = RoadmapStepType.lesson,
    this.lesson,
    this.state = RoadmapStepState.locked,
  });

  final String id;
  final String title;
  final String category;
  final String guide;
  final List<String> tips;
  final RoadmapStepType type;
  final RoadmapLesson? lesson;
  final RoadmapStepState state;

  bool get hasLesson => lesson != null && lesson!.sections.isNotEmpty;

  RoadmapStep copyWith({RoadmapStepState? state}) {
    return RoadmapStep(
      id: id,
      title: title,
      category: category,
      guide: guide,
      tips: tips,
      type: type,
      lesson: lesson,
      state: state ?? this.state,
    );
  }

  /// `state` no se persiste: se deriva del progreso al cargar.
  Map<String, dynamic> toMap() {
    return {'title': title, 'category': category, 'guide': guide, 'tips': tips};
  }

  factory RoadmapStep.fromMap(Map<String, dynamic> map) {
    return RoadmapStep(
      title: map['title'] as String? ?? '',
      category: map['category'] as String? ?? '',
      guide: map['guide'] as String? ?? '',
      tips: (map['tips'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
    );
  }

  factory RoadmapStep.fromCatalogMap(
    Map<String, dynamic> map, {
    required bool es,
  }) {
    final lessonMap = map['lesson'] as Map<String, dynamic>?;
    return RoadmapStep(
      id: map['id'] as String? ?? '',
      title: localizedText(map['title'], es),
      category: localizedText(map['category'], es),
      guide: localizedText(map['guide'], es),
      tips: localizedList(map['tips'], es),
      type: map['type'] == 'call'
          ? RoadmapStepType.call
          : RoadmapStepType.lesson,
      lesson: lessonMap == null
          ? null
          : RoadmapLesson.fromCatalogMap(lessonMap, es: es),
    );
  }
}

class RoadmapLesson {
  const RoadmapLesson({required this.sections, required this.quiz});

  final List<LessonSection> sections;
  final List<QuizQuestion> quiz;

  factory RoadmapLesson.fromCatalogMap(
    Map<String, dynamic> map, {
    required bool es,
  }) {
    return RoadmapLesson(
      sections: (map['sections'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (section) => LessonSection(
              title: localizedText(section['title'], es),
              body: localizedText(section['body'], es),
            ),
          )
          .toList(growable: false),
      quiz: (map['quiz'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(
            (question) => QuizQuestion(
              question: localizedText(question['question'], es),
              options: localizedList(question['options'], es),
              correctIndex: question['correctIndex'] as int? ?? 0,
              explanation: localizedText(question['explanation'], es),
            ),
          )
          .toList(growable: false),
    );
  }
}

class LessonSection {
  const LessonSection({required this.title, required this.body});

  final String title;
  final String body;
}

class QuizQuestion {
  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
}

enum RoadmapStepType { lesson, call }

enum RoadmapStepState { completed, current, locked }

String localizedText(dynamic value, bool es) {
  if (value is String) return value;
  if (value is Map<String, dynamic>) {
    final primary = value[es ? 'es' : 'en'];
    final fallback = value[es ? 'en' : 'es'];
    if (primary is String && primary.isNotEmpty) return primary;
    if (fallback is String) return fallback;
  }
  return '';
}

List<String> localizedList(dynamic value, bool es) {
  if (value is List) return value.whereType<String>().toList(growable: false);
  if (value is Map<String, dynamic>) {
    final primary = value[es ? 'es' : 'en'];
    final fallback = value[es ? 'en' : 'es'];
    final list = primary is List ? primary : fallback;
    if (list is List) return list.whereType<String>().toList(growable: false);
  }
  return const [];
}
