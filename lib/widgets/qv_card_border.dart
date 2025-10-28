import 'package:flutter/material.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum QvCardBorderType {
  rarity,
  primary,
  surface,
}

class QvCardBorder extends StatelessWidget {
  final QvCardBorderType type;
  final Rarity rarity;
  final double width;
  final double height;
  final Widget child;
  final Color bgColor;
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;

  const QvCardBorder(
      {super.key,
      this.type = QvCardBorderType.rarity,
      this.rarity = Rarity.common,
      required this.child,
      this.width = 0,
      this.height = 0,
      this.bgColor = Colors.transparent,
      this.widthFactor = .9,
      this.heightFactor = .9,
      this.padding = const EdgeInsets.all(12)});

  @override
  Widget build(BuildContext context) {
    String getBorderImage() {
      switch (type) {
        case QvCardBorderType.rarity:
          return 'images/ui/borders/${rarity.name.toLowerCase()}-border-mini-2x.png';
        case QvCardBorderType.primary:
          return 'images/ui/borders/primary-border-mini-2x.png';
        case QvCardBorderType.surface:
          return 'images/ui/borders/surface-border-mini-2x.png';
      }
    }

    return SizedBox(
      height: height > 0 ? height : null,
      width: width > 0 ? width : null,
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              heightFactor: heightFactor,
              child: Container(
                color: bgColor,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(getBorderImage()),
                  centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
              padding: padding,
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
