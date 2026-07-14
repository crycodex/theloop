import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../domain/entities/roadmap.dart';
import 'cubit/roadmap_cubit.dart';
import 'cubit/roadmap_state.dart';

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
          BlocBuilder<RoadmapCubit, RoadmapState>(
            builder: (context, state) {
              return switch (state) {
                RoadmapLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                RoadmapEmpty() => _EmptyView(strings: strings),
                RoadmapGenerating() => _GeneratingView(strings: strings),
                RoadmapError(:final message) => _ErrorView(
                    strings: strings,
                    message: message,
                  ),
                RoadmapLoaded(:final roadmap) => _LoadedView(
                    strings: strings,
                    roadmap: roadmap,
                  ),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.roadmapEmptyBody,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        LoopCard(
          color: LoopColors.lightGreen,
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.account_tree_outlined,
                size: 56,
                color: LoopColors.brandGreen,
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.read<RoadmapCubit>().generate(),
                icon: const Icon(Icons.auto_awesome_rounded),
                label: Text(strings.roadmapGenerateCta),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GeneratingView extends StatelessWidget {
  const _GeneratingView({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: LoopCard(
        color: LoopColors.lightGreen,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              strings.roadmapGeneratingLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.strings, required this.message});

  final AppStrings strings;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: LoopCard(
        color: LoopColors.danger.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: LoopColors.danger,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.read<RoadmapCubit>().generate(),
              child: Text(strings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({required this.strings, required this.roadmap});

  final AppStrings strings;
  final Roadmap roadmap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                strings.roadmapDescription(roadmap.target),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            TextButton.icon(
              onPressed: () => context.read<RoadmapCubit>().generate(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(strings.roadmapRegenerateCta),
            ),
          ],
        ),
        const SizedBox(height: 14),
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
                  roadmap.finalGoal,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        for (var index = 0; index < roadmap.steps.length; index++)
          _RoadmapStepTile(
            strings: strings,
            step: roadmap.steps[index],
            isLast: index == roadmap.steps.length - 1,
          ),
      ],
    );
  }
}

class _RoadmapStepTile extends StatelessWidget {
  const _RoadmapStepTile({
    required this.strings,
    required this.step,
    required this.isLast,
  });

  final AppStrings strings;
  final RoadmapStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCurrent = step.state == RoadmapStepState.current;
    final isCompleted = step.state == RoadmapStepState.completed;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isCurrent || isCompleted
                    ? LoopColors.accentGreen
                    : LoopColors.border,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_rounded
                    : isCurrent
                        ? Icons.play_arrow_rounded
                        : Icons.lock_rounded,
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          step.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      if (step.category.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: LoopColors.accentGreen.withValues(
                              alpha: 0.2,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            step.category,
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                  if (isCurrent) ...[
                    if (step.guide.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        step.guide,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                    if (step.tips.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        strings.roadmapTipsTitle,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 6),
                      for (final tip in step.tips)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 3),
                                child: Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 16,
                                  color: LoopColors.brandGreen,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style:
                                      Theme.of(context).textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
