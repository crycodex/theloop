import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/settings/cubit/settings_cubit.dart';
import '../../../core/settings/cubit/settings_state.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../features/interview_call/data/services/gemini_config.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = state.profile;
        final strings = AppStrings.of(context);

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            title: Text(strings.profile),
          ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.profile,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 18),
                  LoopCard(
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 34,
                          backgroundColor: LoopColors.brandGreen,
                          child: Text(
                            'C',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                profile.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                profile.target.isEmpty
                                    ? profile.email
                                    : strings.goalLabel(profile.target),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SettingsTile(
                    icon: Icons.flag_rounded,
                    title: strings.careerGoal,
                    subtitle: strings.careerGoalSubtitle,
                  ),
                  _SettingsTile(
                    icon: Icons.credit_card_rounded,
                    title: strings.subscription,
                    subtitle: strings.subscriptionPlan(profile.plan),
                  ),
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: strings.privacy,
                    subtitle: strings.privacySubtitle,
                  ),
                  _PreferencesPanel(strings: strings),
                  const SizedBox(height: 8),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: strings.logout,
                    subtitle: strings.logoutConfirmMessage,
                    iconColor: LoopColors.danger,
                    iconBackground: LoopColors.danger.withValues(alpha: 0.12),
                    onTap: () => _confirmSignOut(context, strings),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AppStrings strings) async {
    final authCubit = context.read<AuthCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.logoutConfirmTitle),
        content: Text(strings.logoutConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.exitOnboarding),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.logout),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await authCubit.signOut();
    if (context.mounted) context.go('/welcome');
  }
}

class _PreferencesPanel extends StatelessWidget {
  const _PreferencesPanel({required this.strings});

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LoopCard(
            padding: EdgeInsets.zero,
            child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 18),
              childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
              leading: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: LoopColors.lightGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: LoopColors.brandGreen,
                ),
              ),
              title: Text(
                strings.preferences,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(strings.preferencesSubtitle),
              children: [
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: Text(strings.darkMode),
                  value: settings.isDarkMode,
                  activeThumbColor: LoopColors.accentGreen,
                  onChanged: context.read<SettingsCubit>().setDarkMode,
                ),
                const Divider(),
                Text(strings.languageLabel, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<AppLanguage>(
                  segments: AppLanguage.values
                      .map(
                        (language) => ButtonSegment(
                          value: language,
                          label: Text(language.label),
                        ),
                      )
                      .toList(),
                  selected: {settings.language},
                  onSelectionChanged: (selection) {
                    context.read<SettingsCubit>().setLanguage(selection.first);
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  strings.recruiterLanguageHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Divider(),
                Text(strings.recruiterVoiceLabel, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SegmentedButton<RecruiterVoice>(
                  segments: RecruiterVoice.values
                      .map(
                        (voice) => ButtonSegment(
                          value: voice,
                          label: Text(voice.label(settings.language)),
                        ),
                      )
                      .toList(),
                  selected: {settings.recruiterVoice},
                  onSelectionChanged: (selection) {
                    context.read<SettingsCubit>().setRecruiterVoice(
                      selection.first,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.iconColor,
    this.iconBackground,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? iconBackground;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LoopCard(
        onTap: onTap,
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconBackground ?? LoopColors.lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor ?? LoopColors.brandGreen),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: LoopColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
