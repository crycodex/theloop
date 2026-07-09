import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import 'cubit/interview_call_cubit.dart';
import 'cubit/interview_call_state.dart';

class InterviewCallScreen extends StatelessWidget {
  const InterviewCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InterviewCallCubit, InterviewCallState>(
      builder: (context, state) {
        final strings = AppStrings.of(context);

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
                        elapsedLabel: state.elapsedLabel,
                        strings: strings,
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => context.go('/'),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const _Orb(),
                  const SizedBox(height: 34),
                  Text(
                    strings.interviewerAi,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineMedium?.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.isPaused
                        ? strings.interviewPaused
                        : strings.interviewPrompt(state.prompt),
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
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
                        onTap: context.read<InterviewCallCubit>().toggleMic,
                      ),
                      const SizedBox(width: 18),
                      _CallControl(
                        icon: state.isPaused
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        label: state.isPaused ? strings.resume : strings.pause,
                        color: state.isPaused
                            ? LoopColors.accentGreen
                            : Colors.white12,
                        iconColor: state.isPaused
                            ? LoopColors.brandGreen
                            : Colors.white,
                        onTap: context.read<InterviewCallCubit>().togglePause,
                      ),
                      const SizedBox(width: 18),
                      _CallControl(
                        icon: Icons.call_end_rounded,
                        label: strings.endCall,
                        color: LoopColors.danger,
                        onTap: () => context.go('/recap'),
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
  const _LiveBadge({required this.elapsedLabel, required this.strings});

  final String elapsedLabel;
  final AppStrings strings;

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
            '${strings.live} · $elapsedLabel',
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
  const _Orb();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final size in [210.0, 164.0, 118.0])
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: LoopColors.accentGreen.withValues(alpha: 0.08),
                border: Border.all(
                  color: LoopColors.accentGreen.withValues(alpha: 0.18),
                ),
              ),
            ),
          Container(
            width: 94,
            height: 94,
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
              size: 42,
            ),
          ),
        ],
      ),
    );
  }
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
