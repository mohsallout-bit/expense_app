// lib/providers/settings_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsState {
  final String language;
  final Color appColor;

  SettingsState({required this.language, required this.appColor});

  SettingsState copyWith({String? language, Color? appColor}) {
    return SettingsState(
      language: language ?? this.language,
      appColor: appColor ?? this.appColor,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier()
    : super(SettingsState(language: 'en', appColor: Colors.blue));

  void updateLanguage(String language) {
    state = state.copyWith(language: language);
  }

  void updateAppColor(Color color) {
    state = state.copyWith(appColor: color);
  }

  void saveSettings() {
    // Save the current settings to persistent storage (e.g., Hive or SharedPreferences)
    // This is a placeholder implementation
    print(
      'Settings saved: Language - ${state.language}, AppColor - ${state.appColor}',
    );
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
