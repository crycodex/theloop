import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState.initial());

  void setDarkMode(bool enabled) {
    emit(state.copyWith(themeMode: enabled ? ThemeMode.dark : ThemeMode.light));
  }

  void setLanguage(AppLanguage language) {
    emit(state.copyWith(language: language));
  }
}
