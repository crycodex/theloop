import 'dart:ui';

import 'package:cupertino_onboarding/cupertino_onboarding.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/settings/cubit/settings_cubit.dart';
import '../../../core/settings/cubit/settings_state.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_breathing_mark.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      body: _OnboardingBackdrop(
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
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: LoopColors.onboardingGreen,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(54),
                    shape: const StadiumBorder(),
                  ),
                  onPressed: () => context.go('/login'),
                  child: Text(strings.tapToContinue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_formKey.currentState!.validate()) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: _OnboardingBackdrop(
        alignment: const Alignment(8, 0.1),
        iconScale: 3,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 48, 30, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        strings.loginTitle,
                        style: Theme.of(context).textTheme.displaySmall
                            ?.copyWith(
                              fontSize: 28,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 22),
                      _FieldLabel(label: strings.emailLabel),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        decoration: InputDecoration(
                          hintText: strings.emailHint,
                        ),
                        validator: _emailValidator,
                      ),
                      const SizedBox(height: 14),
                      _FieldLabel(label: strings.passwordLabel),
                      const SizedBox(height: 7),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          hintText: strings.passwordHint,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                            onPressed: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                        ),
                        validator: (value) => (value?.length ?? 0) < 6
                            ? 'Ingresa al menos 6 caracteres'
                            : null,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(strings.forgotPassword),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: LoopColors.onboardingGreen,
                          foregroundColor: Colors.white,
                          shape: const StadiumBorder(),
                        ),
                        onPressed: _signIn,
                        child: Text(strings.signIn),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(strings.noAccount),
                          TextButton(
                            onPressed: () => context.go('/register'),
                            child: Text(strings.register),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const _SocialButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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
  bool _isCreating = false;

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
    if (_step == 0 && !_accountFormKey.currentState!.validate()) {
      return;
    }
    if (_step == 1 && !_goalFormKey.currentState!.validate()) return;
    if (_step >= 3) return;

    final nextStep = _step + 1;
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastEaseInToSlowEaseOut,
    );
    if (!mounted) return;
    setState(() => _step = nextStep);

    if (nextStep == 3) {
      _createLoop();
    }
  }

  Future<void> _goBack() async {
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

  Future<void> _createLoop() async {
    setState(() => _isCreating = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final background = Theme.of(context).scaffoldBackgroundColor;

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
          _RegisterPage(
            title: strings.accountDetailsTitle,
            description: strings.accountDetailsDescription,
            onExit: () => context.go('/login'),
            onBack: _goBack,
            showBack: _step > 0,
            child: Form(
              key: _accountFormKey,
              child: Column(
                children: [
                  _FieldLabel(label: strings.nameLabel),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _nameController,
                    autofillHints: const [AutofillHints.name],
                    decoration: InputDecoration(hintText: strings.nameHint),
                    validator: (value) => (value?.trim().isEmpty ?? true)
                        ? 'Este campo es obligatorio'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(label: strings.emailLabel),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const [AutofillHints.email],
                    decoration: InputDecoration(hintText: strings.emailHint),
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(label: strings.passwordLabel),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(hintText: strings.passwordHint),
                    validator: (value) => (value?.length ?? 0) < 6
                        ? 'Ingresa al menos 6 caracteres'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _FieldLabel(label: strings.confirmPasswordLabel),
                  const SizedBox(height: 7),
                  TextFormField(
                    controller: _confirmationController,
                    obscureText: true,
                    autofillHints: const [AutofillHints.newPassword],
                    decoration: InputDecoration(
                      hintText: strings.confirmPasswordHint,
                    ),
                    validator: (value) => value != _passwordController.text
                        ? 'Las contraseñas no coinciden'
                        : null,
                  ),
                ],
              ),
            ),
          ),
          _RegisterPage(
            title: strings.goalTitle,
            description: strings.goalDescription,
            onExit: () => context.go('/login'),
            onBack: _goBack,
            showBack: _step > 0,
            child: Form(
              key: _goalFormKey,
              child: _GoalGrid(
                selectedIndex: _goal,
                customGoalController: _customGoalController,
                onSelected: (index) => setState(() => _goal = index),
              ),
            ),
          ),
          _RegisterPage(
            title: strings.experienceTitle,
            description: strings.experienceDescription,
            onExit: () => context.go('/login'),
            onBack: _goBack,
            showBack: _step > 0,
            child: _ExperienceOptions(
              selectedIndex: _experience,
              onSelected: (index) => setState(() => _experience = index),
            ),
          ),
          _RegisterPage(
            title: strings.finishTitle,
            description: strings.finishDescription,
            onExit: () => context.go('/login'),
            onBack: _goBack,
            showBack: _step > 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CupertinoActivityIndicator(radius: 14),
                  const SizedBox(height: 14),
                  Text(
                    strings.creating,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (!_isCreating) const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingBackdrop extends StatelessWidget {
  const _OnboardingBackdrop({
    required this.child,
    this.alignment = Alignment.center,
    this.showBlurredIcon = true,
    this.iconScale = 1.45,
  });

  final Widget child;
  final Alignment alignment;
  final bool showBlurredIcon;
  final double iconScale;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ColoredBox(color: Theme.of(context).scaffoldBackgroundColor),
        ),
        if (showBlurredIcon)
          Align(
            alignment: alignment,
            child: IgnorePointer(
              child: Opacity(
                opacity: Theme.of(context).brightness == Brightness.dark
                    ? 0.2
                    : 0.42,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                  child: Transform.scale(
                    scale: iconScale,
                    child: Image.asset(
                      'assets/icon/icon.png',
                      width: 330,
                      height: 330,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ),
        child,
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: Theme.of(context).textTheme.labelLarge),
    );
  }
}

class _SocialButtons extends StatelessWidget {
  const _SocialButtons();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(icon: Icons.facebook_rounded, color: Color(0xFF4267B2)),
        SizedBox(width: 12),
        _SocialButton(
          icon: Icons.g_mobiledata_rounded,
          color: Color(0xFF4285F4),
        ),
        SizedBox(width: 12),
        _SocialButton(icon: Icons.apple, color: Colors.black),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 42,
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _RegisterPage extends StatelessWidget {
  const _RegisterPage({
    required this.title,
    required this.description,
    required this.onExit,
    required this.onBack,
    required this.showBack,
    required this.child,
  });

  final String title;
  final String description;
  final VoidCallback onExit;
  final VoidCallback onBack;
  final bool showBack;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: const Size(44, 44),
                      onPressed: onExit,
                      child: Text(strings.exitOnboarding),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: LoopColors.onboardingGreen,
                    fontSize: 25,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 28),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoalGrid extends StatelessWidget {
  const _GoalGrid({
    required this.selectedIndex,
    required this.customGoalController,
    required this.onSelected,
  });

  final int selectedIndex;
  final TextEditingController customGoalController;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final goals = [
      (strings.goalBigTech, strings.goalBigTechDetail),
      (strings.goalConsulting, strings.goalConsultingDetail),
      (strings.goalBanking, strings.goalBankingDetail),
      (strings.goalStartup, strings.goalStartupDetail),
      (strings.goalProductManager, strings.goalProductManagerDetail),
      ('+ ${strings.goalCustom}', strings.goalCustomDetail),
    ];

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.25,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final selected = selectedIndex == index;
            return _SelectionCard(
              selected: selected,
              onTap: () => onSelected(index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    goals[index].$1,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : null,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    goals[index].$2,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? Colors.white.withValues(alpha: 0.85)
                          : Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (selectedIndex == 5) ...[
          const SizedBox(height: 20),
          _FieldLabel(label: strings.customGoalLabel),
          const SizedBox(height: 7),
          TextFormField(
            controller: customGoalController,
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
            decoration: InputDecoration(hintText: strings.customGoalHint),
            validator: (value) => (value?.trim().isEmpty ?? true)
                ? 'Describe tu objetivo para continuar'
                : null,
          ),
        ],
      ],
    );
  }
}

class _ExperienceOptions extends StatelessWidget {
  const _ExperienceOptions({
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);
    final options = [
      (strings.experienceNone, strings.experienceNoneDetail),
      (strings.experienceSome, strings.experienceSomeDetail),
      (strings.experienceAdvanced, strings.experienceAdvancedDetail),
    ];

    return Column(
      children: List.generate(options.length, (index) {
        final selected = selectedIndex == index;
        return Padding(
          padding: EdgeInsets.only(
            bottom: index == options.length - 1 ? 0 : 10,
          ),
          child: _SelectionCard(
            selected: selected,
            onTap: () => onSelected(index),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: selected
                      ? Colors.white
                      : LoopColors.onboardingGreen,
                  child: Text(
                    '${index + 1}',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: selected
                          ? LoopColors.onboardingGreen
                          : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        options[index].$1,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected ? Colors.white : null,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        options[index].$2,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: selected
                              ? Colors.white.withValues(alpha: 0.85)
                              : Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  const _SelectionCard({
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
      color: selected ? LoopColors.onboardingGreen : Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: selected
                  ? LoopColors.onboardingGreen
                  : Theme.of(context).dividerColor.withValues(alpha: 0.35),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

String? _emailValidator(String? value) {
  final email = value?.trim() ?? '';
  if (!email.contains('@') || !email.contains('.')) {
    return 'Ingresa un email válido';
  }
  return null;
}
