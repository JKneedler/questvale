import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/helpers/constants.dart';

enum QvInsetBackgroundType {
  surface,
  secondary;

  String assetPath(String themeId) {
    switch (this) {
      case QvInsetBackgroundType.surface:
        return 'images/ui/backgrounds/$themeId/background-surface.png';
      case QvInsetBackgroundType.secondary:
        return 'images/ui/backgrounds/$themeId/background-secondary.png';
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
    final themeId = context.watch<ThemeCubit>().state.theme.id;
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
                  image: AssetImage(type.assetPath(themeId)),
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
