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

  // Pressed-state textures exist for every registered theme's primary/
  // secondary/surface/surfaceContainer assets (generated via the
  // retheme-color Light/Dark-swap technique). Rarity/silver buttons don't
  // have a pressed variant, so QvButton falls back to the normal texture
  // for those.
  String? pressedAssetPath(String themeId) {
    switch (this) {
      case ButtonColor.primary:
        return 'images/ui/buttons/$themeId/button-primary-pressed.png';
      case ButtonColor.secondary:
        return 'images/ui/buttons/$themeId/button-secondary-pressed.png';
      case ButtonColor.surface:
        return 'images/ui/buttons/$themeId/button-surface-pressed.png';
      case ButtonColor.surfaceContainer:
        return 'images/ui/buttons/$themeId/button-surface-container-pressed.png';
      default:
        return null;
    }
  }
}

class QvButton extends StatefulWidget {
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
  State<QvButton> createState() => _QvButtonState();
}

class _QvButtonState extends State<QvButton> {
  bool _isPressed = false;

  void _setPressed(bool pressed) {
    if (_isPressed != pressed) {
      setState(() => _isPressed = pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeId = context.watch<ThemeCubit>().state.theme.id;
    final pressedAssetPath = widget.buttonColor.pressedAssetPath(themeId);
    final showPressed = _isPressed && pressedAssetPath != null;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: GestureDetector(
        onTap: widget.onTap ?? () {},
        onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
        onTapUp: widget.onTap == null ? null : (_) => _setPressed(false),
        onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 60),
          curve: Curves.easeOut,
          child: Container(
            width: widget.width,
            height: widget.height,
            padding: widget.padding,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(showPressed
                    ? pressedAssetPath
                    : widget.buttonColor.assetPath(themeId)),
                centerSlice: STANDARD_BORDER_SLICE,
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
                colorFilter: widget.darkened
                    ? ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.5), BlendMode.srcATop)
                    : null,
              ),
              boxShadow: widget.shadow,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
