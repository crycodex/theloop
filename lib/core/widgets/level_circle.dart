import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';

class LevelCircle extends StatelessWidget {
  const LevelCircle({
    super.key,
    required this.level,
    this.maxLevel = 5,
    this.size = 116,
    this.foregroundColor = LoopColors.accentGreen,
    this.backgroundColor = const Color(0x334D6827),
    this.textColor = LoopColors.textPrimary,
  });

  final double level;
  final int maxLevel;
  final double size;
  final Color foregroundColor;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _LevelCirclePainter(
          progress: (level / maxLevel).clamp(0, 1).toDouble(),
          foregroundColor: foregroundColor,
          backgroundColor: backgroundColor,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                level.toStringAsFixed(1),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'de $maxLevel',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: textColor.withValues(alpha: 0.68),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelCirclePainter extends CustomPainter {
  const _LevelCirclePainter({
    required this.progress,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.08;
    final rect = Offset.zero & size;
    final circleRect = rect.deflate(strokeWidth / 2);
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(circleRect, 0, math.pi * 2, false, backgroundPaint);
    canvas.drawArc(
      circleRect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _LevelCirclePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.foregroundColor != foregroundColor ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
