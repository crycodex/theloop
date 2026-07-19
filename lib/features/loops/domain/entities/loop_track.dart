class LoopTrack {
  const LoopTrack({
    this.id = '',
    required this.roleTitle,
    required this.company,
    required this.level,
    required this.cyclesCompleted,
    required this.delta,
    required this.progress,
    required this.focus,
    this.prepCompleted = false,
  });

  final String id;
  final String roleTitle;
  final String company;
  final double level;
  final int cyclesCompleted;
  final double delta;
  final double progress;
  final String focus;
  final bool prepCompleted;
}
