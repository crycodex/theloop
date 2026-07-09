import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';

class LoopCard extends StatelessWidget {
  const LoopCard({
    super.key,
    required this.child,
    this.color = LoopColors.surfaceElevated,
    this.padding = const EdgeInsets.all(22),
    this.onTap,
  });

  final Widget child;
  final Color color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LoopColors.border.withValues(alpha: 0.72)),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (onTap == null) {
      return card;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: card,
    );
  }
}
