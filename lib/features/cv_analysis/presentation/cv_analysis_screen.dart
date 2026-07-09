import 'package:flutter/material.dart';

import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/level_circle.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/metric_progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../mock_data/loop_mock_data.dart';

class CvAnalysisScreen extends StatelessWidget {
  const CvAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShellPagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CV Analysis', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 8),
          Text(
            'Tu hoja de vida medida contra claridad, impacto y match con ofertas.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 22),
          LoopCard(
            child: Row(
              children: [
                const LevelCircle(
                  level: 4.1,
                  maxLevel: 5,
                  size: 112,
                  foregroundColor: LoopColors.brandGreen,
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Score actual: 82/100',
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 6),
                      Text(
                        'Ultimo analisis: hoy',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Nuevo score'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const SectionHeader(title: 'Desglose'),
          const SizedBox(height: 12),
          LoopCard(
            child: Column(
              children: [
                for (final criterion in LoopMockData.cvCriteria) ...[
                  MetricProgressBar(
                    label: criterion.name,
                    value: criterion.score,
                    color: LoopColors.brandGreen,
                  ),
                  if (criterion != LoopMockData.cvCriteria.last)
                    const SizedBox(height: 18),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          LoopCard(
            color: LoopColors.infoBlue,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.work_outline_rounded,
                      color: LoopColors.brandGreen,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Match vs oferta',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text('76%', style: Theme.of(context).textTheme.titleMedium),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'Tu CV ya comunica experiencia mobile fuerte. Falta cuantificar impacto en performance, calidad y liderazgo tecnico.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
