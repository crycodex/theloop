import 'dart:async';

import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import 'widgets/experience_options.dart';
import 'widgets/goal_grid.dart';
import 'widgets/register_step_page.dart';

const _goalIds = [
  'bigTech',
  'consulting',
  'banking',
  'startup',
  'productManager',
  'custom',
];

const _experienceIds = ['none', 'some', 'advanced'];

class GoogleOnboardingScreen extends StatefulWidget {
  const GoogleOnboardingScreen({super.key});

  @override
  State<GoogleOnboardingScreen> createState() => _GoogleOnboardingScreenState();
}

class _GoogleOnboardingScreenState extends State<GoogleOnboardingScreen> {
  static const _totalSteps = 3;

  final _goalFormKey = GlobalKey<FormState>();
  final _customGoalController = TextEditingController();
  final _pageController = PageController();

  int _step = 0;
  int _goal = 0;
  int _experience = 0;

  @override
  void dispose() {
    _customGoalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _resolveDisplayName() {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email;
    if (email == null || email.isEmpty) return 'User';
    final localPart = email.split('@').first.trim();
    if (localPart.isEmpty) return 'User';
    return localPart[0].toUpperCase() + localPart.substring(1);
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    if (_step == 0 && !(_goalFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_step >= _totalSteps - 1) return;

    final nextStep = _step + 1;
    setState(() => _step = nextStep);
    unawaited(
      _pageController.nextPage(
        duration: const Duration(milliseconds: 460),
        curve: Curves.fastEaseInToSlowEaseOut,
      ),
    );

    if (nextStep == _totalSteps - 1) {
      unawaited(
        context.read<AuthCubit>().completeGoogleOnboarding(
          name: _resolveDisplayName(),
          goalId: _goalIds[_goal],
          customGoal: _goal == _goalIds.length - 1
              ? _customGoalController.text
              : null,
          experienceId: _experienceIds[_experience],
        ),
      );
    }
  }

  Future<void> _goBack() async {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      await context.read<AuthCubit>().signOut();
      if (mounted) context.go('/login');
      return;
    }

    final previousStep = _step - 1;
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    if (mounted) setState(() => _step = previousStep);
  }

  Future<void> _revertToStart() async {
    _pageController.jumpToPage(0);
    if (mounted) setState(() => _step = 0);
  }

  String _errorMessage(AppStrings strings, AuthFailureReason reason) {
    return switch (reason) {
      AuthFailureReason.emailAlreadyInUse => strings.authErrorEmailInUse,
      AuthFailureReason.invalidCredential => strings.authErrorInvalidCredential,
      AuthFailureReason.weakPassword => strings.authErrorWeakPassword,
      AuthFailureReason.emailNotVerified => strings.authErrorEmailNotVerified,
      AuthFailureReason.network => strings.authErrorNetwork,
      AuthFailureReason.unknown => strings.authErrorUnknown,
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final background = Theme.of(context).scaffoldBackgroundColor;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          context.go('/');
        } else if (state is AuthFailure) {
          unawaited(_revertToStart());
          unawaited(
            showCupertinoDialog<void>(
              context: context,
              builder: (dialogContext) => CupertinoAlertDialog(
                content: Text(_errorMessage(strings, state.reason)),
                actions: [
                  CupertinoDialogAction(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    child: Text(strings.continueLabel),
                  ),
                ],
              ),
            ),
          );
        }
      },
      child: CupertinoTheme(
        data: CupertinoThemeData(
          primaryColor: LoopColors.onboardingGreen,
          brightness: Theme.of(context).brightness,
        ),
        child: CupertinoOnboarding(
          controller: _pageController,
          backgroundColor: background,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          bottomButtonColor: LoopColors.onboardingGreen,
          bottomButtonBorderRadius: BorderRadius.circular(999),
          bottomButtonPadding: const EdgeInsets.fromLTRB(28, 12, 28, 28),
          bottomButtonChild: Text(
            _step == 1 ? strings.buildMyLoop : strings.next,
          ),
          onPressed: _continue,
          onPressedOnLastPage: null,
          pages: [
            RegisterStepPage(
              title: strings.goalTitle,
              description: strings.goalDescription,
              step: 1,
              totalSteps: _totalSteps,
              onExit: () => unawaited(_goBack()),
              onBack: _goBack,
              showBack: false,
              child: Form(
                key: _goalFormKey,
                child: GoalGrid(
                  selectedIndex: _goal,
                  customGoalController: _customGoalController,
                  onSelected: (index) => setState(() => _goal = index),
                ),
              ),
            ),
            RegisterStepPage(
              title: strings.experienceTitle,
              description: strings.experienceDescription,
              step: 2,
              totalSteps: _totalSteps,
              onExit: () => unawaited(_goBack()),
              onBack: _goBack,
              child: ExperienceOptions(
                selectedIndex: _experience,
                onSelected: (index) => setState(() => _experience = index),
              ),
            ),
            RegisterStepPage(
              title: strings.finishTitle,
              description: strings.finishDescription,
              step: 3,
              totalSteps: _totalSteps,
              onExit: () => unawaited(_goBack()),
              onBack: _goBack,
              showBack: false,
              showExit: false,
              centerChild: true,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 42),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CupertinoActivityIndicator(radius: 16),
                      const SizedBox(height: 16),
                      Text(
                        strings.creating,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
