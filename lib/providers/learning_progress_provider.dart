// Create this file: lib/domain/providers/learning_progress_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_service.dart';
import '../models/learning_progress_model.dart';

/// Learning Progress State
class LearningProgressState {
  final Map<String, LearningProgressModel> progressMap;
  final bool isLoading;
  final String? error;

  LearningProgressState({
    this.progressMap = const {},
    this.isLoading = false,
    this.error,
  });

  LearningProgressState copyWith({
    Map<String, LearningProgressModel>? progressMap,
    bool? isLoading,
    String? error,
  }) {
    return LearningProgressState(
      progressMap: progressMap ?? this.progressMap,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Learning Progress Notifier
class LearningProgressNotifier extends StateNotifier<LearningProgressState> {
  LearningProgressNotifier() : super(LearningProgressState(isLoading: true)) {
    loadProgress();
  }

  /// Load all progress from database
  Future<void> loadProgress() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final allProgress =
          await DatabaseService.instance.getAllLearningProgress();

      final progressMap = <String, LearningProgressModel>{};
      for (var progress in allProgress) {
        progressMap[progress.gesture] = progress;
      }

      state = state.copyWith(
        progressMap: progressMap,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Get progress for specific gesture
  LearningProgressModel? getProgress(String gesture) {
    return state.progressMap[gesture];
  }

  /// Get mastery level (0-5)
  int getMasteryLevel(String gesture) {
    return state.progressMap[gesture]?.masteryLevel ?? 0;
  }

  /// Check if gesture is mastered
  bool isMastered(String gesture) {
    return getMasteryLevel(gesture) >= 5;
  }

  /// Update practice result
  Future<void> updatePractice(String gesture, bool wasCorrect) async {
    try {
      // Update in database
      await DatabaseService.instance.updatePracticeResult(gesture, wasCorrect);

      // Reload progress to reflect changes
      await loadProgress();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reset specific gesture progress
  Future<void> resetGesture(String gesture) async {
    try {
      await DatabaseService.instance.resetGestureProgress(gesture);
      await loadProgress();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear all progress
  Future<void> clearAll() async {
    try {
      await DatabaseService.instance.clearLearningProgress();
      state = state.copyWith(progressMap: {});
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

/// Provider
final learningProgressProvider =
    StateNotifierProvider<LearningProgressNotifier, LearningProgressState>(
  (ref) => LearningProgressNotifier(),
);
