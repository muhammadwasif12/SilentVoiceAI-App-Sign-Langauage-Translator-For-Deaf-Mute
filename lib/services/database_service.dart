/// SilentVoice AI - Database Service
/// ==================================
/// SQLite database service for offline storage.
library;

import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import '../models/gesture_history_model.dart';
import '../models/learning_progress_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  /// Get database instance
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('silentvoice.db');
    return _database!;
  }

  /// Initialize database
  Future<void> initialize() async {
    _database = await _initDB('silentvoice.db');
  }

  /// Initialize database with tables
  Future<Database> _initDB(String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  /// Create database tables
  Future<void> _createDB(Database db, int version) async {
    // Gesture History Table
    await db.execute('''
      CREATE TABLE gesture_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gesture TEXT NOT NULL,
        confidence REAL NOT NULL,
        timestamp TEXT NOT NULL,
        session_id TEXT,
        mode TEXT DEFAULT 'camera'
      )
    ''');

    // Learning Progress Table
    await db.execute('''
      CREATE TABLE learning_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gesture TEXT NOT NULL UNIQUE,
        times_practiced INTEGER DEFAULT 0,
        times_correct INTEGER DEFAULT 0,
        last_practiced TEXT,
        mastery_level INTEGER DEFAULT 0,
        streak INTEGER DEFAULT 0
      )
    ''');

    // Reverse Mode Cache Table
    await db.execute('''
      CREATE TABLE reverse_mode_cache (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        text TEXT NOT NULL,
        gestures TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');

    // Settings Table
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // User Sessions Table
    await db.execute('''
      CREATE TABLE sessions (
        id TEXT PRIMARY KEY,
        start_time TEXT NOT NULL,
        end_time TEXT,
        gestures_detected INTEGER DEFAULT 0,
        mode TEXT DEFAULT 'camera'
      )
    ''');

    // Custom Gestures Table
    await db.execute('''
      CREATE TABLE custom_gestures (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        description TEXT,
        base_gesture TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        last_used TEXT,
        usage_count INTEGER DEFAULT 0
      )
    ''');

    // Create indexes
    await db.execute(
        'CREATE INDEX idx_history_timestamp ON gesture_history(timestamp)');
    await db.execute(
        'CREATE INDEX idx_history_gesture ON gesture_history(gesture)');
    await db.execute(
        'CREATE INDEX idx_progress_gesture ON learning_progress(gesture)');
    await db.execute('CREATE INDEX idx_custom_name ON custom_gestures(name)');
    await db.execute(
        'CREATE INDEX idx_custom_base ON custom_gestures(base_gesture)');
  }

  /// Upgrade database schema
  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE custom_gestures (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL UNIQUE,
          description TEXT,
          base_gesture TEXT NOT NULL,
          image_path TEXT,
          created_at TEXT NOT NULL,
          last_used TEXT,
          usage_count INTEGER DEFAULT 0
        )
      ''');
      await db.execute('CREATE INDEX idx_custom_name ON custom_gestures(name)');
      await db.execute(
          'CREATE INDEX idx_custom_base ON custom_gestures(base_gesture)');
    }
  }

  // ==========================================================================
  // GESTURE HISTORY OPERATIONS
  // ==========================================================================

  Future<int> insertGestureHistory(GestureHistoryModel history) async {
    final db = await database;
    return await db.insert(
      'gesture_history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<GestureHistoryModel>> getGestureHistory({
    int? limit,
    int? offset,
    String? gesture,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (gesture != null) {
      whereClause = 'gesture = ?';
      whereArgs.add(gesture);
    }
    if (startDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp >= ?';
      whereArgs.add(startDate.toIso8601String());
    }
    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'timestamp <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    final maps = await db.query(
      'gesture_history',
      where: whereClause.isNotEmpty ? whereClause : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => GestureHistoryModel.fromMap(map)).toList();
  }

  Future<Map<String, int>> getGestureStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT gesture, COUNT(*) as count 
      FROM gesture_history 
      GROUP BY gesture 
      ORDER BY count DESC
    ''');
    return {
      for (var row in result) row['gesture'] as String: row['count'] as int
    };
  }

  Future<int> deleteGestureHistory(int id) async {
    final db = await database;
    return await db.delete('gesture_history', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> clearGestureHistory() async {
    final db = await database;
    return await db.delete('gesture_history');
  }

  Future<int> addHistory(String text) async {
    final history = GestureHistoryModel(
      gesture: text,
      confidence: 1.0,
      timestamp: DateTime.now(),
      mode: 'camera',
    );
    return await insertGestureHistory(history);
  }

  // ==========================================================================
  // LEARNING PROGRESS OPERATIONS - FIXED VERSION
  // ==========================================================================

  /// Get all learning progress
  Future<List<LearningProgressModel>> getAllLearningProgress() async {
    final db = await database;
    final maps = await db.query('learning_progress', orderBy: 'gesture ASC');
    return maps.map((map) => LearningProgressModel.fromMap(map)).toList();
  }

  /// Get learning progress for specific gesture
  Future<LearningProgressModel?> getLearningProgress(String gesture) async {
    final db = await database;
    final maps = await db.query(
      'learning_progress',
      where: 'gesture = ?',
      whereArgs: [gesture],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return LearningProgressModel.fromMap(maps.first);
  }

  /// Update practice result - FIXED CALCULATION
  /// Each practice = +1 mastery level (max 5)
  Future<void> updatePracticeResult(String gesture, bool wasCorrect) async {
    final db = await database;
    final current = await getLearningProgress(gesture);

    if (current == null) {
      // First practice - create new entry with mastery level 1
      await db.insert('learning_progress', {
        'gesture': gesture,
        'times_practiced': 1,
        'times_correct': wasCorrect ? 1 : 0,
        'last_practiced': DateTime.now().toIso8601String(),
        'mastery_level': 1, // Start at level 1
        'streak': wasCorrect ? 1 : 0,
      });
    } else {
      // Update existing
      final newTimesPracticed = current.timesPracticed + 1;
      final newTimesCorrect = current.timesCorrect + (wasCorrect ? 1 : 0);
      final newStreak = wasCorrect ? current.streak + 1 : 0;

      // FIXED: Simple calculation - each practice adds 1 to mastery (max 5)
      final newMasteryLevel = newTimesPracticed.clamp(0, 5);

      await db.update(
        'learning_progress',
        {
          'times_practiced': newTimesPracticed,
          'times_correct': newTimesCorrect,
          'last_practiced': DateTime.now().toIso8601String(),
          'mastery_level': newMasteryLevel,
          'streak': newStreak,
        },
        where: 'gesture = ?',
        whereArgs: [gesture],
      );
    }
  }

  /// Get learning statistics
  Future<Map<String, dynamic>> getLearningStats() async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_gestures,
        SUM(times_practiced) as total_practices,
        SUM(times_correct) as total_correct,
        COUNT(CASE WHEN mastery_level >= 5 THEN 1 END) as mastered_count,
        MAX(streak) as best_streak
      FROM learning_progress
    ''');

    if (result.isEmpty) {
      return {
        'total_gestures': 0,
        'total_practices': 0,
        'total_correct': 0,
        'mastered_count': 0,
        'best_streak': 0,
      };
    }

    return {
      'total_gestures': result.first['total_gestures'] ?? 0,
      'total_practices': result.first['total_practices'] ?? 0,
      'total_correct': result.first['total_correct'] ?? 0,
      'mastered_count': result.first['mastered_count'] ?? 0,
      'best_streak': result.first['best_streak'] ?? 0,
    };
  }

  /// Reset gesture progress
  Future<void> resetGestureProgress(String gesture) async {
    final db = await database;
    await db.delete('learning_progress',
        where: 'gesture = ?', whereArgs: [gesture]);
  }

  /// Clear all learning progress
  Future<int> clearLearningProgress() async {
    final db = await database;
    return await db.delete('learning_progress');
  }

  /// Get recently practiced gestures
  Future<List<LearningProgressModel>> getRecentlyPracticed(
      {int limit = 10}) async {
    final db = await database;
    final maps = await db.query(
      'learning_progress',
      orderBy: 'last_practiced DESC',
      limit: limit,
    );
    return maps.map((map) => LearningProgressModel.fromMap(map)).toList();
  }

  /// Get mastered gestures
  Future<List<LearningProgressModel>> getMasteredGestures() async {
    final db = await database;
    final maps = await db.query(
      'learning_progress',
      where: 'mastery_level >= ?',
      whereArgs: [5],
      orderBy: 'gesture ASC',
    );
    return maps.map((map) => LearningProgressModel.fromMap(map)).toList();
  }

  // ==========================================================================
  // REVERSE MODE CACHE
  // ==========================================================================

  Future<int> cacheReverseMode(String text, List<String> gestures) async {
    final db = await database;
    return await db.insert(
      'reverse_mode_cache',
      {
        'text': text,
        'gestures': gestures.join(','),
        'timestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<String>?> getCachedReverseMode(String text) async {
    final db = await database;
    final maps = await db.query(
      'reverse_mode_cache',
      where: 'text = ?',
      whereArgs: [text],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return (maps.first['gestures'] as String).split(',');
  }

  // ==========================================================================
  // SETTINGS
  // ==========================================================================

  Future<void> saveSetting(String key, String value) async {
    final db = await database;
    await db.insert(
      'settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings',
        where: 'key = ?', whereArgs: [key], limit: 1);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<Map<String, String>> getAllSettings() async {
    final db = await database;
    final maps = await db.query('settings');
    return {for (var row in maps) row['key'] as String: row['value'] as String};
  }

  // ==========================================================================
  // SESSIONS
  // ==========================================================================

  Future<String> startSession(String mode) async {
    final db = await database;
    final sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    await db.insert('sessions', {
      'id': sessionId,
      'start_time': DateTime.now().toIso8601String(),
      'mode': mode,
    });
    return sessionId;
  }

  Future<void> endSession(String sessionId, int gesturesDetected) async {
    final db = await database;
    await db.update(
      'sessions',
      {
        'end_time': DateTime.now().toIso8601String(),
        'gestures_detected': gesturesDetected,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // ==========================================================================
  // UTILITIES
  // ==========================================================================

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }

  Future<int> getDatabaseSize() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'silentvoice.db');
    final file = await directory.list().firstWhere(
          (f) => f.path == path,
          orElse: () => throw Exception('Database file not found'),
        );
    return await file.stat().then((stat) => stat.size);
  }

  Future<String> exportDatabase() async {
    throw UnimplementedError('Database export not yet implemented');
  }
}
