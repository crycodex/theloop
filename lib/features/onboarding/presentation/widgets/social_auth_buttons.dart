import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final loading = state is AuthSubmitting;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialButton(
              icon: CupertinoIcons.person_2_fill,
              color: const Color(0xFF4267B2),
              onPressed: loading ? null : () {},
            ),
            const SizedBox(width: 12),
            _SocialButton(
              icon: Icons.g_mobiledata_rounded,
              color: const Color(0xFF4285F4),
              loading: loading,
              onPressed: loading
                  ? null
                  : () => context.read<AuthCubit>().signInWithGoogle(),
            ),
            const SizedBox(width: 12),
            _SocialButton(
              icon: Icons.apple,
              color: Theme.of(context).colorScheme.onSurface,
              onPressed: loading ? null : () {},
            ),
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
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        color: CupertinoDynamicColor.resolve(
          CupertinoColors.secondarySystemBackground,
          context,
        ),
        borderRadius: BorderRadius.circular(14),
        onPressed: onPressed,
        child: loading
            ? const CupertinoActivityIndicator(radius: 10)
            : Icon(icon, color: color),
      ),
    );
  }
}
