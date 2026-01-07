/// SilentVoice AI - Prediction Result Model
/// =========================================
/// Model for gesture prediction results.
library;

import 'package:equatable/equatable.dart';

/// Single gesture prediction
class GesturePrediction extends Equatable {
  final String gesture;
  final double confidence;
  final int index;

  const GesturePrediction({
    required this.gesture,
    required this.confidence,
    required this.index,
  });

  /// Confidence as percentage
  double get confidencePercent => confidence * 100;

  /// Formatted confidence string
  String get confidenceString => '${confidencePercent.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [gesture, confidence, index];

  Map<String, dynamic> toMap() {
    return {'gesture': gesture, 'confidence': confidence, 'index': index};
  }

  factory GesturePrediction.fromMap(Map<String, dynamic> map) {
    return GesturePrediction(
      gesture: map['gesture'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      index: map['index'] ?? -1,
    );
  }
}

/// Complete prediction result
class PredictionResult extends Equatable {
  final String gesture;
  final double confidence;
  final List<GesturePrediction> topPredictions;
  final DateTime timestamp;
  final bool isConfident;

  const PredictionResult({
    required this.gesture,
    required this.confidence,
    required this.topPredictions,
    required this.timestamp,
    required this.isConfident,
  });

  /// Empty prediction result
  static PredictionResult empty() {
    return PredictionResult(
      gesture: '',
      confidence: 0.0,
      topPredictions: [],
      timestamp: DateTime.now(),
      isConfident: false,
    );
  }

  /// Check if result is valid
  bool get isValid => gesture.isNotEmpty && confidence > 0;

  /// Display gesture (same as gesture for simple model)
  String get displayGesture => gesture;

  /// Confidence as percentage
  double get confidencePercent => confidence * 100;

  /// Formatted confidence string
  String get confidenceString => '${confidencePercent.toStringAsFixed(1)}%';

  @override
  List<Object?> get props => [
        gesture,
        confidence,
        topPredictions,
        timestamp,
        isConfident,
      ];

  Map<String, dynamic> toMap() {
    return {
      'gesture': gesture,
      'confidence': confidence,
      'top_predictions': topPredictions.map((p) => p.toMap()).toList(),
      'timestamp': timestamp.toIso8601String(),
      'is_confident': isConfident,
    };
  }

  factory PredictionResult.fromMap(Map<String, dynamic> map) {
    return PredictionResult(
      gesture: map['gesture'] ?? '',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      topPredictions: (map['top_predictions'] as List?)
              ?.map((p) => GesturePrediction.fromMap(p))
              .toList() ??
          [],
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
      isConfident: map['is_confident'] ?? false,
    );
  }

  PredictionResult copyWith({
    String? gesture,
    double? confidence,
    List<GesturePrediction>? topPredictions,
    DateTime? timestamp,
    bool? isConfident,
  }) {
    return PredictionResult(
      gesture: gesture ?? this.gesture,
      confidence: confidence ?? this.confidence,
      topPredictions: topPredictions ?? this.topPredictions,
      timestamp: timestamp ?? this.timestamp,
      isConfident: isConfident ?? this.isConfident,
    );
  }
}
