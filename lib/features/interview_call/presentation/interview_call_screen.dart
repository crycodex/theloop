import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/loop_colors.dart';

class InterviewCallScreen extends StatelessWidget {
  const InterviewCallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoopColors.surfaceBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          child: Column(
            children: [
              Row(
                children: [
                  _LiveBadge(),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
              const Spacer(),
              const _Orb(),
              const SizedBox(height: 34),
              Text(
                'Interviewer AI',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Cuéntame de una vez en la que tuviste que liderar una decisión técnica con información incompleta.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CallControl(
                    icon: Icons.mic_rounded,
                    label: 'Mic',
                    color: Colors.white12,
                    onTap: () {},
                  ),
                  const SizedBox(width: 18),
                  _CallControl(
                    icon: Icons.pause_rounded,
                    label: 'Pausar',
                    color: Colors.white12,
                    onTap: () {},
                  ),
                  const SizedBox(width: 18),
                  _CallControl(
                    icon: Icons.call_end_rounded,
                    label: 'Terminar',
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
  }
}

class _LiveBadge extends StatelessWidget {
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
          const Text(
            'EN VIVO · 04:32',
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
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
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
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}
