import 'package:flutter/material.dart';

enum QvInsetBackgroundType {
  surface,
  secondary,
}

class QvInsetBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final QvInsetBackgroundType type;
  final bool enabled;
  const QvInsetBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    this.width,
    this.height,
    this.type = QvInsetBackgroundType.secondary,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      width: width,
      height: height,
      decoration: enabled
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/ui/${type.name}-background-2x.png'),
                centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            )
          : null,
      child: child,
    );
  }
}
