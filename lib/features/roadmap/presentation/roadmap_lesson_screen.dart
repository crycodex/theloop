import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../domain/entities/roadmap.dart';
import 'cubit/roadmap_cubit.dart';
import 'cubit/roadmap_state.dart';

class RoadmapLessonScreen extends StatelessWidget {
  const RoadmapLessonScreen({super.key, required this.stepId});

  final String stepId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoadmapCubit, RoadmapState>(
      builder: (context, state) {
        final step = state is RoadmapLoaded
            ? state.roadmap.stepById(stepId)
            : null;
        if (step == null || !step.hasLesson) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return _LessonFlow(step: step);
      },
    );
  }
}

enum _LessonPhase { reading, quiz, done }

class _LessonFlow extends StatefulWidget {
  const _LessonFlow({required this.step});

  final RoadmapStep step;

  @override
  State<_LessonFlow> createState() => _LessonFlowState();
}

class _LessonFlowState extends State<_LessonFlow> {
  _LessonPhase _phase = _LessonPhase.reading;
  int _questionIndex = 0;
  int? _selectedOption;
  bool _answered = false;
  int _correctCount = 0;
  bool _saving = false;

  RoadmapLesson get _lesson => widget.step.lesson!;

  QuizQuestion get _question => _lesson.quiz[_questionIndex];

  void _startQuiz() {
    if (_lesson.quiz.isEmpty) {
      setState(() => _phase = _LessonPhase.done);
      return;
    }
    setState(() => _phase = _LessonPhase.quiz);
  }

  void _checkAnswer() {
    if (_selectedOption == null) return;
    setState(() {
      _answered = true;
      if (_selectedOption == _question.correctIndex) _correctCount++;
    });
  }

  void _nextQuestion() {
    if (_questionIndex + 1 >= _lesson.quiz.length) {
      setState(() => _phase = _LessonPhase.done);
      return;
    }
    setState(() {
      _questionIndex++;
      _selectedOption = null;
      _answered = false;
    });
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    await context.read<RoadmapCubit>().completeStep(widget.step.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.step.title, maxLines: 1),
      ),
      body: SafeArea(
        child: switch (_phase) {
          _LessonPhase.reading => _ReadingView(
              step: widget.step,
              strings: strings,
              onContinue: _startQuiz,
            ),
          _LessonPhase.quiz => _QuizView(
              strings: strings,
              question: _question,
              questionNumber: _questionIndex + 1,
              totalQuestions: _lesson.quiz.length,
              selectedOption: _selectedOption,
              answered: _answered,
              onSelect: (index) => setState(() => _selectedOption = index),
              onCheck: _checkAnswer,
              onContinue: _nextQuestion,
            ),
          _LessonPhase.done => _DoneView(
              strings: strings,
              correctCount: _correctCount,
              totalQuestions: _lesson.quiz.length,
              saving: _saving,
              onFinish: _finish,
            ),
        },
      ),
    );
  }
}

class _ReadingView extends StatelessWidget {
  const _ReadingView({
    required this.step,
    required this.strings,
    required this.onContinue,
  });

  final RoadmapStep step;
  final AppStrings strings;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final lesson = step.lesson!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        if (step.guide.isNotEmpty)
          Text(step.guide, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 16),
        for (final section in lesson.sections) ...[
          LoopCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  section.body,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        if (step.tips.isNotEmpty)
          LoopCard(
            color: LoopColors.lightGreen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
            ),
          ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onContinue,
          icon: const Icon(Icons.quiz_rounded),
          label: Text(strings.roadmapLessonStartQuizCta),
        ),
      ],
    );
  }
}

class _QuizView extends StatelessWidget {
  const _QuizView({
    required this.strings,
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedOption,
    required this.answered,
    required this.onSelect,
    required this.onCheck,
    required this.onContinue,
  });

  final AppStrings strings;
  final QuizQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedOption;
  final bool answered;
  final ValueChanged<int> onSelect;
  final VoidCallback onCheck;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final isCorrect = selectedOption == question.correctIndex;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Text(
          strings.roadmapQuestionOf(questionNumber, totalQuestions),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: questionNumber / totalQuestions,
          minHeight: 6,
          borderRadius: BorderRadius.circular(999),
          color: LoopColors.accentGreen,
          backgroundColor: LoopColors.border,
        ),
        const SizedBox(height: 20),
        Text(question.question, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        for (var i = 0; i < question.options.length; i++) ...[
          _OptionCard(
            label: question.options[i],
            selected: selectedOption == i,
            answered: answered,
            isCorrectOption: i == question.correctIndex,
            onTap: answered ? null : () => onSelect(i),
          ),
          const SizedBox(height: 10),
        ],
        if (answered) ...[
          const SizedBox(height: 8),
          LoopCard(
            color: isCorrect
                ? LoopColors.lightGreen
                : LoopColors.danger.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect
                      ? strings.roadmapQuizCorrect
                      : strings.roadmapQuizIncorrect,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (question.explanation.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    question.explanation,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: answered
              ? onContinue
              : selectedOption == null
                  ? null
                  : onCheck,
          child: Text(
            answered ? strings.roadmapQuizContinue : strings.roadmapQuizCheck,
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.answered,
    required this.isCorrectOption,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool answered;
  final bool isCorrectOption;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color? color;
    if (answered && isCorrectOption) {
      color = LoopColors.lightGreen;
    } else if (answered && selected && !isCorrectOption) {
      color = LoopColors.danger.withValues(alpha: 0.1);
    } else if (selected) {
      color = LoopColors.accentGreen.withValues(alpha: 0.2);
    }

    return LoopCard(
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            answered && isCorrectOption
                ? Icons.check_circle_rounded
                : answered && selected && !isCorrectOption
                    ? Icons.cancel_rounded
                    : selected
                        ? Icons.radio_button_checked_rounded
                        : Icons.radio_button_off_rounded,
            size: 20,
            color: answered && selected && !isCorrectOption
                ? LoopColors.danger
                : LoopColors.brandGreen,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DoneView extends StatelessWidget {
  const _DoneView({
    required this.strings,
    required this.correctCount,
    required this.totalQuestions,
    required this.saving,
    required this.onFinish,
  });

  final AppStrings strings;
  final int correctCount;
  final int totalQuestions;
  final bool saving;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.emoji_events_rounded,
            size: 64,
            color: LoopColors.accentGreen,
          ),
          const SizedBox(height: 16),
          Text(
            strings.roadmapLessonDoneTitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (totalQuestions > 0) ...[
            const SizedBox(height: 8),
            Text(
              strings.roadmapQuizScore(correctCount, totalQuestions),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          const SizedBox(height: 28),
          FilledButton(
            onPressed: saving ? null : onFinish,
            child: saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(strings.roadmapLessonFinishCta),
          ),
        ],
      ),
    );
  }
}
