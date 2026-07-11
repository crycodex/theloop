import 'package:flutter/material.dart';

import '../../../features/interview_call/data/services/gemini_config.dart';

enum AppLanguage {
  spanish(Locale('es'), 'Español'),
  english(Locale('en'), 'English');

  const AppLanguage(this.locale, this.label);

  final Locale locale;
  final String label;
}

class SettingsState {
  const SettingsState({
    required this.themeMode,
    required this.language,
    required this.recruiterVoice,
  });

  const SettingsState.initial()
    : themeMode = ThemeMode.light,
      language = AppLanguage.spanish,
      recruiterVoice = RecruiterVoice.sadaltager;

  final ThemeMode themeMode;
  final AppLanguage language;
  final RecruiterVoice recruiterVoice;

  bool get isDarkMode => themeMode == ThemeMode.dark;

  SettingsState copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    RecruiterVoice? recruiterVoice,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      recruiterVoice: recruiterVoice ?? this.recruiterVoice,
    );
  }
}
