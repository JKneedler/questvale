import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';

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
              image: AssetImage('images/ui/buttons/button-silver.png'),
              centerSlice: STANDARD_BORDER_SLICE,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
