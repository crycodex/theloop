import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/delta_badge.dart';
import '../../../core/widgets/level_circle.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/metric_progress_bar.dart';
import '../../../mock_data/loop_mock_data.dart';

class RecapScreen extends StatelessWidget {
  const RecapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoopColors.surface,
      appBar: AppBar(
        title: const Text('Reporte final'),
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
                  const LevelCircle(
                    level: 3.9,
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
                          'Buen avance',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tu respuesta fue más concreta y conectó mejor decisiones con resultados.',
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: LoopCard(
                    color: LoopColors.lightGreen,
                    child: _Insight(
                      title: 'Fortaleza',
                      body: 'Explicaste el contexto sin perder el foco del problema.',
                      icon: Icons.check_circle_rounded,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LoopCard(
                    color: LoopColors.amber,
                    child: _Insight(
                      title: 'Mejora',
                      body: 'Cierra con una métrica antes de pasar a aprendizajes.',
                      icon: Icons.lightbulb_rounded,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: () => context.go('/interview'),
              child: const Text('Practicar de nuevo'),
            ),
            const SizedBox(height: 10),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text('Ver transcripción'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Insight extends StatelessWidget {
  const _Insight({
    required this.title,
    required this.body,
    required this.icon,
  });

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
