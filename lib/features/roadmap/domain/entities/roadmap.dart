class Roadmap {
  const Roadmap({
    required this.target,
    required this.finalGoal,
    required this.generatedAt,
    required this.steps,
  });

  final String target;
  final String finalGoal;
  final DateTime generatedAt;
  final List<RoadmapStep> steps;

  Roadmap copyWith({List<RoadmapStep>? steps}) {
    return Roadmap(
      target: target,
      finalGoal: finalGoal,
      generatedAt: generatedAt,
      steps: steps ?? this.steps,
    );
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
}

class RoadmapStep {
  const RoadmapStep({
    required this.title,
    required this.category,
    required this.guide,
    required this.tips,
    this.state = RoadmapStepState.locked,
  });

  final String title;
  final String category;
  final String guide;
  final List<String> tips;
  final RoadmapStepState state;

  RoadmapStep copyWith({RoadmapStepState? state}) {
    return RoadmapStep(
      title: title,
      category: category,
      guide: guide,
      tips: tips,
      state: state ?? this.state,
    );
  }

  /// `state` no se persiste: se deriva del progreso de loops al cargar.
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
}

enum RoadmapStepState { completed, current, locked }
