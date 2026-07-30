import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/shared_enums.dart';

enum QvCardBorderType {
  rarity,
  primary,
  surface,
  surfaceContainer,
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
          return rarity.borderAssetPath;
        case QvCardBorderType.primary:
          return 'images/ui/borders/border-primary-mini.png';
        case QvCardBorderType.surface:
          return 'images/ui/borders/border-surface-mini.png';
        case QvCardBorderType.surfaceContainer:
          return 'images/ui/borders/border-surface-container-mini.png';
      }
    }

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: SizedBox(
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
                    centerSlice: STANDARD_BORDER_SLICE,
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
      ),
    );
  }
}
