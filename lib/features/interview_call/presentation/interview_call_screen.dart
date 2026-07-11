import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import '../../loops/domain/entities/interview_track.dart';
import '../../home_dashboard/presentation/cubit/home_dashboard_cubit.dart';
import 'cubit/interview_call_cubit.dart';
import 'cubit/interview_call_state.dart';

class InterviewCallScreen extends StatefulWidget {
  const InterviewCallScreen({
    super.key,
    this.sourceLoopId,
    this.trackId,
    this.loopType = 'interview',
  });

  final String? sourceLoopId;
  final String? trackId;
  final String loopType;

  @override
  State<InterviewCallScreen> createState() => _InterviewCallScreenState();
}

class _InterviewCallScreenState extends State<InterviewCallScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InterviewCallCubit>().start(
        sourceLoopId: widget.sourceLoopId,
        trackId: widget.trackId,
        loopType: widget.loopType == 'prep' ? LoopType.prep : LoopType.interview,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InterviewCallCubit, InterviewCallState>(
      listenWhen: (previous, current) =>
          previous.transcript.length != current.transcript.length,
      listener: (_, _) => _scrollToEnd(),
      builder: (context, state) {
        final strings = AppStrings.of(context);
        final busy =
            state.phase == InterviewCallPhase.connecting ||
            state.phase == InterviewCallPhase.ending;

        return Scaffold(
          backgroundColor: LoopColors.surfaceBlack,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      _LiveBadge(
                        timerLabel: state.timerLabel,
                        strings: strings,
                        isPrep: state.isPrep,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: busy
                            ? null
                            : () async {
                                await context
                                    .read<InterviewCallCubit>()
                                    .cancel();
                                if (context.mounted) _goHome(context);
                              },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _Orb(speaking: state.isAiSpeaking),
                  const SizedBox(height: 18),
                  Text(
                    switch (state.phase) {
                      InterviewCallPhase.connecting =>
                        strings.connectingCall,
                      InterviewCallPhase.ending => state.isPrep
                          ? strings.preparingPrep
                          : strings.preparingReport,
                      InterviewCallPhase.error =>
                        state.errorMessage ?? strings.authErrorUnknown,
                      _ when state.isAiSpeaking => strings.recruiterSpeaking,
                      _ => strings.recruiterListening,
                    },
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: state.transcript.isEmpty
                        ? Center(
                            child: busy
                                ? const CircularProgressIndicator(
                                    color: LoopColors.accentGreen,
                                  )
                                : const SizedBox.shrink(),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: state.transcript.length,
                            itemBuilder: (context, index) {
                              final turn = state.transcript[index];
                              final candidate =
                                  turn.speaker.name == 'candidate';
                              return Align(
                                alignment: candidate
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    maxWidth: 310,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: candidate
                                        ? LoopColors.accentGreen
                                        : Colors.white12,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    turn.text,
                                    style: TextStyle(
                                      color: candidate
                                          ? LoopColors.brandGreen
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (state.phase == InterviewCallPhase.error)
                    FilledButton.icon(
                      onPressed: () => context
                          .read<InterviewCallCubit>()
                          .start(sourceLoopId: widget.sourceLoopId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: Text(strings.retry),
                    )
                  else
                    Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CallControl(
                        icon: state.isMicEnabled
                            ? Icons.mic_rounded
                            : Icons.mic_off_rounded,
                        label: state.isMicEnabled ? strings.mic : strings.mute,
                        color: state.isMicEnabled
                            ? Colors.white12
                            : LoopColors.amber,
                        iconColor: state.isMicEnabled
                            ? Colors.white
                            : LoopColors.brandGreen,
                        onTap: busy
                            ? () {}
                            : context.read<InterviewCallCubit>().toggleMic,
                      ),
                      const SizedBox(width: 18),
                      _CallControl(
                        icon: Icons.call_end_rounded,
                        label: strings.endCall,
                        color: LoopColors.danger,
                        onTap: state.phase != InterviewCallPhase.inCall
                            ? () {}
                            : () async {
                                final isPrep = state.isPrep;
                                final trackId = widget.trackId;
                                final resultId = await context
                                    .read<InterviewCallCubit>()
                                    .end();
                                if (!context.mounted) return;
                                if (resultId == null) {
                                  _goHome(context);
                                  return;
                                }
                                if (isPrep && trackId != null) {
                                  context.go(
                                    '/interview?trackId=$trackId&loopType=interview',
                                  );
                                  return;
                                }
                                context.go(
                                  '/recap?trackId=$trackId&loopId=$resultId',
                                );
                              },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({
    required this.timerLabel,
    required this.strings,
    required this.isPrep,
  });

  final String timerLabel;
  final AppStrings strings;
  final bool isPrep;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: LoopColors.danger,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${isPrep ? strings.prepBadge : strings.live} · $timerLabel',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.speaking});

  final bool speaking;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 128,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final size in [128.0, 100.0, 76.0])
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LoopColors.accentGreen.withValues(
                  alpha: speaking ? 0.16 : 0.08,
                ),
                border: Border.all(
                  color: LoopColors.accentGreen.withValues(alpha: 0.18),
                ),
              ),
            ),
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [LoopColors.accentGreen, LoopColors.lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.graphic_eq_rounded,
              color: LoopColors.brandGreen,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}

void _goHome(BuildContext context) {
  context.read<HomeDashboardCubit>().load();
  context.go('/');
}

class _CallControl extends StatelessWidget {
  const _CallControl({
    required this.icon,
    required this.label,
    required this.color,
    this.iconColor = Colors.white,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
