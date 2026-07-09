import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    return BlocBuilder<RoadmapCubit, RoadmapState>(
      builder: (context, state) {
        if (state is! RoadmapLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final roadmap = state.roadmap;

        return ShellPagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ruta', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Preparación paso a paso para ${roadmap.target}.',
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
                    'Meta final: ${roadmap.finalGoal}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          for (var index = 0; index < roadmap.steps.length; index++)
            _RoadmapStepTile(
              step: roadmap.steps[index],
              isLast: index == roadmap.steps.length - 1,
            ),
        ],
      ),
    );
      },
    );
  }
}

class _RoadmapStepTile extends StatelessWidget {
  const _RoadmapStepTile({required this.step, required this.isLast});

  final RoadmapStep step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isCompleted = step.state == RoadmapStepState.completed;
    final isCurrent = step.state == RoadmapStepState.current;
    final icon = isCompleted
        ? Icons.check_rounded
        : isCurrent
            ? Icons.play_arrow_rounded
            : Icons.lock_rounded;
    final markerColor = isCompleted || isCurrent
        ? LoopColors.accentGreen
        : LoopColors.border;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(color: markerColor, shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: LoopColors.brandGreen),
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
              color: isCurrent ? LoopColors.lightGreen : LoopColors.surfaceElevated,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.category, style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 5),
                  Text(step.title, style: Theme.of(context).textTheme.titleMedium),
                  if (step.level != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Nivel logrado ${step.level!.toStringAsFixed(1)} de 5',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  if (isCurrent) ...[
                    const SizedBox(height: 14),
                    FilledButton(
                      onPressed: () => context.go('/interview'),
                      child: const Text('Practicar ahora'),
                    ),
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
