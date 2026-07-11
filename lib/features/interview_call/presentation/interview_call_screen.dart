import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import '../domain/entities/transcript_turn.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
  }

  @override
  void didUpdateWidget(covariant InterviewCallScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trackId != widget.trackId ||
        oldWidget.loopType != widget.loopType ||
        oldWidget.sourceLoopId != widget.sourceLoopId) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _startSession());
    }
  }

  void _startSession() {
    context.read<InterviewCallCubit>().start(
      sourceLoopId: widget.sourceLoopId,
      trackId: widget.trackId,
      loopType: widget.loopType == 'prep' ? LoopType.prep : LoopType.interview,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
      );
    });
  }

  bool _transcriptChanged(
    List<TranscriptTurn> previous,
    List<TranscriptTurn> current,
  ) {
    if (previous.length != current.length) return true;
    if (previous.isEmpty || current.isEmpty) return false;
    final prevLast = previous.last;
    final curLast = current.last;
    return prevLast.text != curLast.text;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<InterviewCallCubit, InterviewCallState>(
      listenWhen: (previous, current) =>
          _transcriptChanged(previous.transcript, current.transcript) ||
          (previous.phase != current.phase &&
              (current.phase == InterviewCallPhase.completed ||
                  (previous.phase == InterviewCallPhase.ending &&
                      current.phase == InterviewCallPhase.idle))),
      listener: (context, state) {
        if (state.phase == InterviewCallPhase.completed) {
          final trackId = state.trackId ?? widget.trackId;
          if (state.isPrep && trackId != null) {
            context.go('/interview?trackId=$trackId&loopType=interview');
            return;
          }
          final loopId = state.loopId;
          if (loopId != null && trackId != null) {
            context.read<HomeDashboardCubit>().load();
            context.go('/recap?trackId=$trackId&loopId=$loopId');
          }
          return;
        }
        if (state.phase == InterviewCallPhase.idle) {
          _goHome(context);
          return;
        }
        _scrollToEnd();
      },
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
                  _SpeakingOrb(
                    speaking: state.isAiSpeaking,
                    inCall: state.phase == InterviewCallPhase.inCall,
                  ),
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
                            padding: const EdgeInsets.only(bottom: 8),
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
                      onPressed: () => _startSession(),
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
                            : () => context.read<InterviewCallCubit>().end(),
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

class _SpeakingOrb extends StatefulWidget {
  const _SpeakingOrb({required this.speaking, required this.inCall});

  final bool speaking;
  final bool inCall;

  @override
  State<_SpeakingOrb> createState() => _SpeakingOrbState();
}

class _SpeakingOrbState extends State<_SpeakingOrb>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant _SpeakingOrb oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    if (widget.speaking) {
      if (!_controller.isAnimating) _controller.repeat();
    } else if (widget.inCall) {
      _controller
        ..stop()
        ..value = 0;
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 148,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _FlameWavePainter(
              progress: _controller.value,
              speaking: widget.speaking,
              inCall: widget.inCall,
            ),
            child: Center(
              child: Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: widget.speaking
                        ? [
                            const Color(0xFFFFB347),
                            LoopColors.accentGreen,
                            LoopColors.lightGreen,
                          ]
                        : [LoopColors.accentGreen, LoopColors.lightGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: widget.speaking
                      ? [
                          BoxShadow(
                            color: LoopColors.accentGreen.withValues(alpha: 0.45),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  widget.speaking
                      ? Icons.local_fire_department_rounded
                      : Icons.graphic_eq_rounded,
                  color: LoopColors.brandGreen,
                  size: 30,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlameWavePainter extends CustomPainter {
  _FlameWavePainter({
    required this.progress,
    required this.speaking,
    required this.inCall,
  });

  final double progress;
  final bool speaking;
  final bool inCall;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.48;

    if (!speaking) {
      final idlePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = LoopColors.accentGreen.withValues(alpha: inCall ? 0.22 : 0.1);
      canvas.drawCircle(center, maxRadius * 0.72, idlePaint);
      canvas.drawCircle(center, maxRadius * 0.56, idlePaint);
      return;
    }

    const waveCount = 4;
    for (var i = 0; i < waveCount; i++) {
      final waveProgress = (progress + i / waveCount) % 1.0;
      final radius = maxRadius * (0.42 + waveProgress * 0.58);
      final alpha = (1 - waveProgress) * 0.42;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 - waveProgress * 1.8
        ..color = Color.lerp(
          const Color(0xFFFF9A3C),
          LoopColors.accentGreen,
          waveProgress,
        )!.withValues(alpha: alpha);

      canvas.drawCircle(center, radius, paint);
    }

    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * 3.1415926535 * 2 + progress * 3.1415926535 * 2;
      final sparkRadius = maxRadius * (0.34 + (i % 3) * 0.04);
      final sparkSize = 2.5 + (i % 2);
      final offset = Offset(
        center.dx + sparkRadius * math.cos(angle),
        center.dy + sparkRadius * math.sin(angle),
      );
      final sparkPaint = Paint()
        ..color = Color.lerp(
          const Color(0xFFFFD166),
          LoopColors.accentGreen,
          (i % 4) / 4,
        )!.withValues(alpha: 0.35 + (i % 3) * 0.15);
      canvas.drawCircle(offset, sparkSize, sparkPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlameWavePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.speaking != speaking ||
        oldDelegate.inCall != inCall;
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
