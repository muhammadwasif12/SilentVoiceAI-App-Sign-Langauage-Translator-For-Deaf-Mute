/// SilentVoice AI - TTS Service
/// =============================
/// Text-to-Speech service for speaking detected gestures.
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TTSService {
  static final TTSService instance = TTSService._init();

  final FlutterTts _flutterTts = FlutterTts();

  TtsState _ttsState = TtsState.stopped;
  String? _lastSpokenText;
  bool _isInitialized = false;
  bool _isEnabled = true;

  // Settings
  double _speechRate = 0.5;
  double _volume = 1.0;
  double _pitch = 1.0;
  String _language = 'en-US';

  TTSService._init();

  /// Get current TTS state
  TtsState get state => _ttsState;

  /// Check if TTS is speaking
  bool get isSpeaking => _ttsState == TtsState.playing;

  /// Get last spoken text
  String? get lastSpokenText => _lastSpokenText;

  /// Initialize TTS service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Set up handlers
      _flutterTts.setStartHandler(() {
        _ttsState = TtsState.playing;
        debugPrint('🔊 TTS started');
      });

      _flutterTts.setCompletionHandler(() {
        _ttsState = TtsState.stopped;
        debugPrint('🔇 TTS completed');
      });

      _flutterTts.setCancelHandler(() {
        _ttsState = TtsState.stopped;
        debugPrint('⏹️ TTS cancelled');
      });

      _flutterTts.setErrorHandler((msg) {
        _ttsState = TtsState.stopped;
        debugPrint('❌ TTS error: $msg');
      });

      _flutterTts.setPauseHandler(() {
        _ttsState = TtsState.paused;
      });

      _flutterTts.setContinueHandler(() {
        _ttsState = TtsState.continued;
      });

      // Configure TTS
      await _flutterTts.setLanguage(_language);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_volume);
      await _flutterTts.setPitch(_pitch);

      // Check if language is available
      final isAvailable = await _flutterTts.isLanguageAvailable(_language);
      if (!isAvailable) {
        debugPrint('⚠️ Language $_language not available, using default');
      }

      _isInitialized = true;
      debugPrint('✅ TTS initialized');

      return true;
    } catch (e) {
      debugPrint('❌ TTS initialization error: $e');
      return false;
    }
  }

  /// Set enabled state
  void setEnabled(bool enabled) {
    _isEnabled = enabled;
    if (!enabled) {
      stop();
    }
  }

  /// Speak text
  Future<void> speak(String text) async {
    if (!_isEnabled) return;

    if (!_isInitialized) {
      await initialize();
    }

    if (text.isEmpty) return;

    try {
      // Don't repeat the same text immediately
      if (_lastSpokenText == text && _ttsState == TtsState.playing) {
        return;
      }

      // Stop any current speech
      if (_ttsState == TtsState.playing) {
        await stop();
      }

      _lastSpokenText = text;
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('❌ TTS speak error: $e');
    }
  }

  /// Speak gesture with formatting
  Future<void> speakGesture(String gesture) async {
    // Format gesture name for speech
    final formattedText = _formatGestureForSpeech(gesture);
    await speak(formattedText);
  }

  /// Speak only if different from last spoken
  Future<void> speakIfNew(String text) async {
    if (text != _lastSpokenText) {
      await speak(text);
    }
  }

  /// Format gesture name for natural speech
  String _formatGestureForSpeech(String gesture) {
    // Handle single letters
    if (gesture.length == 1 && RegExp(r'[A-Z]').hasMatch(gesture)) {
      return gesture.toLowerCase();
    }

    // Handle numbers
    if (RegExp(r'^\d+$').hasMatch(gesture)) {
      return gesture;
    }

    // Handle compound words with underscores
    final formatted =
        gesture.replaceAll('_', ' ').replaceAll('-', ' ').toLowerCase();

    return formatted;
  }

  /// Stop speaking
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _ttsState = TtsState.stopped;
    } catch (e) {
      debugPrint('❌ TTS stop error: $e');
    }
  }

  /// Pause speaking
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
      _ttsState = TtsState.paused;
    } catch (e) {
      debugPrint('❌ TTS pause error: $e');
    }
  }

  /// Set speech rate (0.0 - 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  /// Set volume (0.0 - 1.0)
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_volume);
  }

  /// Set pitch (0.5 - 2.0)
  Future<void> setPitch(double pitch) async {
    _pitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_pitch);
  }

  /// Set language
  Future<bool> setLanguage(String languageCode) async {
    try {
      final isAvailable = await _flutterTts.isLanguageAvailable(languageCode);
      if (isAvailable) {
        await _flutterTts.setLanguage(languageCode);
        _language = languageCode;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('❌ Error setting language: $e');
      return false;
    }
  }

  /// Get available languages
  Future<List<String>> getAvailableLanguages() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return List<String>.from(languages);
    } catch (e) {
      debugPrint('❌ Error getting languages: $e');
      return [];
    }
  }

  /// Get available voices
  Future<List<Map<String, String>>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices;
      return List<Map<String, String>>.from(
        voices.map((v) => Map<String, String>.from(v)),
      );
    } catch (e) {
      debugPrint('❌ Error getting voices: $e');
      return [];
    }
  }

  /// Set voice
  Future<void> setVoice(Map<String, String> voice) async {
    try {
      await _flutterTts.setVoice(voice);
    } catch (e) {
      debugPrint('❌ Error setting voice: $e');
    }
  }

  /// Get current settings
  Map<String, dynamic> getSettings() {
    return {
      'speechRate': _speechRate,
      'volume': _volume,
      'pitch': _pitch,
      'language': _language,
      'isInitialized': _isInitialized,
    };
  }

  /// Apply settings from map
  Future<void> applySettings(Map<String, dynamic> settings) async {
    if (settings.containsKey('speechRate')) {
      await setSpeechRate(settings['speechRate']);
    }
    if (settings.containsKey('volume')) {
      await setVolume(settings['volume']);
    }
    if (settings.containsKey('pitch')) {
      await setPitch(settings['pitch']);
    }
    if (settings.containsKey('language')) {
      await setLanguage(settings['language']);
    }
  }

  /// Dispose TTS service
  void dispose() {
    _flutterTts.stop();
    _isInitialized = false;
  }
}
