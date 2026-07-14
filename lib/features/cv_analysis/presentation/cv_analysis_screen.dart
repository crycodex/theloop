import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../loops/domain/entities/interview_track.dart';
import '../domain/entities/cv_analysis.dart';
import 'cubit/cv_analysis_cubit.dart';
import 'cubit/cv_analysis_state.dart';

class CvAnalysisScreen extends StatefulWidget {
  const CvAnalysisScreen({super.key});

  @override
  State<CvAnalysisScreen> createState() => _CvAnalysisScreenState();
}

class _CvAnalysisScreenState extends State<CvAnalysisScreen> {
  PlatformFile? _pickedFile;
  String? _selectedTrackId;
  bool _showForm = false;
  String? _localError;

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    final file = result?.files.firstOrNull;
    if (file == null || file.bytes == null) return;
    setState(() {
      _pickedFile = file;
      _localError = null;
    });
  }

  void _analyze() {
    final strings = AppStrings.read(context);
    final bytes = _pickedFile?.bytes;
    if (bytes == null) {
      setState(() => _localError = strings.cvNoFileError);
      return;
    }
    setState(() {
      _showForm = false;
      _localError = null;
    });
    context.read<CvAnalysisCubit>().analyze(bytes, trackId: _selectedTrackId);
  }

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
          BlocBuilder<CvAnalysisCubit, CvAnalysisState>(
            builder: (context, state) {
              return switch (state) {
                CvAnalysisLoading() => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                CvAnalysisAnalyzing() => _UploadCard(
                    strings: strings,
                    tracks: const [],
                    pickedFile: _pickedFile,
                    selectedTrackId: _selectedTrackId,
                    analyzing: true,
                    onPickPdf: null,
                    onTrackChanged: null,
                    onAnalyze: null,
                  ),
                CvAnalysisEmpty(:final tracks) => _buildForm(strings, tracks),
                CvAnalysisError(:final message, :final tracks) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ErrorBanner(message: message),
                      const SizedBox(height: 14),
                      _buildForm(strings, tracks),
                    ],
                  ),
                CvAnalysisLoaded(:final analysis, :final tracks) => _showForm
                    ? _buildForm(strings, tracks)
                    : _ResultView(
                        strings: strings,
                        analysis: analysis,
                        onReanalyze: () => setState(() => _showForm = true),
                      ),
              };
            },
          ),
        ],
      ),
    );
  }

  Widget _buildForm(AppStrings strings, List<InterviewTrack> tracks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_localError != null) ...[
          _ErrorBanner(message: _localError!),
          const SizedBox(height: 14),
        ],
        _UploadCard(
          strings: strings,
          tracks: tracks,
          pickedFile: _pickedFile,
          selectedTrackId: _selectedTrackId,
          analyzing: false,
          onPickPdf: _pickPdf,
          onTrackChanged: (value) => setState(() => _selectedTrackId = value),
          onAnalyze: _analyze,
        ),
      ],
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.strings,
    required this.tracks,
    required this.pickedFile,
    required this.selectedTrackId,
    required this.analyzing,
    required this.onPickPdf,
    required this.onTrackChanged,
    required this.onAnalyze,
  });

  final AppStrings strings;
  final List<InterviewTrack> tracks;
  final PlatformFile? pickedFile;
  final String? selectedTrackId;
  final bool analyzing;
  final VoidCallback? onPickPdf;
  final ValueChanged<String?>? onTrackChanged;
  final VoidCallback? onAnalyze;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      color: LoopColors.lightGreen,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.description_outlined,
            size: 56,
            color: LoopColors.brandGreen,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onPickPdf,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(
              pickedFile?.name ?? strings.cvPickPdfCta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (tracks.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              strings.cvSelectTrackLabel,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String?>(
              initialValue: selectedTrackId,
              isExpanded: true,
              onChanged: onTrackChanged,
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(strings.cvNoTrackOption),
                ),
                for (final track in tracks)
                  DropdownMenuItem<String?>(
                    value: track.id,
                    child: Text(
                      track.company.isEmpty
                          ? track.title
                          : '${track.title} · ${track.company}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: analyzing ? null : onAnalyze,
            icon: analyzing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome_rounded),
            label: Text(
              analyzing ? strings.cvAnalyzingLabel : strings.cvAnalyzeCta,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.strings,
    required this.analysis,
    required this.onReanalyze,
  });

  final AppStrings strings;
  final CvAnalysis analysis;
  final VoidCallback onReanalyze;

  @override
  Widget build(BuildContext context) {
    final date = analysis.analyzedAt;
    final dateLabel =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LoopCard(
          color: LoopColors.brandGreen,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${analysis.score}',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6, left: 4),
                    child: Text(
                      '/100',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: LoopColors.accentGreen),
                    ),
                  ),
                  const Spacer(),
                  if (analysis.qualification.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LoopColors.accentGreen.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        analysis.qualification,
                        style: Theme.of(context)
                            .textTheme
                            .labelLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (analysis.summary.isNotEmpty)
                Text(
                  analysis.summary,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white.withValues(alpha: 0.85)),
                ),
              const SizedBox(height: 8),
              Text(
                strings.lastAnalysis(dateLabel),
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white.withValues(alpha: 0.6)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(child: SectionHeader(title: strings.breakdown)),
            TextButton.icon(
              onPressed: onReanalyze,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(strings.cvReanalyzeCta),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LoopCard(
          child: Column(
            children: [
              for (var i = 0; i < analysis.criteria.length; i++) ...[
                if (i > 0) const SizedBox(height: 18),
                _CriterionMetric(criterion: analysis.criteria[i]),
              ],
            ],
          ),
        ),
        if (analysis.matchScore != null) ...[
          const SizedBox(height: 28),
          SectionHeader(title: strings.matchVsJob),
          const SizedBox(height: 12),
          LoopCard(
            color: LoopColors.infoBlue.withValues(alpha: 0.6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.work_outline_rounded,
                      color: LoopColors.brandGreen,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        analysis.matchTrackTitle ?? '',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      '${analysis.matchScore}%',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: LoopColors.brandGreen),
                    ),
                  ],
                ),
                if ((analysis.matchSummary ?? '').isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    analysis.matchSummary!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _CriterionMetric extends StatelessWidget {
  const _CriterionMetric({required this.criterion});

  final CvCriterion criterion;

  Color get _barColor {
    if (criterion.score >= 0.75) return LoopColors.accentGreen;
    if (criterion.score >= 0.5) return Colors.amber.shade600;
    return LoopColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                criterion.name,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Text(
              '${(criterion.score * 100).round()}%',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: criterion.score,
            backgroundColor: LoopColors.textMuted.withValues(alpha: 0.12),
            color: _barColor,
          ),
        ),
        if (criterion.feedback.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            criterion.feedback,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: LoopColors.textMuted),
          ),
        ],
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return LoopCard(
      color: LoopColors.danger.withValues(alpha: 0.1),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: LoopColors.danger),
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
    );
  }
}
