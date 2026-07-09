import 'package:flutter/material.dart';

class CvAnalysis {
  const CvAnalysis({
    required this.score,
    required this.lastAnalyzedLabel,
    required this.criteria,
    required this.matchScore,
    required this.matchSummary,
  });

  final int score;
  final String lastAnalyzedLabel;
  final List<CvCriterion> criteria;
  final int matchScore;
  final String matchSummary;
}

class CvCriterion {
  const CvCriterion({
    required this.name,
    required this.score,
    required this.color,
  });

  final String name;
  final double score;
  final Color color;
}
