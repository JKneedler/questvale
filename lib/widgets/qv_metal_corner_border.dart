import 'package:flutter/material.dart';

class QvMetalCornerBorder extends StatelessWidget {
  final Widget child;
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;
  final Color? color;

  const QvMetalCornerBorder({
    super.key,
    required this.child,
    this.widthFactor = .95,
    this.heightFactor = .95,
    this.padding = const EdgeInsets.all(6),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Center(
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            heightFactor: heightFactor,
            child: Container(
              color: color ?? colorScheme.surface,
              padding: padding,
              child: child,
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              foregroundDecoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'images/ui/borders/primary-metal-edge-border-2x.png'),
                  centerSlice: Rect.fromLTWH(28, 28, 8, 8),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
