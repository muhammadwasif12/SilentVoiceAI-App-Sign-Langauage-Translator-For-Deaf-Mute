import 'package:flutter/material.dart';
import 'package:mute/core/theme/app.dart';
import 'package:mute/models/prediction_result_model.dart';

class PredictionOverlay extends StatelessWidget {
  final PredictionResult prediction;

  const PredictionOverlay({super.key, required this.prediction});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getBorderColor(), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getBorderColor().withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Detected Label
          Text(
            prediction.displayGesture,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Confidence Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Confidence: ',
                style:
                    TextStyle(color: AppTheme.textSecondaryDark, fontSize: 14),
              ),
              Text(
                prediction.confidenceString,
                style: TextStyle(
                  color: _getBorderColor(),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Confidence Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: prediction.confidence,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(_getBorderColor()),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBorderColor() {
    if (prediction.isConfident || prediction.confidence >= 0.80) {
      return AppTheme.successColor; // Green
    } else if (prediction.confidence >= 0.50) {
      return AppTheme.warningColor; // Yellow
    } else {
      return AppTheme.errorColor; // Red
    }
  }
}
