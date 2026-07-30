import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/theme/theme_cubit.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum ButtonColor {
  primary,
  secondary,
  surface,
  surfaceContainer,
  silver,
  common,
  uncommon,
  rare,
  legendary,
  epic;

  static ButtonColor getColor(Rarity rarity) {
    switch (rarity) {
      case Rarity.common:
        return ButtonColor.common;
      case Rarity.uncommon:
        return ButtonColor.uncommon;
      case Rarity.rare:
        return ButtonColor.rare;
      case Rarity.epic:
        return ButtonColor.epic;
      case Rarity.legendary:
        return ButtonColor.legendary;
      default:
        return ButtonColor.common;
    }
  }

  // Primary/secondary/surface/surfaceContainer are theme-dependent — each
  // registered theme (constants.dart's APP_THEMES) has its own asset folder
  // under images/ui/buttons/{themeId}/. Rarity/silver assets are shared
  // across every theme, so they stay in the flat buttons/ directory.
  String assetPath(String themeId) {
    switch (this) {
      case ButtonColor.primary:
        return 'images/ui/buttons/$themeId/button-primary.png';
      case ButtonColor.secondary:
        return 'images/ui/buttons/$themeId/button-secondary.png';
      case ButtonColor.surface:
        return 'images/ui/buttons/$themeId/button-surface.png';
      case ButtonColor.surfaceContainer:
        return 'images/ui/buttons/$themeId/button-surface-container.png';
      case ButtonColor.silver:
        return 'images/ui/buttons/button-silver.png';
      case ButtonColor.common:
        return 'images/ui/buttons/button-rarity-common.png';
      case ButtonColor.uncommon:
        return 'images/ui/buttons/button-rarity-uncommon.png';
      case ButtonColor.rare:
        return 'images/ui/buttons/button-rarity-rare.png';
      case ButtonColor.legendary:
        return 'images/ui/buttons/button-rarity-legendary.png';
      case ButtonColor.epic:
        return 'images/ui/buttons/button-rarity-epic.png';
    }
  }
}

class QvButton extends StatelessWidget {
  const QvButton({
    super.key,
    this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(0),
    this.buttonColor = ButtonColor.primary,
    this.darkened = false,
    this.shadow,
    required this.child,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;
  final ButtonColor buttonColor;
  final bool darkened;
  final List<BoxShadow>? shadow;
  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: GestureDetector(
        onTap: onTap ?? () {},
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(buttonColor.assetPath(themeId)),
              centerSlice: STANDARD_BORDER_SLICE,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
              colorFilter: darkened
                  ? ColorFilter.mode(
                      Colors.black.withValues(alpha: 0.5), BlendMode.srcATop)
                  : null,
            ),
            boxShadow: shadow,
          ),
          child: child,
        ),
      ),
    );
  }
}
