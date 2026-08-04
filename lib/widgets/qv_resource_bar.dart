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
    this.labelAbove = false,
    this.labelAlign = TextAlign.center,
    this.trackColor,
  });
  final Color color;
  final int maxValue;
  final int currentValue;
  final Alignment alignment;
  final double height;
  final double fontSize;
  // When true, the current/max label sits above the bar in the bar's own
  // color instead of overlaid inside it in white — used by the combat
  // status card. Defaults to the original inside-bar look (combat page's
  // bars sit in a fixed-height row that isn't sized for the extra label
  // height).
  final bool labelAbove;
  // Only takes effect when labelAbove is true — lets the health/mana bars
  // lean their labels toward the AP display between them instead of
  // centering over their own (differently-sized) bar.
  final TextAlign labelAlign;
  // Color of the unfilled portion behind the bar. Defaults to the original
  // translucent white (combat page); the status card overrides this to the
  // theme's surface color.
  final Color? trackColor;
  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final fillHeight = height - 2;
    final label = Text(
      '$currentValue / $maxValue',
      textAlign: labelAbove ? labelAlign : TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: labelAbove ? color : Colors.grey[100],
        fontWeight: labelAbove ? FontWeight.bold : FontWeight.normal,
        height: 1,
      ),
    );
    final bar = SizedBox(
      height: height,
      child: Column(
        children: [
          Container(height: 2, color: colorScheme.secondary),
          Stack(
            alignment: alignment,
            children: [
              Container(
                  height: fillHeight,
                  color: trackColor ?? Colors.white.withValues(alpha: 0.3)),
              FractionallySizedBox(
                widthFactor: currentValue / maxValue,
                child: Container(color: color, height: fillHeight),
              ),
              if (!labelAbove) Center(child: label),
            ],
          ),
        ],
      ),
    );
    if (!labelAbove) return bar;
    return Column(
      mainAxisSize: MainAxisSize.min,
      // Stretch so the label has the bar's full width to align within —
      // otherwise it shrink-wraps to its own text and labelAlign has
      // nothing to do.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [label, const SizedBox(height: 2), bar],
    );
  }
}
