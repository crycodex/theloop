import 'package:flutter/material.dart';

import '../core/theme/loop_colors.dart';

class CriterionProgress {
  const CriterionProgress({
    required this.name,
    required this.score,
    required this.trend,
  });

  final String name;
  final double score;
  final String trend;
}

class LoopTrackMock {
  const LoopTrackMock({
    required this.roleTitle,
    required this.company,
    required this.level,
    required this.cyclesCompleted,
    required this.delta,
    required this.progress,
    required this.focus,
  });

  final String roleTitle;
  final String company;
  final double level;
  final int cyclesCompleted;
  final double delta;
  final double progress;
  final String focus;
}

class RoadmapStepMock {
  const RoadmapStepMock({
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

class CvCriterionMock {
  const CvCriterionMock({
    required this.name,
    required this.score,
    required this.color,
  });

  final String name;
  final double score;
  final Color color;
}

abstract final class LoopMockData {
  static const userName = 'Cristhian';
  static const target = 'Mobile Engineer · Meta';
  static const generalLevel = 3.7;
  static const streakDays = 6;
  static const totalLoops = 18;

  static const criteria = [
    CriterionProgress(name: 'Estructura STAR', score: 0.82, trend: '+0.4'),
    CriterionProgress(name: 'Impacto medible', score: 0.68, trend: '+0.2'),
    CriterionProgress(name: 'Claridad', score: 0.76, trend: '+0.3'),
    CriterionProgress(name: 'Profundidad', score: 0.61, trend: 'plano'),
  ];

  static const tracks = [
    LoopTrackMock(
      roleTitle: 'Mobile Engineer',
      company: 'Meta',
      level: 3.7,
      cyclesCompleted: 8,
      delta: 0.4,
      progress: 0.74,
      focus: 'Ownership y conflictos técnicos',
    ),
    LoopTrackMock(
      roleTitle: 'Senior Flutter Engineer',
      company: 'Spotify',
      level: 3.2,
      cyclesCompleted: 5,
      delta: 0.3,
      progress: 0.58,
      focus: 'Colaboración cross-functional',
    ),
    LoopTrackMock(
      roleTitle: 'AI Product Engineer',
      company: 'OpenAI',
      level: 2.8,
      cyclesCompleted: 3,
      delta: 0.5,
      progress: 0.42,
      focus: 'Ambiguedad y toma de decisiones',
    ),
  ];

  static const cvCriteria = [
    CvCriterionMock(
      name: 'Experiencia relevante',
      score: 0.84,
      color: LoopColors.lightGreen,
    ),
    CvCriterionMock(name: 'Logros medibles', score: 0.64, color: LoopColors.amber),
    CvCriterionMock(
      name: 'Claridad narrativa',
      score: 0.78,
      color: LoopColors.infoBlue,
    ),
    CvCriterionMock(name: 'Formato ATS', score: 0.91, color: LoopColors.lightGreen),
  ];

  static const roadmapSteps = [
    RoadmapStepMock(
      title: 'Define tu historia profesional',
      category: 'Foundation',
      state: RoadmapStepState.completed,
      level: 3.4,
    ),
    RoadmapStepMock(
      title: 'Practica ownership con STAR',
      category: 'Behavioral',
      state: RoadmapStepState.completed,
      level: 3.7,
    ),
    RoadmapStepMock(
      title: 'Mejora resultados cuantificados',
      category: 'Behavioral',
      state: RoadmapStepState.current,
      level: null,
    ),
    RoadmapStepMock(
      title: 'Simulación final Meta',
      category: 'Mock interview',
      state: RoadmapStepState.locked,
      level: null,
    ),
  ];
}
