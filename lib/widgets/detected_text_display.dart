import 'package:flutter/material.dart';
import 'package:mute/core/theme/app.dart';

class DetectedTextDisplay extends StatelessWidget {
  final String text;
  final bool isAnimated;
  final VoidCallback? onClear;
  final VoidCallback? onCopy;
  final VoidCallback? onSpeak;

  const DetectedTextDisplay({
    super.key,
    required this.text,
    this.isAnimated = false,
    this.onClear,
    this.onCopy,
    this.onSpeak,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.secondaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.text_fields, color: AppTheme.secondaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                'Detected Text',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppTheme.secondaryColor,
                ),
              ),
              const Spacer(),
              if (text.isNotEmpty) ...[
                if (onSpeak != null)
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 20),
                    onPressed: onSpeak,
                    color: AppTheme.textPrimaryDark,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                if (onCopy != null)
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: onCopy,
                    color: AppTheme.textPrimaryDark,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
                if (onClear != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: onClear,
                    color: AppTheme.textPrimaryDark,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(8),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Text Content
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: text.isEmpty
                ? Text(
                    'No text detected yet...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textPrimaryDark.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  )
                : Text(
                    text,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.textPrimaryDark,
                      height: 1.5,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
