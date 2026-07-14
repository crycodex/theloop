import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/settings/cubit/settings_cubit.dart';
import '../../../core/settings/cubit/settings_state.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
import '../../../features/interview_call/data/services/gemini_config.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../onboarding/presentation/widgets/experience_options.dart';
import '../../onboarding/presentation/widgets/goal_grid.dart';
import 'cubit/profile_cubit.dart';
import 'cubit/profile_state.dart';

const _goalIds = [
  'bigTech',
  'consulting',
  'banking',
  'startup',
  'productManager',
  'custom',
];

const _experienceIds = ['none', 'some', 'advanced'];

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _customGoalController;
  int _goalIndex = 0;
  int _experienceIndex = 0;
  bool _initialized = false;
  Timer? _saveDebounce;
  bool _isSaving = false;

  static const _saveDebounceDuration = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _customGoalController = TextEditingController();
    _nameController.addListener(_onFieldChanged);
    _customGoalController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => _scheduleAutoSave();

  @override
  void dispose() {
    _saveDebounce?.cancel();
    _nameController
      ..removeListener(_onFieldChanged)
      ..dispose();
    _customGoalController
      ..removeListener(_onFieldChanged)
      ..dispose();
    super.dispose();
  }

  void _syncFromProfile(ProfileLoaded state) {
    if (_initialized) return;
    final profile = state.profile;
    _nameController.text = profile.name;
    _customGoalController.text = profile.customGoal ?? '';
    _goalIndex = _goalIds.indexOf(profile.target).clamp(0, _goalIds.length - 1);
    if (_goalIds[_goalIndex] != profile.target) {
      _goalIndex = _goalIds.length - 1;
    }
    _experienceIndex = _experienceIds
        .indexOf(profile.experience)
        .clamp(0, _experienceIds.length - 1);
    _initialized = true;
  }

  String _initial(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '?';
    return trimmed[0].toUpperCase();
  }

  void _scheduleAutoSave() {
    if (!_initialized || _isSaving) return;
    _saveDebounce?.cancel();
    _saveDebounce = Timer(_saveDebounceDuration, _saveProfile);
  }

  Future<void> _saveProfile() async {
    if (!_initialized || _isSaving) return;

    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    if (_goalIndex == _goalIds.length - 1 &&
        _customGoalController.text.trim().isEmpty) {
      return;
    }

    _isSaving = true;
    await context.read<ProfileCubit>().updateProfile(
      name: name,
      goalId: _goalIds[_goalIndex],
      customGoal: _goalIndex == _goalIds.length - 1
          ? _customGoalController.text
          : null,
      experienceId: _experienceIds[_experienceIndex],
    );
    if (mounted) _isSaving = false;
  }

  void _selectExperience(int index) {
    if (_experienceIndex == index) return;
    setState(() => _experienceIndex = index);
    _saveDebounce?.cancel();
    unawaited(_saveProfile());
  }

  void _selectGoal(int index) {
    if (_goalIndex == index) return;
    setState(() => _goalIndex = index);
    if (index != _goalIds.length - 1) {
      _saveDebounce?.cancel();
      unawaited(_saveProfile());
    }
  }

  Future<void> _exportData(AppStrings strings) async {
    final data = await context.read<ProfileCubit>().exportData();
    if (!mounted || data == null) return;
    final jsonText = const JsonEncoder.withIndent('  ').convert(data);
    await SharePlus.instance.share(
      ShareParams(text: jsonText, subject: 'Loop — ${strings.exportData}'),
    );
  }

  Future<void> _confirmDeleteAccount(AppStrings strings) async {
    final passwordController = TextEditingController();
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(strings.deleteAccountConfirmTitle),
        content: Column(
          children: [
            const SizedBox(height: 8),
            Text(strings.deleteAccountWarning),
            const SizedBox(height: 12),
            CupertinoTextField(
              controller: passwordController,
              placeholder: strings.passwordLabel,
              obscureText: true,
              autocorrect: false,
            ),
          ],
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.confirmDelete),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      passwordController.dispose();
      return;
    }

    final password = passwordController.text;
    passwordController.dispose();
    await context.read<ProfileCubit>().deleteAccount(password);
  }

  Future<void> _confirmSignOut(AppStrings strings) async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: Text(strings.logoutConfirmTitle),
        content: Text(strings.logoutConfirmMessage),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(strings.cancel),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(strings.logout),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    await context.read<AuthCubit>().signOut();
    if (mounted) context.go('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          current is ProfileDeleted ||
          (current is ProfileLoaded &&
              current.actionMessage != null &&
              current != previous),
      listener: (context, state) {
        if (state is ProfileDeleted) {
          context.read<AuthCubit>().signOut();
          context.go('/welcome');
          return;
        }
        if (state is ProfileLoaded && state.actionMessage == 'updated') {
          context.read<ProfileCubit>().clearActionMessage();
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(strings.profileUpdated),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
        }
        if (state is ProfileLoaded && state.actionError != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.actionError!)));
          context.read<ProfileCubit>().clearActionMessage();
        }
      },
      builder: (context, state) {
        if (state is! ProfileLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        _syncFromProfile(state);
        final profile = state.profile;
        final goalLabel =
            profile.target == 'custom' &&
                profile.customGoal?.trim().isNotEmpty == true
            ? profile.customGoal!.trim()
            : strings.goalLabel(profile.target);

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
                  const SizedBox(height: 20),
                  _ProfileExpansionCard(
                    icon: Icons.person_outline_rounded,
                    title: strings.editProfile,
                    subtitle: profile.name.isEmpty
                        ? profile.email
                        : profile.name,
                    leadingAvatar: _initial(profile.name),
                    children: [
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: strings.nameLabel,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InputDecorator(
                        decoration: InputDecoration(
                          labelText: strings.emailLabel,
                        ),
                        child: Text(
                          profile.email,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        strings.experienceLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 10),
                      ExperienceOptions(
                        selectedIndex: _experienceIndex,
                        onSelected: _selectExperience,
                      ),
                    ],
                  ),
                  _ProfileExpansionCard(
                    icon: Icons.flag_rounded,
                    title: strings.careerGoal,
                    subtitle: goalLabel,
                    footer: strings.careerGoalSubtitle,
                    children: [
                      GoalGrid(
                        selectedIndex: _goalIndex,
                        customGoalController: _customGoalController,
                        onSelected: _selectGoal,
                      ),
                    ],
                  ),
                  _ProfileExpansionCard(
                    icon: Icons.credit_card_rounded,
                    title: strings.subscription,
                    subtitle: strings.subscriptionFreeTitle,
                    children: [
                      Text(
                        strings.subscriptionStatusActive,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        strings.subscriptionFreeDetail,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  _ProfileExpansionCard(
                    icon: Icons.lock_outline_rounded,
                    title: strings.privacy,
                    subtitle: strings.privacySubtitle,
                    children: [
                      _ActionRow(
                        icon: Icons.upload_file_rounded,
                        title: strings.exportData,
                        subtitle: strings.exportDataHint,
                        onTap: state.saving ? null : () => _exportData(strings),
                      ),
                      const SizedBox(height: 10),
                      _ActionRow(
                        icon: Icons.delete_outline_rounded,
                        title: strings.deleteAccount,
                        subtitle: strings.deleteAccountWarning,
                        iconColor: LoopColors.danger,
                        onTap: state.saving
                            ? null
                            : () => _confirmDeleteAccount(strings),
                      ),
                    ],
                  ),
                  const _PreferencesPanel(),
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    title: strings.logout,
                    subtitle: strings.logoutConfirmMessage,
                    iconColor: LoopColors.danger,
                    iconBackground: LoopColors.danger.withValues(alpha: 0.12),
                    onTap: () => _confirmSignOut(strings),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileExpansionCard extends StatelessWidget {
  const _ProfileExpansionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
    this.leadingAvatar,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String? footer;
  final String? leadingAvatar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LoopCard(
        padding: EdgeInsets.zero,
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 4,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            leading: leadingAvatar != null
                ? CircleAvatar(
                    radius: 22,
                    backgroundColor: LoopColors.brandGreen,
                    child: Text(
                      leadingAvatar!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  )
                : _IconBadge(icon: icon),
            title: Text(title, style: Theme.of(context).textTheme.titleMedium),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            children: [
              ...children,
              if (footer != null) ...[
                const SizedBox(height: 12),
                Text(
                  footer!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: LoopColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: LoopColors.lightGreen,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Icon(icon, color: LoopColors.brandGreen),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: LoopColors.lightGreen.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: iconColor ?? LoopColors.brandGreen),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: iconColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
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
      ),
    );
  }
}

class _PreferencesPanel extends StatelessWidget {
  const _PreferencesPanel();

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(context);

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: LoopCard(
            padding: EdgeInsets.zero,
            child: Theme(
              data: Theme.of(
                context,
              ).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: 18),
                childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                leading: const _IconBadge(icon: Icons.tune_rounded),
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
                  Text(
                    strings.languageLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
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
                      context.read<SettingsCubit>().setLanguage(
                        selection.first,
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.recruiterLanguageHint,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Divider(),
                  Text(
                    strings.recruiterVoiceLabel,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
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
    required this.onTap,
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
