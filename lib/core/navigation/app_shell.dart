import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/profile/presentation/cubit/profile_cubit.dart';
import '../../features/profile/presentation/cubit/profile_state.dart';
import '../theme/loop_colors.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.location, required this.child});

  final String location;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _TopBar(onProfileTap: () => context.go('/profile')),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 18,
              child: _FloatingNavBar(location: location),
            ),
          ],
        ),
      ),
    );
  }
}

class ShellPagePadding extends StatelessWidget {
  const ShellPagePadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 92, 20, 128),
      child: child,
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onProfileTap});

  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        final userName = state is ProfileLoaded ? state.profile.name : '';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
        children: [
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: LoopColors.surfaceElevated.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: LoopColors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 16,
                    backgroundColor: LoopColors.brandGreen,
                    child: Text(
                      'C',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _TopIconButton(
            icon: Icons.notifications_none_rounded,
            onTap: () {},
          ),
          const SizedBox(width: 8),
          _TopIconButton(
            icon: Icons.settings_rounded,
            onTap: onProfileTap,
          ),
        ],
      ),
    );
      },
    );
  }
}

class _TopIconButton extends StatelessWidget {
  const _TopIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: LoopColors.surfaceElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: LoopColors.border),
        ),
        child: Icon(icon, size: 20, color: LoopColors.textPrimary),
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({required this.location});

  final String location;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _BlurPill(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavItem(
                icon: Icons.bar_chart_rounded,
                active: location == '/',
                onTap: () => context.go('/'),
              ),
              const SizedBox(width: 10),
              _NavItem(
                icon: Icons.crop_square_rounded,
                active: location == '/cv',
                onTap: () => context.go('/cv'),
              ),
              const SizedBox(width: 10),
              _NavItem(
                icon: Icons.account_tree_outlined,
                active: location == '/roadmap',
                onTap: () => context.go('/roadmap'),
              ),
            ],
          ),
        ),
        _CallButton(onTap: () => context.go('/interview')),
      ],
    );
  }
}

class _BlurPill extends StatelessWidget {
  const _BlurPill({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 66,
          padding: const EdgeInsets.symmetric(horizontal: 9),
          decoration: BoxDecoration(
            color: LoopColors.surfaceBlack.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  const _CallButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 66,
        height: 66,
        decoration: BoxDecoration(
          color: LoopColors.surfaceBlack.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              blurRadius: 28,
              offset: const Offset(0, 12),
              color: LoopColors.brandGreen.withValues(alpha: 0.24),
            ),
          ],
        ),
        child: Center(
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: LoopColors.accentGreen, width: 4),
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  spreadRadius: 1,
                  color: LoopColors.accentGreen.withValues(alpha: 0.42),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.graphic_eq_rounded,
                color: LoopColors.accentGreen,
                size: 18,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconColor = active ? Colors.white : Colors.white70;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF11C86F) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }
}
