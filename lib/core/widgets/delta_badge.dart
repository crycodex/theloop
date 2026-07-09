import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';

class DeltaBadge extends StatelessWidget {
  const DeltaBadge({super.key, required this.value, this.compact = false});

  final double value;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0;
    final color = isPositive ? LoopColors.accentGreen : LoopColors.danger;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: color,
            size: compact ? 14 : 16,
          ),
          const SizedBox(width: 4),
          Text(
            '$sign${value.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontSize: compact ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
