import 'package:flutter/material.dart';

import '../theme/loop_colors.dart';

class MetricProgressBar extends StatelessWidget {
  const MetricProgressBar({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.color = LoopColors.accentGreen,
  });

  final String label;
  final double value;
  final String? trailing;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final normalized = value.clamp(0, 1).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.labelLarge),
            ),
            Text(
              trailing ?? '${(normalized * 100).round()}%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: LoopColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: normalized,
            minHeight: 9,
            backgroundColor: LoopColors.border,
            color: color,
          ),
        ),
      ],
    );
  }
}
