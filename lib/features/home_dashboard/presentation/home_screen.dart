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
import '../../../core/widgets/skeleton.dart';
import '../../loops/domain/entities/loop_track.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  void _reload() => context.read<HomeDashboardCubit>().load();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeDashboardCubit, HomeDashboardState>(
      builder: (context, state) {
        final strings = AppStrings.of(context);

        if (state is HomeDashboardInitial) {
          return ShellPagePadding(child: _HomeLoading(strings: strings));
        }

        if (state is HomeDashboardError) {
          return ShellPagePadding(
            child: Center(child: Text(state.message)),
          );
        }

        if (state is! HomeDashboardLoaded) {
          return const SizedBox.shrink();
        }

        final dashboard = state.dashboard;
        final displayName = dashboard.userName.trim().isEmpty
            ? strings.homeDefaultUser
            : dashboard.userName.trim();

        if (!dashboard.hasTracks) {
          return RefreshIndicator(
            onRefresh: () async => _reload(),
            child: ShellPagePadding(
              child: _HomeEmpty(
                strings: strings,
                displayName: displayName,
                streak: dashboard.streakDays,
                onCreate: () => context.go('/loops/create'),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _reload(),
          child: ShellPagePadding(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.homeWelcome,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  displayName,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: LoopColors.brandGreen,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  strings.homeIntro,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 22),
                _LevelCard(
                  strings: strings,
                  level: dashboard.generalLevel,
                  hasMeasuredLevel: dashboard.hasMeasuredLevel,
                  delta: dashboard.latestTrack?.delta ?? 0,
                ),
                const SizedBox(height: 14),
                _StatsRow(
                  strings: strings,
                  streak: dashboard.streakDays,
                  loops: dashboard.totalLoops,
                  tracks: dashboard.totalTracks,
                ),
                const SizedBox(height: 24),
                if (dashboard.latestTrack != null) ...[
                  SectionHeader(
                    title: strings.homeLatestPractice,
                    actionLabel: strings.seeLoops,
                    onAction: () => context.go('/loops'),
                  ),
                  const SizedBox(height: 12),
                  _PracticeCard(
                    track: dashboard.latestTrack!,
                    strings: strings,
                  ),
                  const SizedBox(height: 12),
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
                      Text(
                        strings.homeNewLoopCta,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(height: 34, width: 180),
        const SizedBox(height: 8),
        const SkeletonBox(height: 34, width: 140),
        const SizedBox(height: 12),
        const SkeletonLine(height: 18),
        const SizedBox(height: 22),
        const _LevelCardSkeleton(),
        const SizedBox(height: 14),
        const _StatsRowSkeleton(),
        const SizedBox(height: 24),
        const SkeletonBox(height: 160, borderRadius: 18),
      ],
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty({
    required this.strings,
    required this.displayName,
    required this.streak,
    required this.onCreate,
  });

  final AppStrings strings;
  final String displayName;
  final int streak;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.homeWelcome,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 4),
        Text(
          displayName,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            color: LoopColors.brandGreen,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          strings.homeIntro,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 22),
        _LevelCard(strings: strings),
        const SizedBox(height: 14),
        _StatsRow(strings: strings, streak: streak, loops: 0, tracks: 0),
        const SizedBox(height: 24),
        LoopCard(
          color: LoopColors.brandGreen,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.homeCreateLoopTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.homeCreateLoopBody,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: LoopColors.brandGreen,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(strings.homeCreateLoopCta),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelCard extends StatelessWidget {
  const _LevelCard({
    required this.strings,
    this.level = 0,
    this.hasMeasuredLevel = false,
    this.delta = 0,
  });

  final AppStrings strings;
  final double level;
  final bool hasMeasuredLevel;
  final double delta;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (hasMeasuredLevel)
            LevelCircle(level: level, size: 72)
          else
            const _LevelEmptyRing(size: 72),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.homeLevelTitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: LoopColors.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasMeasuredLevel
                      ? level.toStringAsFixed(1)
                      : strings.homeLevelEmpty,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hasMeasuredLevel
                      ? strings.generalLevelSummary
                      : strings.homeLevelEmptyHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (hasMeasuredLevel) ...[
                  const SizedBox(height: 10),
                  DeltaBadge(value: delta),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelCardSkeleton extends StatelessWidget {
  const _LevelCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: const [
          SkeletonCircle(size: 72),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLine(width: 120, height: 14),
                SizedBox(height: 10),
                SkeletonLine(width: 160, height: 22),
                SizedBox(height: 8),
                SkeletonLine(width: 220, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.strings,
    this.streak = 0,
    this.loops = 0,
    this.tracks = 0,
  });

  final AppStrings strings;
  final int streak;
  final int loops;
  final int tracks;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: streak > 0
                ? Icons.local_fire_department_rounded
                : Icons.local_fire_department_outlined,
            iconColor: streak > 0 ? LoopColors.brandGreen : LoopColors.textMuted,
            value: '$streak',
            label: strings.homeStreakLabel,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.loop_rounded,
            value: '$loops',
            label: strings.homeLoopsLabel,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.adjust_rounded,
            value: '$tracks',
            label: strings.homeTracksLabel,
          ),
        ),
      ],
    );
  }
}

class _StatsRowSkeleton extends StatelessWidget {
  const _StatsRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _MiniStatCardSkeleton()),
        SizedBox(width: 10),
        Expanded(child: _MiniStatCardSkeleton()),
        SizedBox(width: 10),
        Expanded(child: _MiniStatCardSkeleton()),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor = LoopColors.textMuted,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                TextSpan(
                  text: ' $label',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCardSkeleton extends StatelessWidget {
  const _MiniStatCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          SkeletonCircle(size: 22),
          SizedBox(height: 10),
          SkeletonLine(width: 72, height: 20),
        ],
      ),
    );
  }
}

class _PracticeCard extends StatelessWidget {
  const _PracticeCard({required this.track, required this.strings});

  final LoopTrack track;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final route = track.prepCompleted
        ? '/interview?trackId=${track.id}&loopType=interview'
        : '/interview?trackId=${track.id}&loopType=prep';

    return LoopCard(
      onTap: () => context.go(route),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${track.roleTitle} · ${track.company}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              DeltaBadge(value: track.delta, compact: true),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            track.prepCompleted
                ? strings.trackPrepDone
                : strings.trackPrepPending,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Text(
            strings.nextFocus(track.focus),
            style: Theme.of(context).textTheme.bodyMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 14),
          MetricProgressBar(
            label: strings.cyclesCompleted(track.cyclesCompleted),
            value: track.progress,
          ),
        ],
      ),
    );
  }
}

class _LevelEmptyRing extends StatelessWidget {
  const _LevelEmptyRing({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    const dotOffsets = [
      Offset(0, -1),
      Offset(0.87, -0.5),
      Offset(0.87, 0.5),
      Offset(0, 1),
      Offset(-0.87, 0.5),
      Offset(-0.87, -0.5),
      Offset(0.43, 0.75),
      Offset(-0.43, 0.75),
    ];

    final radius = size * 0.34;
    final dotSize = size * 0.11;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: LoopColors.border,
                width: 2,
              ),
            ),
          ),
          for (final unit in dotOffsets)
            Transform.translate(
              offset: Offset(unit.dx * radius, unit.dy * radius),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  color: LoopColors.textMuted.withValues(alpha: 0.28),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Icon(
            Icons.insights_outlined,
            size: size * 0.28,
            color: LoopColors.textMuted.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
