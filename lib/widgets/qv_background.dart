import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/helpers/constants.dart';

enum QvBackgroundType {
  surfaceContainerNoBottom,
  surfaceNoBottom,
  surfaceNoTop,
  surfaceNoTopNoBottom;

  // These all live under images/ui/buttons/ (not backgrounds/, despite the
  // class's own name) — they're variants of the same raised-button asset
  // family (see button-surface.png), just missing a cap edge, not flat
  // background fills. surfaceContainerNoBottom's original home in
  // backgrounds/ was a pre-existing quirk from before this file grew the
  // rest of the no-top/no-bottom family; all four moved to buttons/
  // together to stop compounding it.
  String assetPath(String themeId) {
    switch (this) {
      case QvBackgroundType.surfaceContainerNoBottom:
        return 'images/ui/buttons/$themeId/button-surface-container-no-bottom.png';
      case QvBackgroundType.surfaceNoBottom:
        return 'images/ui/buttons/$themeId/button-surface-no-bottom.png';
      case QvBackgroundType.surfaceNoTop:
        return 'images/ui/buttons/$themeId/button-surface-no-top.png';
      case QvBackgroundType.surfaceNoTopNoBottom:
        return 'images/ui/buttons/$themeId/button-surface-no-top-no-bottom.png';
    }
  }
}

/// Full-page background: a bordered/beveled cap along the top edge only,
/// with the rest of the shape a flat fill extending to the bottom - unlike
/// QvInsetBackground's uniform 9-slice border on every side.
/// surfaceNoTop is the mirror shape of surfaceNoBottom — flat fill up to
/// the top, cap on the bottom edge instead — but NOT a simple vertical
/// flip of that asset: a raised container's cap always shades as raised
/// (dark accent + a drop shadow beneath it, see button-surface.png's own
/// bottom edge), regardless of which edge it's on. Flipping
/// button-surface-no-bottom.png naively carries its Light (highlight)
/// top cap down to the bottom edge instead, which reads as inset rather
/// than raised — button-surface-no-top.png is built from
/// button-surface.png's own real (correctly-shaded) bottom cap instead,
/// with its top cap flattened out.
/// surfaceNoTopNoBottom drops both caps — left/right edge lines only,
/// flat fill top and bottom — built for NavBar to borrow via its own
/// asset path (not through this widget directly, since NavBar's SafeArea/
/// Material layout doesn't fit QvBackground's own padding/sizing shape) so
/// the vitals card above it and the nav bar below read as one continuous
/// bordered region — see nav_bar.dart's useCombatBackground.
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
