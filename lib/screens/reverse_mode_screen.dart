import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../services/tts_service.dart';
import '../widgets/common/glass_container.dart';

class ReverseModeScreen extends ConsumerStatefulWidget {
  const ReverseModeScreen({super.key});

  @override
  ConsumerState<ReverseModeScreen> createState() => _ReverseModeScreenState();
}

class _ReverseModeScreenState extends ConsumerState<ReverseModeScreen> {
  final TextEditingController _textController = TextEditingController();
  List<String> _gestureSequence = [];

  void _processText(String text) {
    setState(() {
      _gestureSequence = text.toUpperCase().split('').where((char) {
        // Only keep characters that have corresponding gestures (A-Z, 0-9)
        return RegExp(r'[A-Z0-9]').hasMatch(char);
      }).toList();
    });
  }

  Future<void> _speakText() async {
    if (_textController.text.isNotEmpty) {
      await TTSService.instance.speak(_textController.text);
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reverse Mode'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Input Area
          Padding(
            padding: const EdgeInsets.all(20),
            child: GlassContainer(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  controller: _textController,
                  onChanged: _processText,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Type text to translate...',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_textController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.volume_up),
                            onPressed: _speakText,
                            tooltip: 'Speak Text',
                          ),
                        if (_textController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _textController.clear();
                              _processText('');
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Gesture Display Area
          Expanded(
            child: _gestureSequence.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.touch_app_outlined,
                          size: 64,
                          color: theme.colorScheme.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Type above to see gestures',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: _gestureSequence.length,
                    itemBuilder: (context, index) {
                      final char = _gestureSequence[index];
                      return _buildGestureCard(context, char, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildGestureCard(BuildContext context, String char, int index) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                'assets/gestures/${char.toLowerCase()}.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Text(
                      char,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.black.withOpacity(0.3),
            child: Text(
              char,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: (50 * index).ms).scale();
  }
}
