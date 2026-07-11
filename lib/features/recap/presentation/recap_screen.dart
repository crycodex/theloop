import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/delta_badge.dart';
import '../../../core/widgets/level_circle.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/metric_progress_bar.dart';
import '../domain/entities/session_recap.dart';
import 'cubit/recap_cubit.dart';
import 'cubit/recap_state.dart';

class RecapScreen extends StatefulWidget {
  const RecapScreen({super.key, this.loopId});

  final String? loopId;

  @override
  State<RecapScreen> createState() => _RecapScreenState();
}

class _RecapScreenState extends State<RecapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecapCubit>().load(widget.loopId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecapCubit, RecapState>(
      builder: (context, state) {
        if (state is RecapEmpty || state is RecapError) {
          return Scaffold(
            backgroundColor: LoopColors.surface,
            appBar: AppBar(
              leading: IconButton(
                onPressed: () => context.go('/'),
                icon: const Icon(Icons.close_rounded),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state is RecapError
                      ? state.message
                      : 'Todavía no hay un reporte disponible.',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        if (state is! RecapLoaded) {
          return const Scaffold(
            backgroundColor: LoopColors.surface,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final recap = state.recap;
        final strings = AppStrings.of(context);

        return Scaffold(
          backgroundColor: LoopColors.surface,
          appBar: AppBar(
            title: Text(strings.recapTitle),
            leading: IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.close_rounded),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LoopCard(
                  color: LoopColors.brandGreen,
                  child: Row(
                    children: [
                      LevelCircle(
                        level: recap.level,
                        foregroundColor: LoopColors.accentGreen,
                        backgroundColor: const Color(0x335B7D2E),
                        textColor: Colors.white,
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.recapText(recap.title),
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.recapText(recap.summary),
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: Colors.white70),
                            ),
                            const SizedBox(height: 14),
                            DeltaBadge(value: recap.delta),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                LoopCard(
                  child: Column(
                    children: [
                      for (final criterion in recap.criteria) ...[
                        MetricProgressBar(
                          label: strings.criterion(criterion.name),
                          value: criterion.score,
                          trailing: criterion.trend,
                        ),
                        if (criterion != recap.criteria.last)
                          const SizedBox(height: 18),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: LoopCard(
                        color: LoopColors.lightGreen,
                        child: _Insight(
                          title: strings.strength,
                          body: strings.recapText(recap.strength),
                          icon: Icons.check_circle_rounded,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: LoopCard(
                        color: LoopColors.amber,
                        child: _Insight(
                          title: strings.improvement,
                          body: strings.recapText(recap.improvement),
                          icon: Icons.lightbulb_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                FilledButton(
                  onPressed: () => context.go(
                    '/interview?sourceLoopId=${recap.loopId}',
                  ),
                  child: Text(strings.practiceAgain),
                ),
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => _showTranscript(context, recap),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Text(strings.viewTranscript),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showTranscript(BuildContext context, SessionRecap recap) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.92,
        builder: (context, controller) => ListView.separated(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          itemCount: recap.transcript.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final turn = recap.transcript[index];
            final candidate = turn.role == 'candidate';
            return ListTile(
              tileColor: candidate
                  ? LoopColors.lightGreen
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(candidate ? 'Candidato' : 'Reclutador'),
              subtitle: Text(turn.text),
            );
          },
        ),
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight({required this.title, required this.body, required this.icon});

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: LoopColors.brandGreen),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(body, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}
