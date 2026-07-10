import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SocialAuthButtons extends StatelessWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(
          icon: CupertinoIcons.person_2_fill,
          color: const Color(0xFF4267B2),
          onPressed: () {},
        ),
        const SizedBox(width: 12),
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          color: const Color(0xFF4285F4),
          onPressed: () {},
        ),
        const SizedBox(width: 12),
        _SocialButton(
          icon: Icons.apple,
          color: Theme.of(context).colorScheme.onSurface,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

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
        child: Icon(icon, color: color),
      ),
    );
  }
}
