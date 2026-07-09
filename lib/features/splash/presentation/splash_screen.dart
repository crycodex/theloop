import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'cubit/splash_cubit.dart';
import 'cubit/splash_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _controller.repeat();
    _completeWhenAppIsReady();
  }

  Future<void> _completeWhenAppIsReady() async {
    await Future.wait([
      WidgetsBinding.instance.endOfFrame,
      Future<void>.delayed(const Duration(seconds: 3)),
    ]);
    if (mounted) {
      context.read<SplashCubit>().complete();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplashState>(
      listener: (context, state) {
        if (state is SplashCompleted) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return RepaintBoundary(
                child: SizedBox.square(
                  dimension: 360,
                  child: CustomPaint(
                    painter: _IndependentDottedRingPainter(
                      progress: _controller.value,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _IndependentDottedRingPainter extends CustomPainter {
  const _IndependentDottedRingPainter({required this.progress});

  final double progress;

  static const _dotColor = Color(0xFF09F27B);

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
      ..color = _dotColor.withValues(alpha: 0.14 + 0.08 * math.sin(time).abs());
    canvas.drawCircle(center, baseRadius, glowPaint);

    for (var band = 0; band < 17; band++) {
      final bandT = band / 16;
      final bandOffset = (bandT - 0.5) * bandThickness;
      final ringRadius = baseRadius + bandOffset;
      final density = (ringRadius * 1.68).round();

      for (var index = 0; index < density; index++) {
        final seed = _hash(index, band);
        if (seed < 0.12 && band != 8) {
          continue;
        }

        final phase = _hash(index + 41, band + 17) * math.pi * 2;
        final angleNoise = (_hash(index + 7, band + 3) - 0.5) * 0.018;
        final angle = (index / density) * math.pi * 2 + angleNoise;
        final pulse = math.sin(time + phase);
        final slowPulse = math.sin(time * 0.5 + phase * 0.7);
        final localRadius = ringRadius + pulse * 3.2 + slowPulse * 1.1;
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
          ..color = _dotColor.withValues(alpha: alpha);
        canvas.drawCircle(position, dotRadius, paint);
      }
    }
  }

  double _hash(int x, int y) {
    final value = math.sin(x * 127.1 + y * 311.7) * 43758.5453;
    return value - value.floorToDouble();
  }

  @override
  bool shouldRepaint(covariant _IndependentDottedRingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
