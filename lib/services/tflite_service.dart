// TensorFlow Lite model service for on-device gesture recognition.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

import '../models/prediction_result_model.dart';
import '../core/constants/gesture_labels.dart';

class TFLiteService {
  static final TFLiteService instance = TFLiteService._init();

  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isInitialized = false;

  // Model configuration - MobileNetV2 from Kaggle (sayannath235)
  static const int inputSize = 224; // MobileNetV2 expects 224x224 images
  static const int numChannels = 3;
  static const double confidenceThreshold =
      0.4; // Lower threshold for better detection

  // MobileNetV2 uses simple 0-1 normalization (no ImageNet mean/std needed)

  // Prediction smoothing - exponential moving average
  final List<List<double>> _predictionHistory = [];
  static const int _smoothingWindow = 3;
  static const double _smoothingAlpha = 0.6; // Weight for latest prediction

  TFLiteService._init();

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get available labels
  List<String> get labels => _labels;

  /// Initialize TFLite interpreter
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      debugPrint('🔄 Loading TFLite model from assets...');

      // Load model from assets
      _interpreter = await Interpreter.fromAsset(
        'assets/models/gesture_model.tflite',
      );

      debugPrint('✅ Model file loaded');

      // Load labels - USE MODEL GESTURES ONLY (A-Z + special, no numbers)
      // Numbers are only for UI/Learning/Reverse Mode
      _labels = GestureLabels.modelGestures;
      debugPrint('✅ Labels loaded: ${_labels.length} gestures (model only)');

      // Verify model dimensions
      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);

      debugPrint('📊 Model Info:');
      debugPrint('   Input shape: ${inputTensor.shape}');
      debugPrint('   Input type: ${inputTensor.type}');
      debugPrint('   Output shape: ${outputTensor.shape}');
      debugPrint('   Output type: ${outputTensor.type}');
      debugPrint('   Expected classes: ${_labels.length}');

      _isInitialized = true;
      debugPrint('✅ TFLite model loaded successfully');

      return true;
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading TFLite model: $e');
      debugPrint('Stack trace: $stackTrace');
      _isInitialized = false;
      return false;
    }
  }

  /// Initialize with custom model path
  Future<bool> initializeWithModel(String modelPath) async {
    try {
      final file = File(modelPath);
      if (!await file.exists()) {
        debugPrint('❌ Model file not found: $modelPath');
        return false;
      }

      _interpreter = Interpreter.fromFile(file);
      _labels = GestureLabels.modelGestures; // Use model gestures only
      _isInitialized = true;

      return true;
    } catch (e) {
      debugPrint('❌ Error loading custom model: $e');
      return false;
    }
  }

  /// Predict gesture from image bytes
  Future<PredictionResult?> predictFromBytes(Uint8List imageBytes) async {
    if (!_isInitialized || _interpreter == null) {
      debugPrint('⚠️ TFLite not initialized');
      return null;
    }

    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        debugPrint('❌ Failed to decode image');
        return null;
      }

      return await _runInference(image, isFrontCamera: false);
    } catch (e) {
      debugPrint('❌ Prediction error: $e');
      return null;
    }
  }

  /// Predict gesture from image file
  Future<PredictionResult?> predictFromFile(File imageFile) async {
    if (!_isInitialized || _interpreter == null) {
      return null;
    }

    try {
      final bytes = await imageFile.readAsBytes();
      return await predictFromBytes(bytes);
    } catch (e) {
      debugPrint('❌ Error reading image file: $e');
      return null;
    }
  }

  /// Predict gesture from camera image (YUV format)
  Future<PredictionResult?> predictFromCameraImage(
    Uint8List yPlane,
    Uint8List? uPlane,
    Uint8List? vPlane,
    int width,
    int height,
    int rotation, {
    bool isFrontCamera = false,
  }) async {
    if (!_isInitialized || _interpreter == null) {
      return null;
    }

    try {
      // Convert YUV to RGB
      final image = _convertYUVToImage(yPlane, uPlane, vPlane, width, height);
      if (image == null) return null;

      // Rotate if needed
      var processedImage = _rotateImage(image, rotation);

      // Flip horizontally for front camera to match training data
      if (isFrontCamera) {
        processedImage = img.flipHorizontal(processedImage);
      }

      return await _runInference(processedImage, isFrontCamera: isFrontCamera);
    } catch (e) {
      debugPrint('❌ Camera prediction error: $e');
      return null;
    }
  }

  /// Run inference on preprocessed image
  Future<PredictionResult?> _runInference(img.Image image,
      {bool isFrontCamera = false}) async {
    try {
      // Preprocess image with ImageNet normalization
      final input = _preprocessImage(image);

      // Prepare output buffer
      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final numClasses = outputShape[1];
      final output = List.filled(numClasses, 0.0).reshape([1, numClasses]);

      // Run inference
      _interpreter!.run(input, output);

      // Get results with smoothing
      final probabilities = output[0];

      return _processOutputWithSmoothing(probabilities);
    } catch (e) {
      debugPrint('❌ Inference error: $e');
      return null;
    }
  }

  /// Preprocess image for model input - MobileNetV2 uses 0-1 normalization
  List<List<List<List<double>>>> _preprocessImage(img.Image image) {
    // Resize image with bilinear interpolation for better quality
    final resized = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    // Create input tensor [1, height, width, channels] with simple 0-1 normalization
    final input = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (y) => List.generate(inputSize, (x) {
          final pixel = resized.getPixel(x, y);
          // Simple 0-1 normalization for MobileNetV2
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    );

    return input;
  }

  /// Process model output with smoothing for stable predictions
  PredictionResult _processOutputWithSmoothing(List<double> probabilities) {
    // Add to history for smoothing
    _predictionHistory.add(List<double>.from(probabilities));
    if (_predictionHistory.length > _smoothingWindow) {
      _predictionHistory.removeAt(0);
    }

    // Apply exponential moving average smoothing
    final smoothedProbs = List<double>.filled(probabilities.length, 0.0);

    if (_predictionHistory.length == 1) {
      // First prediction, no smoothing
      for (int i = 0; i < probabilities.length; i++) {
        smoothedProbs[i] = probabilities[i];
      }
    } else {
      // Apply EMA: new_value = alpha * current + (1-alpha) * previous_smoothed
      double totalWeight = 0.0;
      double weight = 1.0;

      for (int h = _predictionHistory.length - 1; h >= 0; h--) {
        for (int i = 0; i < probabilities.length; i++) {
          smoothedProbs[i] += _predictionHistory[h][i] * weight;
        }
        totalWeight += weight;
        weight *= (1 - _smoothingAlpha);
      }

      // Normalize
      for (int i = 0; i < smoothedProbs.length; i++) {
        smoothedProbs[i] /= totalWeight;
      }
    }

    // Find top predictions from smoothed probabilities
    final indexed = smoothedProbs.asMap().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topPredictions = indexed.take(5).map((entry) {
      final label = entry.key < _labels.length ? _labels[entry.key] : 'Unknown';
      return GesturePrediction(
        gesture: label,
        confidence: entry.value,
        index: entry.key,
      );
    }).toList();

    final bestPrediction = topPredictions.first;

    return PredictionResult(
      gesture: bestPrediction.gesture,
      confidence: bestPrediction.confidence,
      topPredictions: topPredictions,
      timestamp: DateTime.now(),
      isConfident: bestPrediction.confidence >= confidenceThreshold,
    );
  }

  /// Clear prediction history (call when stopping detection)
  void clearPredictionHistory() {
    _predictionHistory.clear();
  }

  /// Convert YUV camera image to RGB image - Optimized with correct coefficients
  img.Image? _convertYUVToImage(
    Uint8List yPlane,
    Uint8List? uPlane,
    Uint8List? vPlane,
    int width,
    int height,
  ) {
    try {
      // For faster processing, use grayscale from Y plane only if UV is missing
      if (uPlane == null || vPlane == null) {
        final image = img.Image(width: width, height: height);
        for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
            final yValue = yPlane[y * width + x];
            image.setPixelRgb(x, y, yValue, yValue, yValue);
          }
        }
        return image;
      }

      // Full YUV420 to RGB with correct BT.601 coefficients
      final image = img.Image(width: width, height: height);
      final int uvWidth = width ~/ 2;

      for (int y = 0; y < height; y++) {
        final int yRowStart = y * width;
        final int uvRowStart = (y ~/ 2) * uvWidth;

        for (int x = 0; x < width; x++) {
          final int yIndex = yRowStart + x;
          final int uvIndex = uvRowStart + (x ~/ 2);

          final int yValue = yPlane[yIndex];
          final int uValue = uPlane[uvIndex] - 128;
          final int vValue = vPlane[uvIndex] - 128;

          // BT.601 YUV to RGB conversion (correct coefficients)
          int r = yValue + ((1402 * vValue) >> 10);
          int g = yValue - ((344 * uValue + 714 * vValue) >> 10);
          int b = yValue + ((1772 * uValue) >> 10);

          // Clamp values
          r = r.clamp(0, 255);
          g = g.clamp(0, 255);
          b = b.clamp(0, 255);

          image.setPixelRgb(x, y, r, g, b);
        }
      }

      return image;
    } catch (e) {
      debugPrint('❌ YUV conversion error: $e');
      return null;
    }
  }

  /// Rotate image based on camera rotation
  img.Image _rotateImage(img.Image image, int rotation) {
    switch (rotation) {
      case 90:
        return img.copyRotate(image, angle: 90);
      case 180:
        return img.copyRotate(image, angle: 180);
      case 270:
        return img.copyRotate(image, angle: 270);
      default:
        return image;
    }
  }

  /// Get model info
  Map<String, dynamic> getModelInfo() {
    if (!_isInitialized || _interpreter == null) {
      return {'status': 'not_initialized'};
    }

    final inputTensor = _interpreter!.getInputTensor(0);
    final outputTensor = _interpreter!.getOutputTensor(0);

    return {
      'status': 'initialized',
      'input_shape': inputTensor.shape,
      'input_type': inputTensor.type.toString(),
      'output_shape': outputTensor.shape,
      'output_type': outputTensor.type.toString(),
      'num_classes': _labels.length,
    };
  }

  /// Close interpreter and release resources
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
    _predictionHistory.clear();
    debugPrint('🔒 TFLite interpreter closed');
  }
}

/// Extension for reshaping lists
extension ReshapeExtension on List<double> {
  List<List<double>> reshape(List<int> shape) {
    if (shape.length != 2) {
      throw ArgumentError('Shape must have 2 dimensions');
    }

    final rows = shape[0];
    final cols = shape[1];

    if (length != rows * cols) {
      throw ArgumentError('Cannot reshape list of length $length to $shape');
    }

    return List.generate(rows, (i) => sublist(i * cols, (i + 1) * cols));
  }
}
