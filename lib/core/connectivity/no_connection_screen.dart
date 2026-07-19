import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../localization/app_strings.dart';
import '../settings/cubit/settings_state.dart';
import '../settings/data/settings_storage.dart';
import '../theme/loop_colors.dart';
import '../theme/loop_theme.dart';
import '../widgets/loop_card.dart';

class NoConnectionScreen extends StatefulWidget {
  const NoConnectionScreen({
    super.key,
    required this.settingsStorage,
    required this.onRetry,
    this.checking = false,
  });

  final SettingsStorage settingsStorage;
  final VoidCallback onRetry;
  final bool checking;

  @override
  State<NoConnectionScreen> createState() => _NoConnectionScreenState();
}

class _NoConnectionScreenState extends State<NoConnectionScreen> {
  SettingsState _settings = const SettingsState.initial();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await widget.settingsStorage.load();
    if (!mounted) return;
    setState(() => _settings = settings);
  }

  Future<void> _setLanguage(AppLanguage language) async {
    await widget.settingsStorage.saveLanguage(language);
    if (!mounted) return;
    setState(() => _settings = _settings.copyWith(language: language));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings(_settings.language);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: LoopTheme.light,
      darkTheme: LoopTheme.dark,
      themeMode: _settings.themeMode,
      locale: _settings.language.locale,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: LoopColors.surface,
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: PopupMenuButton<AppLanguage>(
                        tooltip: strings.welcomeLanguage,
                        onSelected: _setLanguage,
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
                            onPressed: widget.checking ? null : widget.onRetry,
                            style: FilledButton.styleFrom(
                              backgroundColor: LoopColors.brandGreen,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: Text(
                              widget.checking
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
          );
        },
      ),
    );
  }
}
