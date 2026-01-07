/// SilentVoice AI - Learning Progress Model
/// =========================================
/// Model for tracking user's learning progress.

library;

import 'package:equatable/equatable.dart';

class LearningProgressModel extends Equatable {
  final int? id;
  final String gesture;
  final int timesPracticed;
  final int timesCorrect;
  final DateTime? lastPracticed;
  final int masteryLevel; // 0-5 scale
  final int streak;

  const LearningProgressModel({
    this.id,
    required this.gesture,
    this.timesPracticed = 0,
    this.timesCorrect = 0,
    this.lastPracticed,
    this.masteryLevel = 0,
    this.streak = 0,
  });

  /// Accuracy percentage
  double get accuracy {
    if (timesPracticed == 0) return 0.0;
    return (timesCorrect / timesPracticed) * 100;
  }

  /// Is gesture mastered (mastery level >= 5)
  bool get isMastered => masteryLevel >= 5;

  /// Progress percentage (0-100)
  int get progressPercentage => (masteryLevel * 20).clamp(0, 100);

  /// Create from database map
  factory LearningProgressModel.fromMap(Map<String, dynamic> map) {
    return LearningProgressModel(
      id: map['id'] as int?,
      gesture: map['gesture'] as String,
      timesPracticed: map['times_practiced'] as int? ?? 0,
      timesCorrect: map['times_correct'] as int? ?? 0,
      lastPracticed: map['last_practiced'] != null
          ? DateTime.parse(map['last_practiced'] as String)
          : null,
      masteryLevel: map['mastery_level'] as int? ?? 0,
      streak: map['streak'] as int? ?? 0,
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'gesture': gesture,
      'times_practiced': timesPracticed,
      'times_correct': timesCorrect,
      'last_practiced': lastPracticed?.toIso8601String(),
      'mastery_level': masteryLevel,
      'streak': streak,
    };
  }

  /// Create a copy with updated fields
  LearningProgressModel copyWith({
    int? id,
    String? gesture,
    int? timesPracticed,
    int? timesCorrect,
    DateTime? lastPracticed,
    int? masteryLevel,
    int? streak,
  }) {
    return LearningProgressModel(
      id: id ?? this.id,
      gesture: gesture ?? this.gesture,
      timesPracticed: timesPracticed ?? this.timesPracticed,
      timesCorrect: timesCorrect ?? this.timesCorrect,
      lastPracticed: lastPracticed ?? this.lastPracticed,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      streak: streak ?? this.streak,
    );
  }

  @override
  List<Object?> get props => [
        id,
        gesture,
        timesPracticed,
        timesCorrect,
        lastPracticed,
        masteryLevel,
        streak,
      ];

  @override
  String toString() {
    return 'LearningProgressModel(id: $id, gesture: $gesture, '
        'timesPracticed: $timesPracticed, timesCorrect: $timesCorrect, '
        'masteryLevel: $masteryLevel, streak: $streak)';
  }
}
