class Roadmap {
  const Roadmap({
    required this.target,
    required this.finalGoal,
    required this.steps,
  });

  final String target;
  final String finalGoal;
  final List<RoadmapStep> steps;
}

class RoadmapStep {
  const RoadmapStep({
    required this.title,
    required this.category,
    required this.state,
    required this.level,
  });

  final String title;
  final String category;
  final RoadmapStepState state;
  final double? level;
}

enum RoadmapStepState { completed, current, locked }
