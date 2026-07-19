class CvAnalysis {
  const CvAnalysis({
    required this.score,
    required this.qualification,
    required this.summary,
    required this.analyzedAt,
    required this.criteria,
    this.matchScore,
    this.matchSummary,
    this.matchTrackTitle,
  });

  final int score;
  final String qualification;
  final String summary;
  final DateTime analyzedAt;
  final List<CvCriterion> criteria;
  final int? matchScore;
  final String? matchSummary;
  final String? matchTrackTitle;

  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'qualification': qualification,
      'summary': summary,
      'analyzedAt': analyzedAt.toUtc().toIso8601String(),
      'criteria': criteria.map((item) => item.toMap()).toList(growable: false),
      if (matchScore != null) 'matchScore': matchScore,
      if (matchSummary != null) 'matchSummary': matchSummary,
      if (matchTrackTitle != null) 'matchTrackTitle': matchTrackTitle,
    };
  }

  factory CvAnalysis.fromMap(Map<String, dynamic> map) {
    return CvAnalysis(
      score: (map['score'] as num?)?.round() ?? 0,
      qualification: map['qualification'] as String? ?? '',
      summary: map['summary'] as String? ?? '',
      analyzedAt:
          DateTime.tryParse(map['analyzedAt'] as String? ?? '')?.toLocal() ??
              DateTime.now(),
      criteria: (map['criteria'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CvCriterion.fromMap)
          .toList(growable: false),
      matchScore: (map['matchScore'] as num?)?.round(),
      matchSummary: map['matchSummary'] as String?,
      matchTrackTitle: map['matchTrackTitle'] as String?,
    );
  }
}

class CvCriterion {
  const CvCriterion({
    required this.name,
    required this.score,
    required this.feedback,
  });

  final String name;
  final double score;
  final String feedback;

  Map<String, dynamic> toMap() {
    return {'name': name, 'score': score, 'feedback': feedback};
  }

  factory CvCriterion.fromMap(Map<String, dynamic> map) {
    return CvCriterion(
      name: map['name'] as String? ?? '',
      score: ((map['score'] as num?)?.toDouble() ?? 0).clamp(0, 1).toDouble(),
      feedback: map['feedback'] as String? ?? '',
    );
  }
}
