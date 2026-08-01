import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qwe1/data/sources/local/secure_storage.dart';

// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.system;
});

// Biometric enabled provider
final biometricEnabledProvider = StateProvider<bool>((ref) => false);

// Read-only mode provider (global default)
final readOnlyModeProvider = StateProvider<bool>((ref) => false);

// Settings notifier
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref);
});

class SettingsState {
  final ThemeMode themeMode;
  final bool biometricEnabled;
  final bool readOnlyMode;
  final String fontSize;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.biometricEnabled = false,
    this.readOnlyMode = false,
    this.fontSize = 'medium',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    bool? biometricEnabled,
    bool? readOnlyMode,
    String? fontSize,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      readOnlyMode: readOnlyMode ?? this.readOnlyMode,
      fontSize: fontSize ?? this.fontSize,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this.ref) : super(SettingsState()) {
    _loadSettings();
  }

  final Ref ref;

  Future<void> _loadSettings() async {
    final storage = ref.read(secureStorageProvider);
    final themeMode = await storage.getThemeMode();
    final biometric = await storage.getBiometricEnabled();

    state = SettingsState(
      themeMode: _themeModeFromString(themeMode),
      biometricEnabled: biometric,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveThemeMode(mode.name);
    state = state.copyWith(themeMode: mode);
    ref.read(themeModeProvider.notifier).state = mode;
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveBiometricEnabled(enabled);
    state = state.copyWith(biometricEnabled: enabled);
    ref.read(biometricEnabledProvider.notifier).state = enabled;
  }

  Future<void> setReadOnlyMode(bool enabled) async {
    state = state.copyWith(readOnlyMode: enabled);
    ref.read(readOnlyModeProvider.notifier).state = enabled;
  }

  ThemeMode _themeModeFromString(String? mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

// Secure storage provider (placeholder)
final secureStorageProvider = Provider<SecureStorage>((ref) {
  throw UnimplementedError('Secure storage not initialized');
});
