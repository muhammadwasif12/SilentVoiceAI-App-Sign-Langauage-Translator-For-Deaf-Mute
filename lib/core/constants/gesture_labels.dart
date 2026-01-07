/// SilentVoice AI - Gesture Labels
/// ================================
/// All supported gesture labels (36 classes: 1-10 + A-Z)
library;

class GestureLabels {
  // Numbers (10 gestures: 1-10) - For UI/Learning/Reverse Mode only
  static const List<String> numbers = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
  ];

  // ASL Alphabet (26 gestures: A-Z)
  static const List<String> alphabet = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
  ];

  // Special gestures (3 gestures) - MUST match model output exactly
  static const List<String> special = [
    'del', // Model outputs 'del', not 'delete'
    'nothing',
    'space',
  ];

  // Model gestures (29 total: 26 alphabet + 3 special)
  // This matches the TFLite model's output shape [1, 29]
  // ONLY these gestures can be detected by the AI model
  static List<String> get modelGestures => [
        ...alphabet,
        ...special,
      ];

  // All gestures for UI (39 total: 10 numbers + 26 alphabet + 3 special)
  // This includes numbers for Learning and Reverse Mode
  static List<String> get allGestures => [
        ...numbers,
        ...alphabet,
        ...special,
      ];

  // Total number of gestures
  static int get totalGestures => allGestures.length;

  // Total number of model gestures (what AI can detect)
  static int get totalModelGestures => modelGestures.length;

  // Gesture to index mapping
  static Map<String, int> get gestureToIndex => {
        for (int i = 0; i < allGestures.length; i++) allGestures[i]: i,
      };

  // Index to gesture mapping
  static Map<int, String> get indexToGesture => {
        for (int i = 0; i < allGestures.length; i++) i: allGestures[i],
      };

  // Get display name for gesture
  static String getDisplayName(String gesture) {
    // Special gestures should be title case
    if (special.contains(gesture)) {
      return gesture[0].toUpperCase() + gesture.substring(1);
    }
    // Alphabet should be uppercase
    return gesture.toUpperCase();
  }

  // Get gesture category
  static String getCategory(String gesture) {
    if (numbers.contains(gesture)) return 'Numbers';
    if (alphabet.contains(gesture)) return 'Alphabet';
    if (special.contains(gesture)) return 'Special';
    return 'Unknown';
  }

  // Get gestures by category
  static List<String> getGesturesByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'numbers':
        return numbers;
      case 'alphabet':
        return alphabet;
      case 'special':
        return special;
      default:
        return [];
    }
  }

  // Get gesture image path
  static String getGestureImagePath(String gesture) {
    return 'assets/gestures/${gesture.toLowerCase()}.png';
  }

  // Categories for UI
  static const List<String> categories = [
    'Numbers',
    'Alphabet',
    'Special',
  ];

  // Category icons
  static const Map<String, String> categoryIcons = {
    'Numbers': '🔢',
    'Alphabet': '🔤',
    'Special': '✨',
  };

  // Difficulty levels for learning
  static int getDifficulty(String gesture) {
    return 1; // All are easy
  }

  // Check if gesture exists
  static bool gestureExists(String gesture) {
    return allGestures.contains(gesture) ||
        allGestures.contains(gesture.toLowerCase());
  }

  // Search gestures
  static List<String> searchGestures(String query) {
    final lowercaseQuery = query.toLowerCase();
    return allGestures.where((gesture) {
      return gesture.toLowerCase().contains(lowercaseQuery) ||
          getDisplayName(gesture).toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
}
