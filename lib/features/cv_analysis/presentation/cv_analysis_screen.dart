import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/section_header.dart';

class CvAnalysisScreen extends StatelessWidget {
  const CvAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            color: LoopColors.lightGreen,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.description_outlined,
                  size: 56,
                  color: LoopColors.brandGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  strings.cvComingSoonTitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  strings.cvComingSoonBody,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.upload_file_rounded),
                  label: Text(strings.cvUploadCta),
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
                _PlaceholderMetric(label: strings.cvCriterionPlaceholder('Claridad')),
                const SizedBox(height: 18),
                _PlaceholderMetric(label: strings.cvCriterionPlaceholder('Impacto')),
                const SizedBox(height: 18),
                _PlaceholderMetric(label: strings.cvCriterionPlaceholder('Match ATS')),
              ],
            ),
          ),
          const SizedBox(height: 18),
          LoopCard(
            color: LoopColors.infoBlue.withValues(alpha: 0.12),
            child: Row(
              children: [
                const Icon(
                  Icons.work_outline_rounded,
                  color: LoopColors.brandGreen,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.cvMatchPlaceholder,
                    style: Theme.of(context).textTheme.bodyMedium,
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

class _PlaceholderMetric extends StatelessWidget {
  const _PlaceholderMetric({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: null,
            backgroundColor: LoopColors.textMuted.withValues(alpha: 0.12),
            color: LoopColors.textMuted.withValues(alpha: 0.2),
          ),
        ),
      ],
    );
  }
}
