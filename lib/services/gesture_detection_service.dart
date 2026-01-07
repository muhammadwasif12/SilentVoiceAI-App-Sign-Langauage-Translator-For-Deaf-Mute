/// SilentVoice AI - Gesture Detection Service
/// ==========================================
/// Main service for real-time gesture detection from camera
library;

import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

import '../models/prediction_result_model.dart';
import 'tflite_service.dart';

class GestureDetectionService {
  static final GestureDetectionService instance =
      GestureDetectionService._init();

  final TFLiteService _tfliteService = TFLiteService.instance;
  bool _isInitialized = false;

  GestureDetectionService._init();

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the detection service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔄 Initializing Gesture Detection Service...');

      // Initialize TFLite service
      final success = await _tfliteService.initialize();

      if (!success) {
        throw Exception('Failed to initialize TFLite service');
      }

      _isInitialized = true;
      debugPrint('✅ Gesture Detection Service initialized');
    } catch (e) {
      debugPrint('❌ Gesture Detection Service initialization failed: $e');
      rethrow;
    }
  }

  /// Predict gesture from camera image
  Future<PredictionResult?> predictFromCameraImage(
    CameraImage image, {
    int rotation = 90,
    bool isFrontCamera = false,
  }) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Gesture Detection Service not initialized');
      return null;
    }

    try {
      // Extract Y plane (grayscale) from camera image
      final yPlane = image.planes[0].bytes;
      final width = image.width;
      final height = image.height;

      // Get U and V planes if available
      Uint8List? uPlane;
      Uint8List? vPlane;

      if (image.planes.length > 1) {
        uPlane = image.planes[1].bytes;
      }
      if (image.planes.length > 2) {
        vPlane = image.planes[2].bytes;
      }

      // Predict using TFLite with front camera flag
      final prediction = await _tfliteService.predictFromCameraImage(
        yPlane,
        uPlane,
        vPlane,
        width,
        height,
        rotation,
        isFrontCamera: isFrontCamera,
      );

      return prediction;
    } catch (e) {
      debugPrint('❌ Camera prediction error: $e');
      return null;
    }
  }

  /// Predict gesture from image bytes
  Future<PredictionResult?> predictFromBytes(Uint8List imageBytes) async {
    if (!_isInitialized) {
      debugPrint('⚠️ Gesture Detection Service not initialized');
      return null;
    }

    try {
      return await _tfliteService.predictFromBytes(imageBytes);
    } catch (e) {
      debugPrint('❌ Bytes prediction error: $e');
      return null;
    }
  }

  /// Get available gesture labels
  List<String> getLabels() {
    return _tfliteService.labels;
  }

  /// Get model information
  Map<String, dynamic> getModelInfo() {
    return _tfliteService.getModelInfo();
  }

  /// Dispose resources
  void dispose() {
    _tfliteService.dispose();
    _isInitialized = false;
    debugPrint('🔒 Gesture Detection Service disposed');
  }
}
