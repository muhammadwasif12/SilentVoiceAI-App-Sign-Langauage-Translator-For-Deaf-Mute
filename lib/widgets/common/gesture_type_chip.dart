import 'package:flutter/material.dart';
import 'package:mute/core/theme/app.dart';

enum GestureType { fixed, custom }

class GestureTypeChip extends StatelessWidget {
  final GestureType type;
  final bool isSmall;

  const GestureTypeChip({
    super.key,
    required this.type,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCustom = type == GestureType.custom;
    final color = isCustom ? AppTheme.secondaryColor : AppTheme.primaryColor;
    final label = isCustom ? 'Custom' : 'Fixed';
    final icon = isCustom ? Icons.star_rounded : Icons.grid_view_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: isSmall ? 12 : 16,
            color: color,
          ),
          SizedBox(width: isSmall ? 4 : 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
