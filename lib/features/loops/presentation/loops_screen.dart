import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/delta_badge.dart';
import '../../../core/widgets/level_circle.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/metric_progress_bar.dart';
import 'cubit/loops_cubit.dart';
import 'cubit/loops_state.dart';

class LoopsScreen extends StatelessWidget {
  const LoopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoopsCubit, LoopsState>(
      builder: (context, state) {
        if (state is! LoopsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final tracks = state.tracks;

        return ShellPagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trayectos', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Cada loop mide tu progreso frente a un puesto objetivo concreto.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          for (final track in tracks) ...[
            LoopCard(
              onTap: () => context.go('/interview'),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LevelCircle(level: track.level, size: 84),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                track.roleTitle,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            DeltaBadge(value: track.delta, compact: true),
                          ],
                        ),
                        Text(
                          track.company,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          track.focus,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 14),
                        MetricProgressBar(
                          label: '${track.cyclesCompleted} ciclos',
                          value: track.progress,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
          LoopCard(
            color: LoopColors.lightGreen,
            child: Row(
              children: [
                const Icon(Icons.add_circle_rounded, color: LoopColors.brandGreen),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Crear trayecto a medida pegando una descripción de oferta',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}
