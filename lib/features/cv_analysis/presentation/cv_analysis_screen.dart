import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/level_circle.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/metric_progress_bar.dart';
import '../../../core/widgets/section_header.dart';
import 'cubit/cv_analysis_cubit.dart';
import 'cubit/cv_analysis_state.dart';

class CvAnalysisScreen extends StatelessWidget {
  const CvAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CvAnalysisCubit, CvAnalysisState>(
      builder: (context, state) {
        if (state is! CvAnalysisLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final analysis = state.analysis;
        final strings = AppStrings.of(context);

        return ShellPagePadding(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.cvAnalysis,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                strings.cvDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              LoopCard(
                child: Row(
                  children: [
                    LevelCircle(
                      level: analysis.score / 20,
                      maxLevel: 5,
                      size: 112,
                      foregroundColor: LoopColors.brandGreen,
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strings.scoreCurrent(analysis.score),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            strings.lastAnalysis(analysis.lastAnalyzedLabel),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 14),
                          FilledButton(
                            onPressed: () {},
                            child: Text(strings.newScore),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SectionHeader(title: strings.breakdown),
              const SizedBox(height: 12),
              LoopCard(
                child: Column(
                  children: [
                    for (final criterion in analysis.criteria) ...[
                      MetricProgressBar(
                        label: strings.cvCriterion(criterion.name),
                        value: criterion.score,
                        color: LoopColors.brandGreen,
                      ),
                      if (criterion != analysis.criteria.last)
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
                            strings.matchVsJob,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${analysis.matchScore}%',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.cvSummary(analysis.matchSummary),
                      style: Theme.of(context).textTheme.bodyMedium,
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
