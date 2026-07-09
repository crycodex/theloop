import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/delta_badge.dart';
import '../../../core/widgets/level_circle.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/metric_progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../mock_data/loop_mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final latestTrack = LoopMockData.tracks.first;

    return ShellPagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tu preparación para', style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(LoopMockData.target, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 24),
          LoopCard(
            color: LoopColors.brandGreen,
            child: Row(
              children: [
                const LevelCircle(
                  level: LoopMockData.generalLevel,
                  foregroundColor: LoopColors.accentGreen,
                  backgroundColor: Color(0x335B7D2E),
                  textColor: Colors.white,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nivel general',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Listo para sostener una entrevista conductual exigente, con oportunidad de profundizar resultados.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const DeltaBadge(value: 0.4),
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
                  label: 'Racha',
                  value: '${LoopMockData.streakDays} dias',
                  color: LoopColors.lightGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Loops',
                  value: '${LoopMockData.totalLoops}',
                  color: LoopColors.infoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SectionHeader(
            title: 'Continuar',
            actionLabel: 'Ver loops',
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
                  'Siguiente foco: ${latestTrack.focus}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                MetricProgressBar(
                  label: '${latestTrack.cyclesCompleted} ciclos completados',
                  value: latestTrack.progress,
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Evolución por criterio'),
          const SizedBox(height: 12),
          LoopCard(
            child: Column(
              children: [
                for (final criterion in LoopMockData.criteria) ...[
                  MetricProgressBar(
                    label: criterion.name,
                    value: criterion.score,
                    trailing: criterion.trend,
                  ),
                  if (criterion != LoopMockData.criteria.last)
                    const SizedBox(height: 18),
                ],
              ],
            ),
          ),
        ],
      ),
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
