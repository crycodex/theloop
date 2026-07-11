import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
import '../../../../core/theme/loop_colors.dart';

class RegisterStepPage extends StatelessWidget {
  const RegisterStepPage({
    super.key,
    required this.title,
    required this.description,
    required this.step,
    required this.totalSteps,
    required this.onExit,
    required this.onBack,
    required this.child,
    this.showBack = true,
    this.showExit = true,
    this.centerChild = false,
  });

  final String title;
  final String description;
  final int step;
  final int totalSteps;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final Widget child;
  final bool showBack;
  final bool showExit;
  final bool centerChild;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (showBack)
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 44),
                onPressed: onBack,
                child: const Icon(CupertinoIcons.back),
              )
            else
              const SizedBox(width: 44),
            const Spacer(),
            Text(
              strings.stepProgress(step, totalSteps),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (showExit)
              CupertinoButton(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: const Size(44, 44),
                onPressed: onExit,
                child: Text(strings.exitOnboarding),
              )
            else
              const SizedBox(width: 44),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: step / totalSteps,
            minHeight: 5,
            backgroundColor: LoopColors.onboardingGreen.withValues(
              alpha: 0.12,
            ),
            valueColor: const AlwaysStoppedAnimation(
              LoopColors.onboardingGreen,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: LoopColors.onboardingGreen,
            fontSize: 27,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        header,
                        centerChild
                            ? SizedBox(
                                height: constraints.maxHeight * 0.5,
                                child: Center(child: child),
                              )
                            : child,
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
