import 'package:flutter/material.dart';
import 'package:mute/core/theme/app.dart';

class GestureCard extends StatelessWidget {
  final String gesture;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showProgress;
  final double? progress;

  const GestureCard({
    super.key,
    required this.gesture,
    this.isSelected = false,
    this.onTap,
    this.showProgress = false,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected
          ? AppTheme.secondaryColor.withOpacity(0.2)
          : AppTheme.surfaceLight2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppTheme.secondaryColor, width: 2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Gesture Display
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.secondaryColor
                      : AppTheme.primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    gesture.length > 2
                        ? gesture.substring(0, 2).toUpperCase()
                        : gesture,
                    style: TextStyle(
                      fontSize: gesture.length > 2 ? 14 : 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Gesture Label
              Text(
                gesture,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? AppTheme.secondaryColor
                      : AppTheme.surfaceLight,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              // Progress Indicator
              if (showProgress && progress != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppTheme.surfaceColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress! >= 1.0
                          ? AppTheme.successColor
                          : AppTheme.secondaryColor,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
