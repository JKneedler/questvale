import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

// Bordered 9-slice geometry for the fraction-fill bar image AND its inset
// background — both are sized/sliced to match (background-<type>-<suffix>.png
// counterparts the bar-<resource>-<suffix>.png assets), unlike
// QvInsetBackground's own fixed STANDARD_BORDER_SLICE/MIN_SIZE which is too
// large for a compact bar. See the *_SLICE and *_MIN_SIZE constants in
// constants.dart for why each variant needs its own min size (tied to that
// asset's own border inset).
enum QvBarSize {
  small(
    assetSuffix: 'small',
    slice: SMALL_BAR_SLICE,
    minSize: SMALL_BAR_MIN_SIZE,
  ),
  mini(
    assetSuffix: 'mini',
    slice: MINI_BAR_SLICE,
    minSize: MINI_BAR_MIN_SIZE,
  );

  final String assetSuffix;
  final Rect slice;
  final Size minSize;

  const QvBarSize({
    required this.assetSuffix,
    required this.slice,
    required this.minSize,
  });
}

// Which resource's baked-color bar asset to use — health/mana/exp each have
// their own pre-colored PNG per QvBarSize (generated from the same template
// via retheme_color.py, matching HEALTH_COLOR/MANA_COLOR/EXP_COLOR).
enum QvBarResource {
  health(assetPrefix: 'health'),
  mana(assetPrefix: 'mana'),
  exp(assetPrefix: 'exp');

  final String assetPrefix;
  const QvBarResource({required this.assetPrefix});
}

// Fraction-fill resource bar: a bordered 9-slice bar image (QvBarResource +
// QvBarSize pick the color/geometry) stacked over an inset background of the
// same size variant, with fully custom overlay content. The bar image's own
// border only wraps the filled portion (FractionallySizedBox), so the
// unfilled remainder just shows the inset background underneath, with no
// fill-bar border of its own.
class QvBar extends StatelessWidget {
  const QvBar({
    super.key,
    required this.currentValue,
    required this.maxValue,
    required this.child,
    this.resource = QvBarResource.health,
    this.size = QvBarSize.small,
    this.insetBackgroundType = QvInsetBackgroundType.surface,
    this.height = 30,
    this.width,
  });

  final int currentValue;
  final int maxValue;
  // Overlay content — fully caller-controlled (text, icon, whatever else).
  final Widget child;
  final QvBarResource resource;
  final QvBarSize size;
  final QvInsetBackgroundType insetBackgroundType;
  final double height;
  final double? width;

  static const _padding = EdgeInsets.all(0);

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    final fraction =
        maxValue > 0 ? (currentValue / maxValue).clamp(0.0, 1.0) : 0.0;
    final barAssetPath =
        'images/ui/bars/${resource.assetPrefix}-bar-${size.assetSuffix}.png';
    final backgroundAssetPath =
        'images/ui/backgrounds/$themeId/background-${insetBackgroundType.name}-${size.assetSuffix}.png';
    // Below size.minSize, the slice's fixed corners overlap and paintImage
    // throws — enforced here (padding included) so no caller can pass a
    // height that crashes, or shrinks either the bar or background image
    // below its own corners into a borderless flat box.
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: size.minSize.width + _padding.horizontal,
        minHeight: size.minSize.height + _padding.vertical,
      ),
      child: Container(
        height: height,
        width: width,
        padding: _padding,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(backgroundAssetPath),
            centerSlice: size.slice,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        child: Stack(
          children: [
            FractionallySizedBox(
              widthFactor: fraction,
              child: Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(barAssetPath),
                    centerSlice: size.slice,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
            ),
            Center(child: child),
          ],
        ),
      ),
    );
  }
}
