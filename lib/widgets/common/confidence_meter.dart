import 'package:flutter/material.dart';
import 'package:mute/core/theme/app.dart';

class ConfidenceMeter extends StatelessWidget {
  final double confidence; // 0.0 to 1.0
  final bool showLabel;

  const ConfidenceMeter({
    super.key,
    required this.confidence,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    // Determine color based on confidence
    Color color;
    if (confidence >= 0.8) {
      color = AppTheme.successColor;
    } else if (confidence >= 0.5) {
      color = AppTheme.warningColor;
    } else {
      color = AppTheme.errorColor;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Confidence',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${(confidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
