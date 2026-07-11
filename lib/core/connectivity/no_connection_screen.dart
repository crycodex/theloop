import 'package:flutter/material.dart';

import '../localization/app_strings.dart';
import '../settings/cubit/settings_state.dart';
import '../theme/loop_colors.dart';
import '../theme/loop_theme.dart';
import '../widgets/loop_card.dart';

class NoConnectionScreen extends StatelessWidget {
  const NoConnectionScreen({
    super.key,
    required this.settings,
    required this.onRetry,
    this.checking = false,
  });

  final SettingsState settings;
  final VoidCallback onRetry;
  final bool checking;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(settings.language);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LoopTheme.light,
      darkTheme: LoopTheme.dark,
      themeMode: settings.themeMode,
      locale: settings.language.locale,
      home: Scaffold(
        backgroundColor: LoopColors.surface,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                LoopCard(
                  color: LoopColors.lightGreen,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(
                        Icons.wifi_off_rounded,
                        size: 64,
                        color: LoopColors.brandGreen.withValues(alpha: 0.85),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        strings.noWifiTitle,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        strings.noWifiBody,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        onPressed: checking ? null : onRetry,
                        style: FilledButton.styleFrom(
                          backgroundColor: LoopColors.brandGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          checking
                              ? strings.noWifiChecking
                              : strings.noWifiReconnect,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
