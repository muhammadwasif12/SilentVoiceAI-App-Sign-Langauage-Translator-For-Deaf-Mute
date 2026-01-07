/// SilentVoice AI - Gesture Detection Provider
/// ============================================
/// Riverpod provider for real-time gesture detection state management
library;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

import '../models/prediction_result_model.dart';
import '../services/gesture_detection_service.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';

/// Detection state enum
enum DetectionState {
  idle,
  detecting,
  paused,
  error,
}

/// Gesture detection state model
class GestureDetectionStateModel {
  final DetectionState state;
  final PredictionResult? currentPrediction;
  final String detectedText;
  final bool isProcessing;
  final String? errorMessage;
  final int frameCount;
  final double fps;

  const GestureDetectionStateModel({
    this.state = DetectionState.idle,
    this.currentPrediction,
    this.detectedText = '',
    this.isProcessing = false,
    this.errorMessage,
    this.frameCount = 0,
    this.fps = 0.0,
  });

  GestureDetectionStateModel copyWith({
    DetectionState? state,
    PredictionResult? currentPrediction,
    String? detectedText,
    bool? isProcessing,
    String? errorMessage,
    int? frameCount,
    double? fps,
  }) {
    return GestureDetectionStateModel(
      state: state ?? this.state,
      currentPrediction: currentPrediction ?? this.currentPrediction,
      detectedText: detectedText ?? this.detectedText,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      frameCount: frameCount ?? this.frameCount,
      fps: fps ?? this.fps,
    );
  }
}

/// Gesture detection provider
class GestureDetectionNotifier
    extends StateNotifier<GestureDetectionStateModel> {
  final GestureDetectionService _detectionService;
  final Ref _ref;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();

  bool _isInitialized = false;
  DateTime? _lastFrameTime;
  int _frameCounter = 0;
  String? _lastDetectedGesture;
  DateTime? _lastGestureTime;

  // Frame throttling - process max 10 frames per second for smoother detection
  DateTime? _lastProcessedTime;
  static const int _minFrameIntervalMs = 100; // 100ms between frames (10 FPS)
  bool _isFrameBeingProcessed = false;

  GestureDetectionNotifier(this._detectionService, this._ref)
      : super(const GestureDetectionStateModel()) {
    _initializeTTS();
  }

  /// Initialize TTS
  Future<void> _initializeTTS() async {
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
  }

  /// Initialize detection service
  Future<void> initialize() async {
    try {
      if (_isInitialized) return;

      await _detectionService.initialize();
      _isInitialized = true;

      state = state.copyWith(
        state: DetectionState.idle,
        errorMessage: null,
      );

      debugPrint('✅ Gesture detection initialized');
    } catch (e) {
      state = state.copyWith(
        state: DetectionState.error,
        errorMessage: 'Failed to initialize: $e',
      );
      debugPrint('❌ Gesture detection initialization failed: $e');
    }
  }

  /// Start detection
  void startDetection() {
    if (!_isInitialized) {
      debugPrint('⚠️ Cannot start detection: not initialized');
      return;
    }

    state = state.copyWith(state: DetectionState.detecting);
    _frameCounter = 0;
    _lastFrameTime = DateTime.now();
    debugPrint('▶️ Detection started');
  }

  /// Stop detection
  void stopDetection() {
    state = state.copyWith(state: DetectionState.paused);
    debugPrint('⏸️ Detection paused');
  }

  /// Process camera frame with throttling for smooth performance
  Future<void> processFrame(CameraImage image,
      {int rotation = 90, bool isFrontCamera = false}) async {
    if (state.state != DetectionState.detecting) {
      return;
    }

    // Frame throttling - skip if processing or too soon
    if (_isFrameBeingProcessed) return;

    final now = DateTime.now();
    if (_lastProcessedTime != null) {
      final elapsed = now.difference(_lastProcessedTime!).inMilliseconds;
      if (elapsed < _minFrameIntervalMs) return; // Skip frame
    }

    _isFrameBeingProcessed = true;
    _lastProcessedTime = now;

    state = state.copyWith(isProcessing: true);

    try {
      // Get settings
      final settings = _ref.read(settingsProvider);
      final confidenceThreshold = settings.confidenceThreshold;

      // Calculate FPS
      _frameCounter++;
      final now = DateTime.now();
      if (_lastFrameTime != null) {
        final elapsed = now.difference(_lastFrameTime!).inMilliseconds;
        if (elapsed > 1000) {
          final fps = (_frameCounter * 1000) / elapsed;
          state = state.copyWith(fps: fps);
          _frameCounter = 0;
          _lastFrameTime = now;
        }
      }

      // Predict gesture with front camera flag for proper mirroring
      final prediction = await _detectionService.predictFromCameraImage(
        image,
        rotation: rotation,
        isFrontCamera: isFrontCamera,
      );

      if (prediction != null) {
        // Update current prediction regardless of confidence
        state = state.copyWith(
          currentPrediction: prediction,
          frameCount: state.frameCount + 1,
        );

        // Add to detected text if confidence meets threshold
        if (prediction.confidence >= confidenceThreshold) {
          // Prevent duplicate detection (same gesture within 500ms)
          final timeSinceLastGesture = _lastGestureTime != null
              ? now.difference(_lastGestureTime!).inMilliseconds
              : 1000;

          if (_lastDetectedGesture != prediction.gesture ||
              timeSinceLastGesture > 500) {
            _addGestureToText(prediction.gesture);
            _lastDetectedGesture = prediction.gesture;
            _lastGestureTime = now;

            // Play sound effect if enabled
            if (settings.soundEffectsEnabled) {
              _playDetectionSound();
            }

            // Trigger vibration if enabled
            if (settings.vibrationEnabled) {
              _triggerVibration();
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ Frame processing error: $e');
    } finally {
      _isFrameBeingProcessed = false;
      state = state.copyWith(isProcessing: false);
    }
  }

  /// Add gesture to detected text
  void _addGestureToText(String gesture) {
    String newText = state.detectedText;

    final gestureLower = gesture.toLowerCase();

    if (gestureLower == 'space') {
      newText += ' ';
    } else if (gestureLower == 'del' || gestureLower == 'delete') {
      // Handle both 'del' (model output) and 'delete' for compatibility
      if (newText.isNotEmpty) {
        newText = newText.substring(0, newText.length - 1);
      }
    } else if (gestureLower != 'nothing') {
      newText += gesture;
    }

    state = state.copyWith(detectedText: newText);

    // Save to history
    if (newText.isNotEmpty && newText.length % 5 == 0) {
      _saveToHistory(newText);
    }
  }

  /// Save to history database
  Future<void> _saveToHistory(String text) async {
    try {
      await DatabaseService.instance.addHistory(text);
    } catch (e) {
      debugPrint('❌ Failed to save history: $e');
    }
  }

  /// Speak current text
  Future<void> speakCurrentText() async {
    if (state.detectedText.isNotEmpty) {
      await _tts.speak(state.detectedText);
    }
  }

  /// Clear detected text
  void clearText() {
    state = state.copyWith(detectedText: '');
  }

  /// Play detection sound
  Future<void> _playDetectionSound() async {
    try {
      // Try to play sound, but don't fail if file is missing
      await _audioPlayer.play(AssetSource('sounds/detection.mp3'));
    } catch (e) {
      // Silently ignore sound errors - sound is optional
      debugPrint('⚠️ Sound playback skipped (file may be missing): $e');
    }
  }

  /// Trigger vibration
  Future<void> _triggerVibration() async {
    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        await Vibration.vibrate(duration: 100);
      }
    } catch (e) {
      debugPrint('❌ Vibration error: $e');
    }
  }

  /// Dispose
  @override
  void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
    _detectionService.dispose();
    super.dispose();
  }
}

/// Provider instance
final gestureDetectionProvider =
    StateNotifierProvider<GestureDetectionNotifier, GestureDetectionStateModel>(
  (ref) => GestureDetectionNotifier(GestureDetectionService.instance, ref),
);
