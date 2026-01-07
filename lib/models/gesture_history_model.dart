/// SilentVoice AI - Gesture History Model
/// =======================================
/// Model for storing gesture detection history.
library;

import 'package:equatable/equatable.dart';

class GestureHistoryModel extends Equatable {
  final int? id;
  final String gesture;
  final double confidence;
  final DateTime timestamp;
  final String? sessionId;
  final String mode;

  const GestureHistoryModel({
    this.id,
    required this.gesture,
    required this.confidence,
    required this.timestamp,
    this.sessionId,
    this.mode = 'camera',
  });

  @override
  List<Object?> get props => [
    id,
    gesture,
    confidence,
    timestamp,
    sessionId,
    mode,
  ];

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gesture': gesture,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      'session_id': sessionId,
      'mode': mode,
    };
  }

  factory GestureHistoryModel.fromMap(Map<String, dynamic> map) {
    return GestureHistoryModel(
      id: map['id'] as int?,
      gesture: map['gesture'] as String,
      confidence: (map['confidence'] as num).toDouble(),
      timestamp: DateTime.parse(map['timestamp'] as String),
      sessionId: map['session_id'] as String?,
      mode: map['mode'] as String? ?? 'camera',
    );
  }

  GestureHistoryModel copyWith({
    int? id,
    String? gesture,
    double? confidence,
    DateTime? timestamp,
    String? sessionId,
    String? mode,
  }) {
    return GestureHistoryModel(
      id: id ?? this.id,
      gesture: gesture ?? this.gesture,
      confidence: confidence ?? this.confidence,
      timestamp: timestamp ?? this.timestamp,
      sessionId: sessionId ?? this.sessionId,
      mode: mode ?? this.mode,
    );
  }

  /// Get formatted timestamp
  String get formattedTime {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}';
  }

  /// Get formatted date
  String get formattedDate {
    return '${timestamp.year}-'
        '${timestamp.month.toString().padLeft(2, '0')}-'
        '${timestamp.day.toString().padLeft(2, '0')}';
  }

  /// Get confidence percentage string
  String get confidenceString => '${(confidence * 100).toStringAsFixed(1)}%';
}
