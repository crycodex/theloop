import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/settings/cubit/settings_cubit.dart';
import '../../../core/settings/cubit/settings_state.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_breathing_mark.dart';
import 'widgets/auth_form_widgets.dart';
import 'widgets/onboarding_backdrop.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: OnboardingBackdrop(
        showBlurredIcon: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: PopupMenuButton<AppLanguage>(
                    tooltip: strings.welcomeLanguage,
                    onSelected: context.read<SettingsCubit>().setLanguage,
                    itemBuilder: (context) => AppLanguage.values
                        .map(
                          (language) => PopupMenuItem(
                            value: language,
                            child: Text(language.label),
                          ),
                        )
                        .toList(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language_rounded, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          strings.welcomeLanguage,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(flex: 3),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final ringSize = (constraints.maxWidth * 0.72)
                        .clamp(220.0, 270.0)
                        .toDouble();

                    return Center(
                      child: SizedBox.square(
                        dimension: ringSize,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            LoopBreathingMark(dimension: ringSize),
                            Text(
                              'the loop',
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    color: LoopColors.onboardingGreen,
                                    fontSize: (ringSize * 0.17)
                                        .clamp(36.0, 44.0)
                                        .toDouble(),
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const Spacer(flex: 2),
                Text(
                  strings.welcomeHeadline,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: LoopColors.onboardingGreen,
                    fontSize: 22,
                  ),
                ),
                const Spacer(flex: 2),
                AuthPrimaryButton(
                  label: strings.tapToContinue,
                  onPressed: () => context.go('/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
