import 'package:flutter/material.dart';

class QvSilverButton extends StatelessWidget {
  const QvSilverButton({
    super.key,
    this.onTap,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(0),
    required this.child,
  });

  final VoidCallback? onTap;
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsets padding;

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
            image: AssetImage('images/ui/buttons/white-button-filled-2x.png'),
            centerSlice: Rect.fromLTWH(16, 16, 32, 32),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        child: child,
      ),
    );
  }
}
