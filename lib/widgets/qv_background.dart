import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/helpers/constants.dart';

enum QvBackgroundType {
  surfaceContainerNoBottom;

  String assetPath(String themeId) {
    switch (this) {
      case QvBackgroundType.surfaceContainerNoBottom:
        return 'images/ui/backgrounds/$themeId/button-surface-container-no-bottom.png';
    }
  }
}

/// Full-page background: a bordered/beveled cap along the top edge only,
/// with the rest of the shape a flat fill extending to the bottom - unlike
/// QvInsetBackground's uniform 9-slice border on every side.
class QvBackground extends StatelessWidget {
  const QvBackground({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(0),
    this.width,
    this.height,
    this.type = QvBackgroundType.surfaceContainerNoBottom,
  });

  final Widget child;
  final EdgeInsets padding;
  final double? width;
  final double? height;
  final QvBackgroundType type;

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(type.assetPath(themeId)),
            centerSlice: STANDARD_BORDER_SLICE,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        child: child,
      ),
    );
  }
}
