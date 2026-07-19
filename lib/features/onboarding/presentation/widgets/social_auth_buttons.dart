import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final showApple =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final loading = state is AuthSubmitting;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              icon: Icons.g_mobiledata,
              color: Colors.red,
              loading: loading,
              onPressed: loading
                  ? null
                  : () => context.read<AuthCubit>().signInWithGoogle(),
            ),
            if (showApple) ...[
              const SizedBox(width: 12),
              _SocialButton(
                icon: Icons.apple,
                color: Theme.of(context).colorScheme.onSurface,
                loading: loading,
                onPressed: loading
                    ? null
                    : () => context.read<AuthCubit>().signInWithApple(),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onPressed,
    this.loading = false,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 48,
      child: PhysicalModel(
        color: Colors.transparent,
        elevation: 6,
        shadowColor: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(14),
        child: CupertinoButton(
          padding: EdgeInsets.zero,
          color: CupertinoDynamicColor.resolve(
            CupertinoColors.tertiarySystemBackground,
            context,
          ),
          borderRadius: BorderRadius.circular(14),
          onPressed: onPressed,
          child: loading
              ? const CupertinoActivityIndicator(radius: 10)
              : Icon(icon, color: color),
        ),
      ),
    );
  }
}
