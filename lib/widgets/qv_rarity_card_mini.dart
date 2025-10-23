import 'package:flutter/material.dart';
import 'package:questvale/helpers/shared_enums.dart';

class QvRarityCardMini extends StatelessWidget {
  final Rarity rarity;
  final double width;
  final double height;
  final Widget child;
  final Color bgColor;
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;

  const QvRarityCardMini(
      {super.key,
      required this.rarity,
      required this.child,
      this.width = 0,
      this.height = 0,
      this.bgColor = Colors.transparent,
      this.widthFactor = .9,
      this.heightFactor = .9,
      this.padding = const EdgeInsets.all(12)});

  @override
  Widget build(BuildContext context) {
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
                  image: AssetImage(
                      'images/ui/borders/${rarity.name.toLowerCase()}-border-mini-2x.png'),
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
