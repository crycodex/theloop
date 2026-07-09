import 'package:flutter/material.dart';

enum AppLanguage {
  spanish(Locale('es'), 'Español'),
  english(Locale('en'), 'English');

  const AppLanguage(this.locale, this.label);

  final Locale locale;
  final String label;
}

class SettingsState {
  const SettingsState({required this.themeMode, required this.language});

  const SettingsState.initial()
    : themeMode = ThemeMode.light,
      language = AppLanguage.spanish;

  final ThemeMode themeMode;
  final AppLanguage language;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  SettingsState copyWith({ThemeMode? themeMode, AppLanguage? language}) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }
}
