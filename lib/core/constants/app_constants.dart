class AppConstants {
  // App Info
  static const String appName = 'SilentVoice AI';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl = 'http://localhost:5000';
  static const String predictEndpoint = '/predict';
  static const int apiTimeout = 30000;

  // Model Configuration
  static const String modelPath = 'assets/models/gesture_model.tflite';
  static const String labelsPath = 'assets/models/gesture_labels.json';
  static const int inputSize = 256; // Model expects 256x256 images
  static const int numChannels = 3;
  static const double confidenceThreshold = 0.5;

  // Camera Configuration
  static const int cameraFrameRate = 15;
  static const double cameraAspectRatio = 4 / 3;

  // TTS Configuration
  static const double defaultSpeechRate = 0.5;
  static const double defaultPitch = 1.0;
  static const double defaultVolume = 1.0;
  static const String defaultLanguage = 'en-US';

  // Database Configuration
  static const String dbName = 'silentvoice.db';
  static const int dbVersion = 1;

  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // Gesture Animation
  static const Duration gestureDisplayDuration = Duration(milliseconds: 800);

  // Mastery Levels
  static const int maxMasteryLevel = 5;
  static const int practiceCountForLevelUp = 5;

  // UI Constants
  static const double borderRadius = 16.0;
  static const double cardPadding = 16.0;
  static const double screenPadding = 20.0;
}
