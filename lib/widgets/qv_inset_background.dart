import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';

enum QvInsetBackgroundType {
  surface,
  secondary;

  String get assetPath {
    switch (this) {
      case QvInsetBackgroundType.surface:
        return 'images/ui/backgrounds/background-surface.png';
      case QvInsetBackgroundType.secondary:
        return 'images/ui/backgrounds/background-secondary.png';
    }
  }
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
    this.padding = const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
    this.width,
    this.height,
    this.type = QvInsetBackgroundType.secondary,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: Container(
        padding: padding,
        width: width,
        height: height,
        decoration: enabled
            ? BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(type.assetPath),
                  centerSlice: STANDARD_BORDER_SLICE,
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              )
            : null,
        child: child,
      ),
    );
  }
}
