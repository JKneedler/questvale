import 'package:flutter/material.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum ButtonColor {
  primary,
  secondary,
  surface,
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
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'images/ui/buttons/${buttonColor.name.toString()}-button-2x.png'),
            centerSlice: Rect.fromLTWH(16, 16, 32, 32),
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
    );
  }
}
