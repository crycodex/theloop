import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/interview_call/data/services/gemini_config.dart';
import '../cubit/settings_state.dart';

abstract interface class SettingsStorage {
  Future<SettingsState> load();

  Future<void> saveThemeMode(ThemeMode themeMode);

  Future<void> saveLanguage(AppLanguage language);
}

class SharedPreferencesSettingsStorage implements SettingsStorage {
  static const themeModeKey = 'settings_theme_mode';
  static const languageKey = 'settings_language';

  @override
  Future<SettingsState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeMode = _readThemeMode(prefs.getString(themeModeKey));
    final language = _readLanguage(prefs.getString(languageKey));

    return SettingsState(
      themeMode: themeMode,
      language: language,
      recruiterVoice: RecruiterVoice.sadaltager,
    );
  }

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(themeModeKey, _themeModeToString(themeMode));
  }

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(languageKey, language.name);
  }

  ThemeMode _readThemeMode(String? value) => switch (value) {
    'dark' => ThemeMode.dark,
    'system' => ThemeMode.system,
    _ => ThemeMode.light,
  };

  AppLanguage _readLanguage(String? value) => switch (value) {
    'english' => AppLanguage.english,
    _ => AppLanguage.spanish,
  };

  String _themeModeToString(ThemeMode mode) => switch (mode) {
    ThemeMode.dark => 'dark',
    ThemeMode.system => 'system',
    ThemeMode.light => 'light',
  };
}

class InMemorySettingsStorage implements SettingsStorage {
  SettingsState _state = const SettingsState.initial();

  @override
  Future<SettingsState> load() async => _state;

  @override
  Future<void> saveThemeMode(ThemeMode themeMode) async {
    _state = _state.copyWith(themeMode: themeMode);
  }

  @override
  Future<void> saveLanguage(AppLanguage language) async {
    _state = _state.copyWith(language: language);
  }
}
