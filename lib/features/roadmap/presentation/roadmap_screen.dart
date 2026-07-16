import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/level_circle.dart';
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
                RoadmapLoaded() => _LoadedView(strings: strings, state: state),
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
  const _LoadedView({required this.strings, required this.state});

  final AppStrings strings;
  final RoadmapLoaded state;

  @override
  Widget build(BuildContext context) {
    final roadmap = state.roadmap;
    final completedCount = roadmap.steps
        .where((step) => step.state == RoadmapStepState.completed)
        .length;

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
            if (!roadmap.isCatalog)
              TextButton.icon(
                onPressed: () => context.read<RoadmapCubit>().generate(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(strings.roadmapRegenerateCta),
              ),
          ],
        ),
        const SizedBox(height: 14),
        _LevelHeaderCard(
          strings: strings,
          userLevel: state.userLevel,
          finalGoal: roadmap.finalGoal,
          progressLabel: strings.roadmapStepsProgress(
            completedCount,
            roadmap.steps.length,
          ),
        ),
        const SizedBox(height: 26),
        _RoadmapPath(strings: strings, steps: roadmap.steps),
      ],
    );
  }
}

class _LevelHeaderCard extends StatelessWidget {
  const _LevelHeaderCard({
    required this.strings,
    required this.userLevel,
    required this.finalGoal,
    required this.progressLabel,
  });

  final AppStrings strings;
  final double? userLevel;
  final String finalGoal;
  final String progressLabel;

  @override
  Widget build(BuildContext context) {
    final level = userLevel;
    return LoopCard(
      color: LoopColors.brandGreen,
      child: Row(
        children: [
          if (level != null)
            LevelCircle(
              level: level,
              size: 74,
              textColor: Colors.white,
            )
          else
            const Icon(
              Icons.phone_in_talk_rounded,
              color: LoopColors.accentGreen,
              size: 40,
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  level != null
                      ? strings.levelAchieved(level)
                      : strings.roadmapLevelPending,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  finalGoal,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.82),
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: LoopColors.accentGreen.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    progressLabel,
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall
                        ?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoadmapPath extends StatelessWidget {
  const _RoadmapPath({required this.strings, required this.steps});

  final AppStrings strings;
  final List<RoadmapStep> steps;

  /// Alineaciones horizontales que dibujan el camino en S, estilo Duolingo.
  static const _serpentine = [0.0, -0.6, -0.95, -0.6, 0.0, 0.6, 0.95, 0.6];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Align(
            alignment: Alignment(_serpentine[i % _serpentine.length], 0),
            child: Padding(
              padding: EdgeInsets.only(bottom: i == steps.length - 1 ? 0 : 22),
              child: _PathNode(strings: strings, step: steps[i]),
            ),
          ),
      ],
    );
  }
}

class _PathNode extends StatelessWidget {
  const _PathNode({required this.strings, required this.step});

  final AppStrings strings;
  final RoadmapStep step;

  bool get _isCurrent => step.state == RoadmapStepState.current;

  bool get _isCompleted => step.state == RoadmapStepState.completed;

  IconData get _icon {
    if (_isCompleted) return Icons.check_rounded;
    if (step.type == RoadmapStepType.call) return Icons.phone_in_talk_rounded;
    if (step.state == RoadmapStepState.locked) return Icons.lock_rounded;
    return Icons.menu_book_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final circleColor = _isCurrent || _isCompleted
        ? LoopColors.accentGreen
        : LoopColors.border;
    final iconColor = _isCurrent || _isCompleted
        ? LoopColors.brandGreen
        : LoopColors.textMuted;

    final circle = Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: circleColor,
        shape: BoxShape.circle,
        border: _isCurrent
            ? Border.all(color: LoopColors.brandGreen, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: _isCurrent || _isCompleted
                ? LoopColors.brandGreen.withValues(alpha: 0.35)
                : Colors.black.withValues(alpha: 0.12),
            offset: const Offset(0, 5),
            blurRadius: 0,
          ),
        ],
      ),
      child: Icon(_icon, size: 30, color: iconColor),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => _showStepSheet(context),
      child: SizedBox(
        width: 130,
        child: Column(
          children: [
            if (_isCurrent) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: LoopColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: LoopColors.accentGreen, width: 2),
                ),
                child: Text(
                  strings.roadmapStartBadge,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: LoopColors.brandGreen,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            Stack(
              clipBehavior: Clip.none,
              children: [
                circle,
                if (_isCompleted)
                  Positioned(
                    right: -4,
                    bottom: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFF7C948),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              step.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: step.state == RoadmapStepState.locked
                        ? LoopColors.textMuted
                        : null,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStepSheet(BuildContext context) {
    final cubit = context.read<RoadmapCubit>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => BlocProvider.value(
        value: cubit,
        child: _StepSheet(strings: strings, step: step),
      ),
    );
  }
}

class _StepSheet extends StatelessWidget {
  const _StepSheet({required this.strings, required this.step});

  final AppStrings strings;
  final RoadmapStep step;

  @override
  Widget build(BuildContext context) {
    final locked = step.state == RoadmapStepState.locked;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    step.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                if (step.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: LoopColors.accentGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      step.category,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ),
              ],
            ),
            if (locked) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 18,
                    color: LoopColors.textMuted,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.roadmapStepLocked,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ] else ...[
              if (step.guide.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  step.guide,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
              if (step.tips.isNotEmpty) ...[
                const SizedBox(height: 14),
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
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: _buildCta(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCta(BuildContext context) {
    if (step.type == RoadmapStepType.call) {
      return FilledButton.icon(
        onPressed: () {
          Navigator.of(context).pop();
          context.go('/loops');
        },
        icon: const Icon(Icons.phone_in_talk_rounded),
        label: Text(strings.roadmapStartCall),
      );
    }
    if (!step.hasLesson) return const SizedBox.shrink();
    final completed = step.state == RoadmapStepState.completed;
    return FilledButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        context.push('/roadmap/lesson/${step.id}');
      },
      icon: Icon(
        completed ? Icons.replay_rounded : Icons.play_arrow_rounded,
      ),
      label: Text(
        completed ? strings.roadmapReviewLesson : strings.roadmapStartLesson,
      ),
    );
  }
}
