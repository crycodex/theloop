import 'package:flutter/material.dart';

import '../../../../core/theme/loop_colors.dart';

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.selected,
    required this.onTap,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? LoopColors.onboardingGreen
          : Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? LoopColors.onboardingGreen
                  : Theme.of(context).dividerColor.withValues(alpha: 0.22),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: LoopColors.onboardingGreen.withValues(alpha: 0.2),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: child,
        ),
      ),
    );
  }
}
