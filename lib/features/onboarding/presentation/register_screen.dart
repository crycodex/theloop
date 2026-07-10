import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import 'validators/auth_validators.dart';
import 'widgets/auth_form_widgets.dart';
import 'widgets/experience_options.dart';
import 'widgets/goal_grid.dart';
import 'widgets/register_step_page.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const _totalSteps = 4;

  final _accountFormKey = GlobalKey<FormState>();
  final _goalFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmationController = TextEditingController();
  final _customGoalController = TextEditingController();
  final _pageController = PageController();

  int _step = 0;
  int _goal = 0;
  int _experience = 0;
  bool _obscurePassword = true;
  bool _obscureConfirmation = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationController.dispose();
    _customGoalController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusScope.of(context).unfocus();
    if (_step == 0 && !(_accountFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_step == 1 && !(_goalFormKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_step >= _totalSteps - 1) return;

    final nextStep = _step + 1;
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 460),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    if (!mounted) return;
    setState(() => _step = nextStep);

    if (nextStep == _totalSteps - 1) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (mounted) context.go('/');
    }
  }

  Future<void> _goBack() async {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      context.go('/login');
      return;
    }

    final previousStep = _step - 1;
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 400),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    if (mounted) setState(() => _step = previousStep);
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final background = Theme.of(context).scaffoldBackgroundColor;
    void exit() => context.go('/login');

    return CupertinoTheme(
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
          _step == 2 ? strings.buildMyLoop : strings.next,
        ),
        onPressed: _continue,
        onPressedOnLastPage: null,
        pages: [
          RegisterStepPage(
            title: strings.accountDetailsTitle,
            description: strings.accountDetailsDescription,
            step: 1,
            totalSteps: _totalSteps,
            onExit: exit,
            onBack: _goBack,
            showBack: false,
            child: AutofillGroup(
              child: Form(
                key: _accountFormKey,
                child: Column(
                  children: [
                    AuthField(
                      label: strings.nameLabel,
                      hint: strings.nameHint,
                      controller: _nameController,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      validator: (value) =>
                          AuthValidators.required(value, strings),
                    ),
                    const SizedBox(height: 18),
                    AuthField(
                      label: strings.emailLabel,
                      hint: strings.emailHint,
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      textInputAction: TextInputAction.next,
                      validator: (value) =>
                          AuthValidators.email(value, strings),
                    ),
                    const SizedBox(height: 18),
                    AuthField(
                      label: strings.passwordLabel,
                      hint: strings.passwordHint,
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.next,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      validator: (value) =>
                          AuthValidators.password(value, strings),
                    ),
                    const SizedBox(height: 18),
                    AuthField(
                      label: strings.confirmPasswordLabel,
                      hint: strings.confirmPasswordHint,
                      controller: _confirmationController,
                      obscureText: _obscureConfirmation,
                      autofillHints: const [AutofillHints.newPassword],
                      textInputAction: TextInputAction.done,
                      onToggleObscure: () => setState(
                        () => _obscureConfirmation = !_obscureConfirmation,
                      ),
                      validator: (value) => AuthValidators.confirmation(
                        value,
                        _passwordController.text,
                        strings,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          RegisterStepPage(
            title: strings.goalTitle,
            description: strings.goalDescription,
            step: 2,
            totalSteps: _totalSteps,
            onExit: exit,
            onBack: _goBack,
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
            step: 3,
            totalSteps: _totalSteps,
            onExit: exit,
            onBack: _goBack,
            child: ExperienceOptions(
              selectedIndex: _experience,
              onSelected: (index) => setState(() => _experience = index),
            ),
          ),
          RegisterStepPage(
            title: strings.finishTitle,
            description: strings.finishDescription,
            step: 4,
            totalSteps: _totalSteps,
            onExit: exit,
            onBack: _goBack,
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
    );
  }
}
