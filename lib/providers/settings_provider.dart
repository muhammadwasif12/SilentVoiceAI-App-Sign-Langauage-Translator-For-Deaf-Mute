/// SilentVoice AI - Settings Provider
/// ===================================
/// Riverpod provider for app settings.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App settings model
class AppSettings {
  final ThemeMode themeMode;
  final String language;
  final double speechRate;
  final double volume;
  final bool ttsEnabled;
  final bool soundEffectsEnabled;
  final bool vibrationEnabled;
  final String backendUrl;
  final bool useOnlineModel;
  final double confidenceThreshold;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = 'en',
    this.speechRate = 0.5,
    this.volume = 1.0,
    this.ttsEnabled = true,
    this.soundEffectsEnabled = true,
    this.vibrationEnabled = true,
    this.backendUrl = 'http://localhost:5000',
    this.useOnlineModel = false,
    this.confidenceThreshold = 0.5,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? language,
    double? speechRate,
    double? volume,
    bool? ttsEnabled,
    bool? soundEffectsEnabled,
    bool? vibrationEnabled,
    String? backendUrl,
    bool? useOnlineModel,
    double? confidenceThreshold,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      volume: volume ?? this.volume,
      ttsEnabled: ttsEnabled ?? this.ttsEnabled,
      soundEffectsEnabled: soundEffectsEnabled ?? this.soundEffectsEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      backendUrl: backendUrl ?? this.backendUrl,
      useOnlineModel: useOnlineModel ?? this.useOnlineModel,
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
    );
  }
}

/// Settings notifier
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings()) {
    _loadSettings();
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    state = AppSettings(
      themeMode: ThemeMode.values[prefs.getInt('themeMode') ?? 0],
      language: prefs.getString('language') ?? 'en',
      speechRate: prefs.getDouble('speechRate') ?? 0.5,
      volume: prefs.getDouble('volume') ?? 1.0,
      ttsEnabled: prefs.getBool('ttsEnabled') ?? true,
      soundEffectsEnabled: prefs.getBool('soundEffectsEnabled') ?? true,
      vibrationEnabled: prefs.getBool('vibrationEnabled') ?? true,
      backendUrl: prefs.getString('backendUrl') ?? 'http://localhost:5000',
      useOnlineModel: prefs.getBool('useOnlineModel') ?? false,
      confidenceThreshold: prefs.getDouble('confidenceThreshold') ?? 0.5,
    );
  }

  /// Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt('themeMode', state.themeMode.index);
    await prefs.setString('language', state.language);
    await prefs.setDouble('speechRate', state.speechRate);
    await prefs.setDouble('volume', state.volume);
    await prefs.setBool('ttsEnabled', state.ttsEnabled);
    await prefs.setBool('soundEffectsEnabled', state.soundEffectsEnabled);
    await prefs.setBool('vibrationEnabled', state.vibrationEnabled);
    await prefs.setString('backendUrl', state.backendUrl);
    await prefs.setBool('useOnlineModel', state.useOnlineModel);
    await prefs.setDouble('confidenceThreshold', state.confidenceThreshold);
  }

  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _saveSettings();
  }

  /// Set language
  void setLanguage(String language) {
    state = state.copyWith(language: language);
    _saveSettings();
  }

  /// Set speech rate
  void setSpeechRate(double rate) {
    state = state.copyWith(speechRate: rate.clamp(0.1, 1.0));
    _saveSettings();
  }

  /// Set volume
  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
    _saveSettings();
  }

  /// Toggle TTS
  void toggleTTS() {
    state = state.copyWith(ttsEnabled: !state.ttsEnabled);
    _saveSettings();
  }

  /// Toggle sound effects
  void toggleSoundEffects() {
    state = state.copyWith(soundEffectsEnabled: !state.soundEffectsEnabled);
    _saveSettings();
  }

  /// Toggle vibration
  void toggleVibration() {
    state = state.copyWith(vibrationEnabled: !state.vibrationEnabled);
    _saveSettings();
  }

  /// Set backend URL
  void setBackendUrl(String url) {
    state = state.copyWith(backendUrl: url);
    _saveSettings();
  }

  /// Toggle online model
  void toggleOnlineModel() {
    state = state.copyWith(useOnlineModel: !state.useOnlineModel);
    _saveSettings();
  }

  /// Set confidence threshold
  void setConfidenceThreshold(double threshold) {
    state = state.copyWith(confidenceThreshold: threshold.clamp(0.1, 0.9));
    _saveSettings();
  }

  /// Reset to defaults
  void resetToDefaults() {
    state = const AppSettings();
    _saveSettings();
  }
}

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>(
  (ref) => SettingsNotifier(),
);

/// Theme mode provider (convenience)
final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(settingsProvider).themeMode;
});

/// TTS enabled provider (convenience)
final ttsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).ttsEnabled;
});
