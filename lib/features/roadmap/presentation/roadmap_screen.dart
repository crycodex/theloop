import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return ShellPagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.roadmap,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            strings.roadmapDescriptionPlaceholder,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          LoopCard(
            color: LoopColors.brandGreen,
            child: Row(
              children: [
                const Icon(
                  Icons.flag_rounded,
                  color: LoopColors.accentGreen,
                  size: 34,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    strings.roadmapGoalPlaceholder,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          LoopCard(
            color: LoopColors.lightGreen,
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  color: LoopColors.brandGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.roadmapComingSoonBody,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          for (var index = 0; index < 4; index++)
            _RoadmapStepPlaceholder(
              title: strings.roadmapStepPlaceholder(index + 1),
              isLast: index == 3,
              isCurrent: index == 1,
            ),
        ],
      ),
    );
  }
}

class _RoadmapStepPlaceholder extends StatelessWidget {
  const _RoadmapStepPlaceholder({
    required this.title,
    required this.isLast,
    required this.isCurrent,
  });

  final String title;
  final bool isLast;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isCurrent
                    ? LoopColors.accentGreen
                    : LoopColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCurrent ? Icons.play_arrow_rounded : Icons.lock_rounded,
                size: 20,
                color: LoopColors.brandGreen,
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 76, color: LoopColors.border),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: LoopCard(
              color: isCurrent
                  ? LoopColors.lightGreen
                  : LoopColors.surfaceElevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 6,
                      value: isCurrent ? null : 0,
                      backgroundColor:
                          LoopColors.textMuted.withValues(alpha: 0.12),
                      color: isCurrent
                          ? LoopColors.brandGreen.withValues(alpha: 0.35)
                          : LoopColors.textMuted.withValues(alpha: 0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
