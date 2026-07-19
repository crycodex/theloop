import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../auth/presentation/cubit/auth_state.dart';
import 'validators/auth_validators.dart';
import 'widgets/auth_form_widgets.dart';
import 'widgets/onboarding_backdrop.dart';
import 'widgets/social_auth_buttons.dart';

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
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
    }
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
        if (state is AuthSuccess) {
          context.go('/');
        } else if (state is GoogleOnboardingRequired) {
          context.go('/google-onboarding');
        } else if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_errorMessage(strings, state.reason))),
          );
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: OnboardingBackdrop(
          alignment: const Alignment(6, -0.2),
          iconScale: 2.7,
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: AutofillGroup(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthHeader(
                            title: strings.loginTitle,
                            description: strings.loginDescription,
                            onBack: () => context.go('/welcome'),
                          ),
                          const SizedBox(height: 32),
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
                            autofillHints: const [AutofillHints.password],
                            textInputAction: TextInputAction.done,
                            onToggleObscure: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                            validator: (value) =>
                                AuthValidators.password(value, strings),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push('/forgot-password'),
                              child: Text(strings.forgotPassword),
                            ),
                          ),
                          const SizedBox(height: 10),
                          BlocBuilder<AuthCubit, AuthState>(
                            builder: (context, state) {
                              return AuthPrimaryButton(
                                label: strings.signIn,
                                loading: state is AuthSubmitting,
                                onPressed: _signIn,
                              );
                            },
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
                          const SizedBox(height: 14),
                          const SocialAuthButtons(),
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
    );
  }
}
