import 'dart:math' as math;

import 'package:flutter/material.dart';

class LoopBreathingMark extends StatefulWidget {
  const LoopBreathingMark({
    super.key,
    required this.dimension,
    this.color = const Color.fromARGB(255, 18, 207, 109),
  });

  final double dimension;
  final Color color;

  @override
  State<LoopBreathingMark> createState() => _LoopBreathingMarkState();
}

class _LoopBreathingMarkState extends State<LoopBreathingMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final breath = 1.5 + math.sin(_controller.value * math.pi * 2) * 0.02;

          return Transform.scale(
            scale: breath,
            child: SizedBox.square(
              dimension: widget.dimension,
              child: CustomPaint(
                painter: _BreathingLoopPainter(
                  progress: _controller.value,
                  color: widget.color,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BreathingLoopPainter extends CustomPainter {
  const _BreathingLoopPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final minSide = math.min(size.width, size.height);
    final baseRadius = minSide * 0.33;
    final bandThickness = minSide * 0.135;
    final time = progress * math.pi * 2;

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bandThickness * 0.26
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18)
      ..color = color.withValues(alpha: 0.14 + 0.08 * math.sin(time).abs());
    canvas.drawCircle(center, baseRadius, glowPaint);

    for (var band = 0; band < 23; band++) {
      final bandT = band / 22;
      final bandOffset = (bandT - 0.5) * bandThickness;
      final ringRadius = baseRadius + bandOffset;
      final density = (ringRadius * 2.1).round();

      for (var index = 0; index < density; index++) {
        final seed = _hash(index, band);
        if (seed < 0.04 && band != 11) continue;

        final phase = _hash(index + 41, band + 17) * math.pi * 2;
        final angleNoise = (_hash(index + 7, band + 3) - 0.5) * 0.018;
        final angle = (index / density) * math.pi * 2 + angleNoise;
        final pulse = math.sin(time + phase);
        final slowPulse = math.sin(time * 0.5 + phase * 0.7);
        final localRadius = ringRadius + pulse * 1.8 + slowPulse * 0.7;
        final position =
            center + Offset(math.cos(angle), math.sin(angle)) * localRadius;
        final radialStrength = 1 - (bandT - 0.5).abs() * 1.45;
        final dotRadius =
            (0.45 + radialStrength * 1.05) * (0.82 + pulse.abs() * 0.42);
        final alpha = (0.22 + radialStrength * 0.5 + pulse * 0.18)
            .clamp(0.08, 0.92)
            .toDouble();

        final paint = Paint()
          ..isAntiAlias = true
          ..color = color.withValues(alpha: alpha);
        canvas.drawCircle(position, dotRadius, paint);
      }
    }
  }

  double _hash(int x, int y) {
    final value = math.sin(x * 127.1 + y * 311.7) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _BreathingLoopPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
