import 'package:flutter/material.dart';

class QvResourceBar extends StatelessWidget {
  const QvResourceBar({
    super.key,
    required this.color,
    required this.maxValue,
    required this.currentValue,
    required this.alignment,
    this.height = 40,
    this.fontSize = 22,
  });
  final Color color;
  final int maxValue;
  final int currentValue;
  final Alignment alignment;
  final double height;
  final double fontSize;
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final fillHeight = height - 2;
    return SizedBox(
      height: height,
      child: Column(
        children: [
          Container(height: 2, color: colorScheme.secondary),
          Stack(
            alignment: alignment,
            children: [
              Container(
                  height: fillHeight,
                  color: Colors.white.withValues(alpha: 0.3)),
              FractionallySizedBox(
                widthFactor: currentValue / maxValue,
                child: Container(color: color, height: fillHeight),
              ),
              Center(
                child: Text(
                  '$currentValue / $maxValue',
                  style: TextStyle(
                      fontSize: fontSize, color: Colors.grey[100], height: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
