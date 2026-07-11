import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/settings/cubit/settings_cubit.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../../onboarding/presentation/widgets/selection_card.dart';
import '../../profile/domain/repositories/profile_repository.dart';
import '../data/predefined_tracks_catalog.dart';
import '../data/repositories/firestore_tracks_repository.dart';
import '../domain/entities/predefined_track_template.dart';
import '../domain/repositories/tracks_repository.dart';

class CreateTrackScreen extends StatefulWidget {
  const CreateTrackScreen({super.key});

  @override
  State<CreateTrackScreen> createState() => _CreateTrackScreenState();
}

class _CreateTrackScreenState extends State<CreateTrackScreen> {
  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _aiInputController = TextEditingController();
  bool _loading = false;
  String? _error;
  String _goalId = '';
  bool _goalLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadGoal());
  }

  Future<void> _loadGoal() async {
    try {
      final profile = await context.read<ProfileRepository>().getProfile();
      if (!mounted) return;
      setState(() {
        _goalId = profile.target;
        _goalLoaded = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _goalLoaded = true);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  Future<void> _createTrack() async {
    final strings = AppStrings.read(context);
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    if (title.isEmpty || description.isEmpty) {
      setState(() => _error = strings.trackFormRequired);
      return;
    }
    await _persist(
      title: title,
      company: _companyController.text.trim(),
      jobDescription: description,
    );
  }

  Future<void> _createFromTemplate(PredefinedTrackTemplate template) async {
    await _persist(
      title: template.title,
      company: template.company,
      jobDescription: template.jobDescription,
    );
  }

  Future<void> _generateWithAi() async {
    final strings = AppStrings.read(context);
    final input = _aiInputController.text.trim();
    if (input.isEmpty) {
      setState(() => _error = strings.trackAiRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<TracksRepository>();
      if (repo is! FirestoreTracksRepository) {
        throw StateError(strings.trackAiUnavailable);
      }
      final language = context.read<SettingsCubit>().state.language;
      final generated = await repo.generateFromDescription(
        input: input,
        language: language,
      );
      if (!mounted) return;
      await _persist(
        title: generated.title.isEmpty ? strings.trackUntitled : generated.title,
        company: generated.company,
        jobDescription: generated.jobDescription,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _persist({
    required String title,
    required String company,
    required String jobDescription,
  }) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final track = await context.read<TracksRepository>().createTrack(
        title: title,
        company: company,
        jobDescription: jobDescription,
      );
      if (!mounted) return;
      context.go('/interview?trackId=${track.id}&loopType=prep');
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final language = context.watch<SettingsCubit>().state.language;
    final templates = _goalLoaded
        ? PredefinedTracksCatalog.forGoal(_goalId, language)
        : const <PredefinedTrackTemplate>[];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/loops'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(strings.createTrackTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: strings.createTrackSuggestedTab),
              Tab(text: strings.createTrackPasteTab),
              Tab(text: strings.createTrackAiTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _SuggestedTab(
              strings: strings,
              goalId: _goalId,
              goalLoaded: _goalLoaded,
              templates: templates,
              loading: _loading,
              error: _error,
              onSelect: _createFromTemplate,
            ),
            _PasteTab(
              strings: strings,
              titleController: _titleController,
              companyController: _companyController,
              descriptionController: _descriptionController,
              loading: _loading,
              error: _error,
              onSubmit: _createTrack,
            ),
            _AiTab(
              strings: strings,
              inputController: _aiInputController,
              loading: _loading,
              error: _error,
              onGenerate: _generateWithAi,
            ),
          ],
        ),
      ),
    );
  }
}

class _SuggestedTab extends StatelessWidget {
  const _SuggestedTab({
    required this.strings,
    required this.goalId,
    required this.goalLoaded,
    required this.templates,
    required this.loading,
    required this.error,
    required this.onSelect,
  });

  final AppStrings strings;
  final String goalId;
  final bool goalLoaded;
  final List<PredefinedTrackTemplate> templates;
  final bool loading;
  final String? error;
  final ValueChanged<PredefinedTrackTemplate> onSelect;

  @override
  Widget build(BuildContext context) {
    if (!goalLoaded) {
      return const Center(child: CircularProgressIndicator());
    }

    if (templates.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          LoopCard(
            color: LoopColors.lightGreen,
            child: Text(strings.createTrackSuggestedEmpty),
          ),
        ],
      );
    }

    final goalLabel = strings.goalLabel(goalId);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          strings.createTrackSuggestedHint(goalLabel),
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        ...templates.map((template) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Opacity(
              opacity: loading ? 0.55 : 1,
              child: SelectionCard(
                selected: false,
                onTap: loading ? () {} : () => onSelect(template),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.title,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.company,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      template.jobDescription,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        if (error != null) ...[
          const SizedBox(height: 8),
          Text(error!, style: const TextStyle(color: LoopColors.danger)),
        ],
        if (loading) ...[
          const SizedBox(height: 12),
          const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ],
      ],
    );
  }
}

class _PasteTab extends StatelessWidget {
  const _PasteTab({
    required this.strings,
    required this.titleController,
    required this.companyController,
    required this.descriptionController,
    required this.loading,
    required this.error,
    required this.onSubmit,
  });

  final AppStrings strings;
  final TextEditingController titleController;
  final TextEditingController companyController;
  final TextEditingController descriptionController;
  final bool loading;
  final String? error;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(strings.createTrackPasteHint, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: strings.trackJobTitle),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: companyController,
          decoration: InputDecoration(labelText: strings.trackCompany),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: descriptionController,
          minLines: 6,
          maxLines: 10,
          decoration: InputDecoration(labelText: strings.trackJobDescription),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(error!, style: const TextStyle(color: LoopColors.danger)),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: loading ? null : onSubmit,
          child: loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(strings.createTrackCta),
        ),
      ],
    );
  }
}

class _AiTab extends StatelessWidget {
  const _AiTab({
    required this.strings,
    required this.inputController,
    required this.loading,
    required this.error,
    required this.onGenerate,
  });

  final AppStrings strings;
  final TextEditingController inputController;
  final bool loading;
  final String? error;
  final VoidCallback onGenerate;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        LoopCard(
          color: LoopColors.lightGreen,
          child: Text(strings.createTrackAiHint),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: inputController,
          minLines: 5,
          maxLines: 8,
          decoration: InputDecoration(labelText: strings.createTrackAiInput),
        ),
        if (error != null) ...[
          const SizedBox(height: 12),
          Text(error!, style: const TextStyle(color: LoopColors.danger)),
        ],
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: loading ? null : onGenerate,
          icon: const Icon(Icons.auto_awesome_rounded),
          label: Text(strings.createTrackAiGenerate),
        ),
      ],
    );
  }
}
