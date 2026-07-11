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
import '../../../core/widgets/section_header.dart';
import 'cubit/home_dashboard_cubit.dart';
import 'cubit/home_dashboard_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeDashboardCubit>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      builder: (context, state) {
        if (state is! HomeDashboardLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final dashboard = state.dashboard;
        final latestTrack = dashboard.latestTrack;
        final strings = AppStrings.of(context);

        if (latestTrack == null) {
          return ShellPagePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dashboard.userName.isEmpty
                      ? strings.noCallsTitle
                      : '${strings.noCallsTitle}, ${dashboard.userName}',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  strings.noCallsDescription,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                LoopCard(
                  color: LoopColors.lightGreen,
                  onTap: () => context.go('/interview'),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.call_rounded,
                        color: LoopColors.brandGreen,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        strings.startFirstCall,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return ShellPagePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.homePreparingFor,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 4),
              Text(
                strings.goalLabel(dashboard.target),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              LoopCard(
                color: LoopColors.brandGreen,
                child: Row(
                  children: [
                    LevelCircle(
                      level: dashboard.generalLevel,
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
                            strings.generalLevel,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.generalLevelSummary,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white70),
                          ),
                          const SizedBox(height: 14),
                          DeltaBadge(value: latestTrack.delta),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: strings.streak,
                      value: strings.days(dashboard.streakDays),
                      color: LoopColors.lightGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: strings.loops,
                      value: '${dashboard.totalLoops}',
                      color: LoopColors.infoBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SectionHeader(
                title: strings.continueLabel,
                actionLabel: strings.seeLoops,
                onAction: () => context.go('/loops'),
              ),
              const SizedBox(height: 12),
              LoopCard(
                onTap: () => context.go('/interview'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${latestTrack.roleTitle} · ${latestTrack.company}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        DeltaBadge(value: latestTrack.delta, compact: true),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.nextFocus(latestTrack.focus),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    MetricProgressBar(
                      label: strings.cyclesCompleted(
                        latestTrack.cyclesCompleted,
                      ),
                      value: latestTrack.progress,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SectionHeader(title: strings.criteriaEvolution),
              const SizedBox(height: 12),
              LoopCard(
                child: Column(
                  children: [
                    for (final criterion in dashboard.criteria) ...[
                      MetricProgressBar(
                        label: strings.criterion(criterion.name),
                        value: criterion.score,
                        trailing: criterion.trend,
                      ),
                      if (criterion != dashboard.criteria.last)
                        const SizedBox(height: 18),
                    ],
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      color: color,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
