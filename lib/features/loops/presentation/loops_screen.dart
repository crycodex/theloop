import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/delta_badge.dart';
import '../../../core/widgets/level_circle.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/metric_progress_bar.dart';
import 'cubit/loops_cubit.dart';
import 'cubit/loops_state.dart';

class LoopsScreen extends StatefulWidget {
  const LoopsScreen({super.key});

  @override
  State<LoopsScreen> createState() => _LoopsScreenState();
}

class _LoopsScreenState extends State<LoopsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoopsCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoopsCubit, LoopsState>(
      builder: (context, state) {
        if (state is! LoopsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final tracks = state.tracks;
        final strings = AppStrings.of(context);

        return ShellPagePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.tracks,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                strings.tracksDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              if (tracks.isEmpty)
                LoopCard(
                  color: LoopColors.lightGreen,
                  onTap: () => context.go('/loops/create'),
                  child: Text(strings.noCallsDescription),
                ),
              for (final track in tracks) ...[
                LoopCard(
                  onTap: () {
                    final route = track.prepCompleted
                        ? '/interview?trackId=${track.id}&loopType=interview'
                        : '/interview?trackId=${track.id}&loopType=prep';
                    context.go(route);
                  },
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleMedium,
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
                              track.prepCompleted
                                  ? strings.trackPrepDone
                                  : strings.trackPrepPending,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.trackFocus(track.focus),
                              style: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.copyWith(fontSize: 14),
                            ),
                            const SizedBox(height: 14),
                            MetricProgressBar(
                              label: strings.cycles(track.cyclesCompleted),
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
                onTap: () => context.go('/loops/create'),
                child: Row(
                  children: [
                    const Icon(
                      Icons.add_circle_rounded,
                      color: LoopColors.brandGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        strings.createCustomTrack,
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
