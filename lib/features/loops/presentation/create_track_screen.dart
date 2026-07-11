import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../../core/settings/cubit/settings_cubit.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../data/repositories/firestore_tracks_repository.dart';
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

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  Future<void> _createTrack() async {
    final strings = AppStrings.of(context);
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

  Future<void> _generateWithAi() async {
    final strings = AppStrings.of(context);
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/loops'),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          title: Text(strings.createTrackTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: strings.createTrackPasteTab),
              Tab(text: strings.createTrackAiTab),
            ],
          ),
        ),
        body: TabBarView(
          children: [
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
