import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/home_dashboard/presentation/cubit/home_dashboard_cubit.dart';
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
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final glassColor = isDark
            ? Colors.white.withValues(alpha: 0.08)
            : LoopColors.lightGreen.withValues(alpha: 0.55);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              const Spacer(),
              InkWell(
                onTap: onProfileTap,
                borderRadius: BorderRadius.circular(22),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: glassColor,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.white.withValues(alpha: 0.24),
                        ),
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
                ),
              ),
            ],
          ),
        );
      },
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
                onTap: () {
                  context.read<HomeDashboardCubit>().load();
                  context.go('/');
                },
              ),
              const SizedBox(width: 6),
              _NavItem(
                icon: Icons.route_rounded,
                active: location == '/loops',
                onTap: () => context.go('/loops'),
              ),
              const SizedBox(width: 6),
              _NavItem(
                icon: Icons.description_outlined,
                active: location == '/cv',
                onTap: () => context.go('/cv'),
              ),
              const SizedBox(width: 6),
              _NavItem(
                icon: Icons.account_tree_outlined,
                active: location == '/roadmap',
                onTap: () => context.go('/roadmap'),
              ),
            ],
          ),
        ),
        _CallButton(onTap: () => context.go('/loops/create')),
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
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : LoopColors.lightGreen.withValues(alpha: 0.55),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
            ),
            child: Center(
              child: Image.asset(
                'assets/icon/icon.png',
                width: 50,
                height: 50,
                fit: BoxFit.contain,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = active
        ? Colors.white
        : isDark
        ? Colors.white.withValues(alpha: 0.72)
        : LoopColors.textPrimary.withValues(alpha: 0.78);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF11C86F) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 24, color: iconColor),
      ),
    );
  }
}
