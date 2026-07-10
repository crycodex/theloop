import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/theme/loop_colors.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import 'validators/auth_validators.dart';
import 'widgets/auth_form_widgets.dart';
import 'widgets/onboarding_backdrop.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isSending = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSending = true);
    await context.read<AuthCubit>().sendPasswordReset(
      _emailController.text.trim(),
    );
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

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (!_isSending) return;
        if (state is PasswordResetSent ||
            (state is AuthFailure &&
                state.reason == AuthFailureReason.invalidCredential)) {
          setState(() {
            _isSending = false;
            _sent = true;
          });
        } else if (state is AuthFailure) {
          setState(() => _isSending = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage(strings, state.reason))),
          );
        }
      },
      child: Scaffold(
      resizeToAvoidBottomInset: true,
      body: OnboardingBackdrop(
        alignment: const Alignment(-5, 0.3),
        iconScale: 2.6,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.04),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _sent
                      ? _SuccessState(
                          key: const ValueKey('success'),
                          email: _emailController.text.trim(),
                          onBack: _goBack,
                        )
                      : KeyedSubtree(
                          key: const ValueKey('form'),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                AuthHeader(
                                  title: strings.forgotPasswordTitle,
                                  description:
                                      strings.forgotPasswordDescription,
                                  onBack: _goBack,
                                ),
                                const SizedBox(height: 32),
                                AuthField(
                                  label: strings.emailLabel,
                                  hint: strings.emailHint,
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.done,
                                  validator: (value) =>
                                      AuthValidators.email(value, strings),
                                ),
                                const SizedBox(height: 24),
                                AuthPrimaryButton(
                                  label: strings.sendResetLink,
                                  loading: _isSending,
                                  onPressed: _sendResetLink,
                                ),
                              ],
                            ),
                          ),
                        ),
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

class _SuccessState extends StatelessWidget {
  const _SuccessState({super.key, required this.email, required this.onBack});

  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(44, 44),
            onPressed: onBack,
            child: const Icon(CupertinoIcons.back),
          ),
        ),
        const SizedBox(height: 44),
        Center(
          child: Container(
            width: 82,
            height: 82,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: LoopColors.onboardingGreen.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.paperplane_fill,
              size: 36,
              color: LoopColors.onboardingGreen,
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          strings.resetLinkSentTitle,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          strings.resetLinkSentDescription(email),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 32),
        AuthPrimaryButton(label: strings.backToLogin, onPressed: onBack),
      ],
    );
  }
}
