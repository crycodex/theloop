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
                loading: false,
              ),
              const SizedBox(height: 14),
              _StatsRow(
                strings: strings,
                streak: dashboard.streakDays,
                loops: dashboard.totalLoops,
                tracks: dashboard.totalTracks,
                loading: false,
              ),
              const SizedBox(height: 24),
              SectionHeader(
                title: strings.homePracticesTitle,
                actionLabel: strings.seeLoops,
                onAction: () => context.go('/loops'),
              ),
              const SizedBox(height: 12),
              for (final track in dashboard.tracks) ...[
                _PracticeCard(track: track, strings: strings),
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
        _SkeletonBox(height: 34, width: 180),
        const SizedBox(height: 8),
        _SkeletonBox(height: 34, width: 140),
        const SizedBox(height: 12),
        _SkeletonBox(height: 18, width: double.infinity),
        const SizedBox(height: 22),
        _LevelCard(strings: strings, loading: true),
        const SizedBox(height: 14),
        _StatsRow(strings: strings, loading: true),
        const SizedBox(height: 24),
        _SkeletonBox(height: 120, width: double.infinity),
      ],
    );
  }
}

class _HomeEmpty extends StatelessWidget {
  const _HomeEmpty({
    required this.strings,
    required this.displayName,
    required this.onCreate,
  });

  final AppStrings strings;
  final String displayName;
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
        _LevelCard(strings: strings, loading: false),
        const SizedBox(height: 14),
        _StatsRow(strings: strings, streak: 0, loops: 0, tracks: 0),
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
    this.loading = false,
  });

  final AppStrings strings;
  final double level;
  final bool hasMeasuredLevel;
  final double delta;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          if (loading)
            const SizedBox(
              width: 72,
              height: 72,
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2.5),
              ),
            )
          else if (hasMeasuredLevel)
            LevelCircle(level: level, size: 72)
          else
            const _DottedLoader(),
          const SizedBox(width: 16),
          Expanded(
            child: loading
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      _SkeletonBox(height: 14, width: 120),
                      SizedBox(height: 10),
                      _SkeletonBox(height: 22, width: 160),
                      SizedBox(height: 8),
                      _SkeletonBox(height: 14, width: 220),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.homeLevelTitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        hasMeasuredLevel
                            ? level.toStringAsFixed(1)
                            : strings.homeLevelEmpty,
                        style: Theme.of(context).textTheme.titleLarge,
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.strings,
    this.streak = 0,
    this.loops = 0,
    this.tracks = 0,
    this.loading = false,
  });

  final AppStrings strings;
  final int streak;
  final int loops;
  final int tracks;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            icon: Icons.error_outline_rounded,
            value: loading ? null : '$streak',
            label: strings.homeStreakLabel,
            loading: loading,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.loop_rounded,
            value: loading ? null : '$loops',
            label: strings.homeLoopsLabel,
            loading: loading,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStatCard(
            icon: Icons.adjust_rounded,
            value: loading ? null : '$tracks',
            label: strings.homeTracksLabel,
            loading: loading,
          ),
        ),
      ],
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    this.value,
    this.loading = false,
  });

  final IconData icon;
  final String? value;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: LoopColors.textMuted),
          const SizedBox(height: 10),
          if (loading)
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            Text(
              '$value $label',
              style: Theme.of(context).textTheme.titleMedium,
            ),
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

class _DottedLoader extends StatelessWidget {
  const _DottedLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final offset in const [
            Offset(0, -18),
            Offset(17, -6),
            Offset(11, 15),
            Offset(-11, 15),
            Offset(-17, -6),
            Offset(0, 0),
            Offset(0, 12),
            Offset(12, 0),
          ])
            Transform.translate(
              offset: offset,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: LoopColors.textMuted.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.height, required this.width});

  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: LoopColors.textMuted.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
