import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/navigation/app_shell.dart';
import '../../../core/theme/loop_colors.dart';
import '../../../core/widgets/loop_card.dart';
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

        return ShellPagePadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Perfil', style: Theme.of(context).textTheme.displaySmall),
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
                        profile.target,
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
            title: 'Objetivo profesional',
            subtitle: 'Rol, nivel, empresas e idioma',
          ),
          _SettingsTile(
            icon: Icons.credit_card_rounded,
            title: 'Suscripción',
            subtitle: profile.plan,
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacidad',
            subtitle: 'Exportar datos o eliminar cuenta',
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            title: 'Preferencias',
            subtitle: 'Tema, notificaciones e idioma',
          ),
        ],
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
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LoopCard(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: LoopColors.lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: LoopColors.brandGreen),
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
            const Icon(Icons.chevron_right_rounded, color: LoopColors.textMuted),
          ],
        ),
      ),
    );
  }
}
