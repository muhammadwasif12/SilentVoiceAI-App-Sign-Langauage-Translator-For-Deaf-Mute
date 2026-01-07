# 📁 SilentVoice AI - Complete Project Structure & File Purpose

## 📊 VISUAL PROJECT TREE

```
d:\silent_voice\
│
├── 📱 lib/                                    # Main application code
│   │
│   ├── 🏗️ core/                               # Core utilities & configuration
│   │   ├── constants/
│   │   │   ├── app_constants.dart           # App-wide constants (colors, strings)
│   │   │   └── gesture_labels.dart          # 107 gesture label definitions
│   │   ├── routes/
│   │   │   └── app_router.dart              # GoRouter navigation configuration
│   │   └── theme/
│   │       └── app.dart                     # Theme configuration (colors, fonts)
│   │
│   ├── 📦 models/                             # Data structures
│   │   ├── gesture_history_model.dart       # History entry data class
│   │   ├── learning_progress_model.dart     # Progress tracking data class
│   │   └── prediction_result_model.dart     # ML prediction result data class
│   │
│   ├── 🎮 providers/                          # State management (Riverpod)
│   │   ├── gesture_detection_provider.dart  # Detection state manager
│   │   ├── learning_progress_provider.dart  # Learning state manager
│   │   └── settings_provider.dart           # App settings state manager
│   │
│   ├── 📱 screens/                            # Full-screen pages
│   │   ├── splash_screen.dart               # App launch & initialization
│   │   ├── home_screen.dart                 # Main navigation hub (6 cards)
│   │   ├── camera_screen.dart               # Real-time detection (MOST COMPLEX)
│   │   ├── learning_screen.dart             # Learn 107 gestures
│   │   ├── practice_screen.dart             # Quiz mode (test skills)
│   │   ├── reverse_mode_screen.dart         # Text → Signs conversion
│   │   ├── history_screen.dart              # View past detections
│   │   └── settings_screen.dart             # App configuration
│   │
│   ├── ⚙️ services/                           # Business logic & external integrations
│   │   ├── tflite_service.dart              # AI model loading & inference
│   │   ├── camera_service.dart              # Camera initialization & streaming
│   │   ├── database_service.dart            # SQLite operations (CRUD)
│   │   ├── gesture_detection_service.dart   # Detection orchestration
│   │   ├── tts_service.dart                 # Text-to-Speech
│   │   └── api_service.dart                 # HTTP API communication
│   │
│   ├── 🎨 widgets/                            # Reusable UI components
│   │   ├── common/
│   │   │   ├── glass_container.dart         # Glassmorphism effect
│   │   │   ├── stats_card.dart              # Statistics display card
│   │   │   ├── confidence_meter.dart        # Confidence bar indicator
│   │   │   └── gesture_type_chip.dart       # Category badge
│   │   ├── camera_preview.dart              # Camera display widget
│   │   ├── prediction_overlay.dart          # Shows detected gesture
│   │   ├── detected_text_display.dart       # Shows building text
│   │   ├── gesture_card.dart                # Individual gesture display
│   │   └── loading_indicator.dart           # Loading animations
│   │
│   └── 🚀 main.dart                           # App entry point (runApp)
│
├── 🤖 ai_model/                               # Python training scripts (42K files!)
│   └── [Training notebooks, datasets, scripts]
│
├── 📦 assets/                                 # Static resources
│   ├── models/
│   │   ├── gesture_model.tflite            # AI model (48.1 KB) ⭐
│   │   └── gesture_labels.json             # Label mappings
│   ├── gestures/
│   │   ├── A.png ... Z.png                 # Alphabet images
│   │   ├── 0.png ... 9.png                 # Number images
│   │   └── [other gesture images]
│   ├── sounds/
│   │   └── detection.mp3                   # Detection sound effect
│   └── app_icon.png                         # App launcher icon
│
├── 🤖 android/                                # Android-specific files
│   └── [Build config, permissions, etc.]
│
├── 🍎 ios/                                    # iOS-specific files (future)
│
├── 📚 Documentation Files/
│   ├── PRESENTATION_DOCUMENTATION.md        # Complete guide (YOU JUST GOT THIS!)
│   ├── TECHNICAL_WORKFLOW.md                # Detailed workflows (YOU JUST GOT THIS!)
│   ├── VIVA_QA_GUIDE.md                     # Q&A cheat sheet (YOU JUST GOT THIS!)
│   ├── QUICK_REFERENCE_CARD.md              # One-page summary (YOU JUST GOT THIS!)
│   ├── MODEL_INTEGRATION.md                 # How to swap AI model
│   ├── SilentVoiceAI_Project_Report.md      # Full project report
│   ├── SilentVoiceAI_Presentation_Content.md # Presentation content
│   ├── CODE_CLEANUP_SUMMARY.md              # Code cleanup log
│   ├── ERROR_FIXES_REPORT.md                # Error fixes log
│   ├── GESTURE_FIX_SUMMARY.md               # Gesture detection fixes
│   ├── MAJOR_UPDATE_SUMMARY.md              # Major updates log
│   └── README.md                             # Basic project info
│
├── 📝 Configuration Files/
│   ├── pubspec.yaml                         # Dependencies & assets ⭐
│   ├── analysis_options.yaml                # Linter rules
│   └── .gitignore                           # Git ignore patterns
│
└── 🎬 build/                                  # Compiled output (APK/IPA)
    └── [Generated build files]
```

---

## 🔍 FILE-BY-FILE EXPLANATION

### 🚀 **main.dart** (Entry Point)

**Purpose:** Application bootstrap  
**Lines:** ~25 lines  

**What it does:**
```dart
1. Import core libraries (Flutter, Riverpod, GoRouter)
2. void main() {
3.   runApp(
4.     ProviderScope(        // Riverpod wrapper
5.       child: MyApp(),
6.     ),
7.   );
8. }
9. 
10. class MyApp extends StatelessWidget {
11.   @override
12.   Widget build(BuildContext context) {
13.     return MaterialApp.router(
14.       title: 'SilentVoice AI',
15.       theme: AppTheme.lightTheme,  // From core/theme/app.dart
16.       routerConfig: AppRouter.router, // From core/routes/app_router.dart
17.     );
18.   }
19. }
```

**Key Concepts:**
- `ProviderScope`: Enables Riverpod state management
- `MaterialApp.router`: Uses GoRouter for navigation
- Theme configuration for consistent UI

---

### 📱 **screens/camera_screen.dart** (MOST IMPORTANT!)

**Purpose:** Real-time gesture detection  
**Lines:** ~400 lines  
**Complexity:** ⭐⭐⭐⭐⭐ (Most complex file)

**What it does:**
1. Initialize camera with permissions
2. Start camera preview
3. Capture frames at ~10 FPS
4. Send to TFLite model for inference
5. Display results in overlay
6. Handle user actions (save, clear, speak)
7. Save sessions to database

**Key Components:**
```dart
class CameraScreen extends ConsumerStatefulWidget {
  // State variables
  CameraController? _cameraController;
  bool _isProcessing = false;
  String _detectedText = '';
  
  // Lifecycle methods
  @override
  void initState() {
    _initializeCamera();
    _loadModel();
  }
  
  // Frame processing
  Future<void> _processFrame(CameraImage image) async {
    if (_isProcessing) return;
    _isProcessing = true;
    
    final result = await tfliteService.predict(image);
    
    if (result.confidence > threshold) {
      setState(() {
        _detectedText += result.label;
      });
    }
    
    _isProcessing = false;
  }
  
  // User actions
  void _addSpace() { ... }
  void _deleteChar() { ... }
  void _saveToHistory() { ... }
  void _speakText() { ... }
  
  // UI build
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreview(_cameraController),
        PredictionOverlay(result),
        DetectedTextDisplay(_detectedText),
        ControlButtons(),
      ],
    );
  }
}
```

**Workflow:**
```
initState
  ↓
Initialize Camera
  ↓
Load TFLite Model
  ↓
Start Image Stream ──┐
  ↓                  │
Process Frame        │
  ↓                  │
Model Inference      │
  ↓                  │
Update UI            │
  ↓                  │
Loop Back ───────────┘
```

---

### 🤖 **services/tflite_service.dart** (AI Core)

**Purpose:** TensorFlow Lite model operations  
**Lines:** ~300 lines  
**Complexity:** ⭐⭐⭐⭐

**What it does:**
1. Load .tflite model from assets
2. Preprocess camera images
3. Run model inference
4. Post-process predictions
5. Return result with confidence

**Key Methods:**
```dart
class TFLiteService {
  Interpreter? _interpreter;
  
  // Load model from assets
  Future<void> loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/gesture_model.tflite'
    );
    print('Model loaded: Input ${_interpreter.getInputTensor(0).shape}');
  }
  
  // Preprocess image
  Float32List _preprocessImage(img.Image image) {
    // 1. Resize to 224x224
    final resized = img.copyResize(image, width: 224, height: 224);
    
    // 2. Convert to Float32 and normalize
    final inputData = Float32List(1 * 224 * 224 * 3);
    int pixelIndex = 0;
    
    for (int y = 0; y < 224; y++) {
      for (int x = 0; x < 224; x++) {
        final pixel = resized.getPixel(x, y);
        inputData[pixelIndex++] = img.getRed(pixel) / 255.0;   // R
        inputData[pixelIndex++] = img.getGreen(pixel) / 255.0; // G
        inputData[pixelIndex++] = img.getBlue(pixel) / 255.0;  // B
      }
    }
    
    return inputData;
  }
  
  // Run inference
  Future<PredictionResult> predict(CameraImage cameraImage) async {
    // 1. Convert CameraImage to img.Image
    final image = _convertCameraImage(cameraImage);
    
    // 2. Preprocess
    final input = _preprocessImage(image);
    
    // 3. Prepare output tensor
    final output = List.filled(1 * 107, 0.0).reshape([1, 107]);
    
    // 4. Run model
    _interpreter.run(input, output);
    
    // 5. Find max probability
    final probabilities = output[0] as List<double>;
    double maxProb = 0.0;
    int maxIndex = 0;
    
    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxProb) {
        maxProb = probabilities[i];
        maxIndex = i;
      }
    }
    
    // 6. Map to label
    final label = GestureLabels.allGestures[maxIndex];
    
    return PredictionResult(
      label: label,
      confidence: maxProb,
    );
  }
  
  // Cleanup
  void dispose() {
    _interpreter?.close();
  }
}
```

**Input/Output:**
```
Input:  Float32List[1, 224, 224, 3] (normalized RGB)
Model:  CNN with ~2.5M parameters
Output: List<double>[1, 107] (probabilities)
        Example: [0.02, 0.85, 0.01, ..., 0.03]
                       ↑ Index 1 = "B" (85% confidence)
```

---

### 🗄️ **services/database_service.dart** (Data Persistence)

**Purpose:** SQLite database operations  
**Lines:** ~350 lines  
**Complexity:** ⭐⭐⭐

**What it does:**
1. Create and manage SQLite database
2. CRUD operations for history
3. CRUD operations for learning progress
4. Query, search, filter data

**Database Schema:**
```sql
-- Table 1: Detection History
CREATE TABLE history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  detected_text TEXT NOT NULL,
  timestamp TEXT NOT NULL,
  confidence REAL DEFAULT 0.0,
  duration INTEGER DEFAULT 0
);

CREATE INDEX idx_timestamp ON history(timestamp);

-- Table 2: Learning Progress
CREATE TABLE learning_progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  gesture_id TEXT UNIQUE NOT NULL,
  gesture_name TEXT NOT NULL,
  category TEXT NOT NULL,
  is_learned INTEGER DEFAULT 0,
  last_practiced TEXT
);

CREATE INDEX idx_gesture_id ON learning_progress(gesture_id);
```

**Key Methods:**
```dart
class DatabaseService {
  static Database? _database;
  static final DatabaseService instance = DatabaseService._init();
  
  DatabaseService._init();
  
  // Singleton pattern
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('silentvoice.db');
    return _database!;
  }
  
  // Initialize database
  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }
  
  // Create tables
  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        detected_text TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        confidence REAL DEFAULT 0.0,
        duration INTEGER DEFAULT 0
      )
    ''');
    
    await db.execute('''
      CREATE TABLE learning_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        gesture_id TEXT UNIQUE NOT NULL,
        gesture_name TEXT NOT NULL,
        category TEXT NOT NULL,
        is_learned INTEGER DEFAULT 0,
        last_practiced TEXT
      )
    ''');
    
    await db.execute('CREATE INDEX idx_timestamp ON history(timestamp)');
    await db.execute('CREATE INDEX idx_gesture_id ON learning_progress(gesture_id)');
  }
  
  // INSERT operation
  Future<int> insertHistory(GestureHistory history) async {
    final db = await database;
    return await db.insert(
      'history',
      history.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
  
  // SELECT operation
  Future<List<GestureHistory>> getAllHistory() async {
    final db = await database;
    final result = await db.query(
      'history',
      orderBy: 'timestamp DESC',
      limit: 50,
    );
    
    return result.map((map) => GestureHistory.fromMap(map)).toList();
  }
  
  // UPDATE operation
  Future<int> markGestureAsLearned(String gestureId, bool isLearned) async {
    final db = await database;
    return await db.update(
      'learning_progress',
      {'is_learned': isLearned ? 1 : 0},
      where: 'gesture_id = ?',
      whereArgs: [gestureId],
    );
  }
  
  // DELETE operation
  Future<int> deleteHistory(int id) async {
    final db = await database;
    return await db.delete(
      'history',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  // SEARCH operation
  Future<List<GestureHistory>> searchHistory(String query) async {
    final db = await database;
    final result = await db.query(
      'history',
      where: 'detected_text LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'timestamp DESC',
    );
    
    return result.map((map) => GestureHistory.fromMap(map)).toList();
  }
}
```

---

### 🎮 **providers/gesture_detection_provider.dart** (State Management)

**Purpose:** Manage detection state with Riverpod  
**Lines:** ~150 lines  
**Complexity:** ⭐⭐⭐

**What it does:**
1. Hold current detection state
2. Update state based on events
3. Notify UI of changes automatically
4. Coordinate between services

**State Structure:**
```dart
class GestureDetectionState {
  final String currentGesture;      // e.g., "A"
  final double currentConfidence;   // e.g., 0.87
  final String detectedText;        // e.g., "HELLO"
  final bool isDetecting;           // true/false
  final List<PredictionResult> history;
  
  GestureDetectionState({
    this.currentGesture = '',
    this.currentConfidence = 0.0,
    this.detectedText = '',
    this.isDetecting = false,
    this.history = const [],
  });
  
  // Immutable copy with changes
  GestureDetectionState copyWith({
    String? currentGesture,
    double? currentConfidence,
    String? detectedText,
    bool? isDetecting,
    List<PredictionResult>? history,
  }) {
    return GestureDetectionState(
      currentGesture: currentGesture ?? this.currentGesture,
      currentConfidence: currentConfidence ?? this.currentConfidence,
      detectedText: detectedText ?? this.detectedText,
      isDetecting: isDetecting ?? this.isDetecting,
      history: history ?? this.history,
    );
  }
}
```

**Provider Definition:**
```dart
class GestureDetectionNotifier extends StateNotifier<GestureDetectionState> {
  GestureDetectionNotifier() : super(GestureDetectionState());
  
  // Update with new prediction
  void updatePrediction(PredictionResult result) {
    state = state.copyWith(
      currentGesture: result.label,
      currentConfidence: result.confidence,
      detectedText: state.detectedText + result.label,
      history: [...state.history, result],
    );
  }
  
  // Add space
  void addSpace() {
    state = state.copyWith(
      detectedText: state.detectedText + ' ',
    );
  }
  
  // Delete last character
  void deleteChar() {
    if (state.detectedText.isEmpty) return;
    
    state = state.copyWith(
      detectedText: state.detectedText.substring(
        0,
        state.detectedText.length - 1,
      ),
    );
  }
  
  // Clear all
  void clearAll() {
    state = state.copyWith(
      detectedText: '',
      history: [],
    );
  }
  
  // Start/stop detection
  void toggleDetection() {
    state = state.copyWith(
      isDetecting: !state.isDetecting,
    );
  }
}

// Provider
final gestureDetectionProvider = 
    StateNotifierProvider<GestureDetectionNotifier, GestureDetectionState>(
  (ref) => GestureDetectionNotifier(),
);
```

**Usage in Widgets:**
```dart
// Watch state (rebuilds on change)
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(gestureDetectionProvider);
    
    return Column(
      children: [
        Text('Gesture: ${state.currentGesture}'),
        Text('Confidence: ${state.currentConfidence}'),
        Text('Text: ${state.detectedText}'),
      ],
    );
  }
}

// Update state
ref.read(gestureDetectionProvider.notifier).addSpace();
```

---

### 🎨 **widgets/prediction_overlay.dart** (UI Component)

**Purpose:** Display real-time prediction on camera  
**Lines:** ~100 lines  
**Complexity:** ⭐⭐

**What it does:**
1. Show detected gesture label
2. Display confidence percentage
3. Animate changes smoothly
4. Color based on confidence (green=high, red=low)

**Implementation:**
```dart
class PredictionOverlay extends StatelessWidget {
  final PredictionResult? result;
  
  const PredictionOverlay({this.result});
  
  @override
  Widget build(BuildContext context) {
    if (result == null) {
      return const SizedBox.shrink();
    }
    
    final confidence = result!.confidence;
    final label = result!.label;
    
    // Color based on confidence
    final color = confidence > 0.7
        ? Colors.green
        : confidence > 0.5
            ? Colors.orange
            : Colors.red;
    
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ).animate()
        .fadeIn(duration: 200.ms)
        .scale(begin: Offset(0.8, 0.8), end: Offset(1.0, 1.0)),
    );
  }
}
```

**Visual:**
```
┌─────────────────────────┐
│        🟩               │  ← Animated container
│          A              │  ← Large label
│        87.5%            │  ← Confidence
└─────────────────────────┘
```

---

## 📦 **models/** (Data Classes)

### **gesture_history_model.dart**

```dart
class GestureHistory {
  final int? id;
  final String detectedText;
  final String timestamp;
  final double confidence;
  final int duration; // seconds
  
  GestureHistory({
    this.id,
    required this.detectedText,
    required this.timestamp,
    required this.confidence,
    required this.duration,
  });
  
  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'detected_text': detectedText,
      'timestamp': timestamp,
      'confidence': confidence,
      'duration': duration,
    };
  }
  
  // Create from Map (database row)
  factory GestureHistory.fromMap(Map<String, dynamic> map) {
    return GestureHistory(
      id: map['id'],
      detectedText: map['detected_text'],
      timestamp: map['timestamp'],
      confidence: map['confidence'],
      duration: map['duration'],
    );
  }
}
```

---

## ⚙️ **pubspec.yaml** (Dependencies)

**Purpose:** Define project metadata and dependencies

```yaml
name: mute
description: "SilentVoice AI - Real-Time Sign Language Translator"
version: 1.0.0+1

environment:
  sdk: ^3.5.0

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.4.9        # Reactive state
  
  # Camera & ML
  camera: ^0.11.0+2               # Camera access
  tflite_flutter: ^0.11.0         # TensorFlow Lite
  image: ^4.5.4                   # Image processing
  
  # Database & Storage
  sqflite: ^2.4.2                 # SQLite database
  path_provider: ^2.1.5           # File paths
  shared_preferences: ^2.5.3      # Key-value storage
  
  # UI & UX
  google_fonts: ^6.3.2            # Custom fonts
  flutter_animate: ^4.5.2         # Animations
  
  # Utilities
  flutter_tts: ^4.2.3             # Text-to-Speech
  http: ^1.6.0                    # HTTP requests
  permission_handler: ^11.3.1     # Permissions
  audioplayers: ^6.1.0            # Sound effects
  vibration: ^2.0.0               # Haptic feedback
  intl: ^0.20.2                   # Internationalization
  equatable: ^2.0.7               # Value equality
  go_router: ^14.6.2              # Navigation
  path: ^1.9.1                    # Path manipulation

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0           # Linter
  flutter_launcher_icons: ^0.14.4 # Icon generation

flutter:
  uses-material-design: true
  
  assets:
    - assets/models/
    - assets/gestures/
    - assets/sounds/
    - assets/app_icon.png
```

---

## 🎯 DEPENDENCY PURPOSE

| Package | Purpose | Why Needed |
|---------|---------|------------|
| **flutter_riverpod** | State management | Reactive UI updates, type-safe |
| **camera** | Camera access | Capture frames for detection |
| **tflite_flutter** | Run TFLite models | On-device ML inference |
| **image** | Image processing | Resize, convert, manipulate images |
| **sqflite** | SQLite database | Persist history & progress locally |
| **path_provider** | File system paths | Locate database/cache directories |
| **shared_preferences** | Settings storage | Save user preferences |
| **google_fonts** | Custom fonts | Beautiful typography (Inter, Roboto) |
| **flutter_animate** | Animations | Smooth UI transitions |
| **flutter_tts** | Text-to-Speech | Speak detected text aloud |
| **http** | API calls | Backend communication (analytics) |
| **permission_handler** | Permissions | Request camera/storage access |
| **audioplayers** | Sound effects | Play detection sound |
| **vibration** | Haptic feedback | Vibrate on detection |
| **intl** | Date/time formatting | Format timestamps nicely |
| **equatable** | Value equality | Compare objects easily |
| **go_router** | Navigation | Declarative routing |

---

## 📊 PROJECT STATISTICS

```
Total Dart Files:      34
Total Lines of Code:   ~5,500 (estimated)
Screens:               8
Services:              6
Providers:             3
Models:                3
Widgets:               9
Assets:                ~120 (gesture images)

Dependencies:          20
Dev Dependencies:      3

Model Size:            48.1 KB
Total App Size:        ~15 MB (built APK)
```

---

## 🔍 FILE DEPENDENCIES (Who Calls Whom)

```
main.dart
  ├─→ app_router.dart (navigation)
  ├─→ app.dart (theme)
  └─→ All providers (Riverpod setup)

camera_screen.dart
  ├─→ tflite_service.dart (inference)
  ├─→ camera_service.dart (camera)
  ├─→ database_service.dart (save history)
  ├─→ tts_service.dart (speak)
  ├─→ gesture_detection_provider.dart (state)
  ├─→ prediction_overlay.dart (UI)
  ├─→ detected_text_display.dart (UI)
  └─→ camera_preview.dart (UI)

tflite_service.dart
  ├─→ gesture_labels.dart (label mapping)
  └─→ prediction_result_model.dart (result)

database_service.dart
  ├─→ gesture_history_model.dart (data)
  └─→ learning_progress_model.dart (data)

learning_screen.dart
  ├─→ database_service.dart (progress)
  ├─→ learning_progress_provider.dart (state)
  └─→ gesture_card.dart (UI)
```

---

## 🎯 CRITICAL FILES (Know These Well!)

### **Top 5 Most Important:**

1. **camera_screen.dart** - Real-time detection (core feature)
2. **tflite_service.dart** - AI model inference (brain)
3. **database_service.dart** - Data persistence (memory)
4. **gesture_detection_provider.dart** - State management (coordinator)
5. **main.dart** - App entry (first impression)

### **Top 5 for Viva Questions:**

1. **camera_screen.dart** - "Explain detection process"
2. **tflite_service.dart** - "How does AI model work?"
3. **database_service.dart** - "Explain database schema"
4. **pubspec.yaml** - "Why these dependencies?"
5. **app_router.dart** - "How is navigation handled?"

---

## 💡 QUICK FILE LOCATOR

**Need to explain:**
- **Detection?** → `camera_screen.dart` + `tflite_service.dart`
- **Database?** → `database_service.dart`
- **Learning progress?** → `learning_screen.dart` + `learning_progress_provider.dart`
- **Practice mode?** → `practice_screen.dart`
- **Reverse mode?** → `reverse_mode_screen.dart`
- **History?** → `history_screen.dart` + `database_service.dart`
- **Settings?** → `settings_screen.dart` + `settings_provider.dart`
- **UI components?** → `widgets/` folder
- **State management?** → `providers/` folder
- **Navigation?** → `app_router.dart`
- **Theme?** → `core/theme/app.dart`
- **Constants?** → `core/constants/`

---

## 🎬 EXECUTION FLOW

```
1. User opens app
   ↓
2. main.dart → runApp()
   ↓
3. ProviderScope initializes Riverpod
   ↓
4. MaterialApp.router loads AppRouter
   ↓
5. SplashScreen displays
   ↓
6. Background: Load model, init DB
   ↓
7. Navigate to HomeScreen
   ↓
8. User taps "Detect Gestures"
   ↓
9. AppRouter → CameraScreen
   ↓
10. CameraScreen initializes:
    - CameraService (camera)
    - TFLiteService (model)
    - GestureDetectionProvider (state)
   ↓
11. Frame processing loop starts
   ↓
12. For each frame:
    - tflite_service.predict()
    - Update GestureDetectionProvider
    - UI rebuilds automatically (Riverpod)
   ↓
13. User saves session
   ↓
14. database_service.insertHistory()
   ↓
15. Navigate back to HomeScreen
```

---

## 🚀 YOU NOW KNOW THE ENTIRE PROJECT!

**This structure document + the 4 previous docs = COMPLETE understanding!**

**You can now confidently explain:**
- ✅ What each file does
- ✅ How files interact
- ✅ What each dependency is for
- ✅ Where to find any functionality
- ✅ The complete execution flow

**For viva, when asked about any feature, just reference the relevant file(s) from this guide!**

**Example:**
- Q: "How does detection work?"
- A: "Let me walk you through the flow. It starts in `camera_screen.dart`, which uses `camera_service.dart` to capture frames. Each frame is sent to `tflite_service.dart` for inference using our CNN model. The result goes through `gesture_detection_provider.dart` which updates the UI automatically via Riverpod. Finally, the result is displayed using `prediction_overlay.dart` and `detected_text_display.dart` widgets."

**Boom! Detailed, file-specific answer that impresses examiners!** 💪

---

**Good luck tomorrow! You're fully prepared!** 🎓✨
