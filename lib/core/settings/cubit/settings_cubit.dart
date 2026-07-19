import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../features/interview_call/data/services/gemini_config.dart';
import '../data/settings_storage.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._storage, {SettingsState? initialState})
    : super(initialState ?? const SettingsState.initial());

  final SettingsStorage _storage;

  void setDarkMode(bool enabled) {
    final themeMode = enabled ? ThemeMode.dark : ThemeMode.light;
    emit(state.copyWith(themeMode: themeMode));
    _storage.saveThemeMode(themeMode);
  }

  void setLanguage(AppLanguage language) {
    emit(state.copyWith(language: language));
    _storage.saveLanguage(language);
  }

  void setRecruiterVoice(RecruiterVoice voice) {
    emit(state.copyWith(recruiterVoice: voice));
  }
}
