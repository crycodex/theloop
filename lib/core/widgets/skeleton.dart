import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';
import 'loop_card.dart';

class _SkeletonPulse extends StatefulWidget {
  const _SkeletonPulse({required this.builder});

  final Widget Function(BuildContext context, double alpha) builder;

  @override
  State<_SkeletonPulse> createState() => _SkeletonPulseState();
}

class _SkeletonPulseState extends State<_SkeletonPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);
  late final Animation<double> _alpha = Tween<double>(
    begin: 0.08,
    end: 0.18,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _alpha,
      builder: (context, _) => widget.builder(context, _alpha.value),
    );
  }
}

class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = 10,
  });

  final double height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return _SkeletonPulse(
      builder: (context, alpha) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: LoopColors.textMuted.withValues(alpha: alpha),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SkeletonCircle extends StatelessWidget {
  const SkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return _SkeletonPulse(
      builder: (context, alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: LoopColors.textMuted.withValues(alpha: alpha),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class SkeletonLine extends StatelessWidget {
  const SkeletonLine({
    super.key,
    this.width = double.infinity,
    this.height = 14,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SkeletonBox(height: height, width: width, borderRadius: 8);
  }
}

/// A card row placeholder: a leading circle avatar next to a column of
/// text-line placeholders. Mirrors the common "avatar + title/subtitle"
/// shape used across loops/profile/recap cards.
class SkeletonCardRow extends StatelessWidget {
  const SkeletonCardRow({
    super.key,
    required this.circleSize,
    required this.lineWidths,
    this.color,
    this.padding = const EdgeInsets.all(22),
  });

  final double circleSize;
  final List<double> lineWidths;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      color: color,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonCircle(size: circleSize),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < lineWidths.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  SkeletonLine(width: lineWidths[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
