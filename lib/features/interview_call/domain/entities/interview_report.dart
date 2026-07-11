class InterviewReport {
  const InterviewReport({
    required this.role,
    required this.summary,
    required this.strengths,
    required this.improvements,
    required this.score,
    required this.recommendation,
    required this.memorySummary,
  });

  final String role;
  final String summary;
  final List<String> strengths;
  final List<String> improvements;
  final double score;
  final String recommendation;
  final String memorySummary;

  factory InterviewReport.fromJson(Map<String, dynamic> json) {
    List<String> strings(String key) => (json[key] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toList(growable: false);

    return InterviewReport(
      role: json['role'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      strengths: strings('strengths'),
      improvements: strings('improvements'),
      score: (json['score'] as num?)?.toDouble() ?? 0,
      recommendation: json['recommendation'] as String? ?? '',
      memorySummary: json['memorySummary'] as String? ?? '',
    );
  }
}
