import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';

class QvMetalCornerBorder extends StatelessWidget {
  final Widget child;
  final double widthFactor;
  final double heightFactor;
  final EdgeInsets padding;
  final Color? color;

  const QvMetalCornerBorder({
    super.key,
    required this.child,
    this.widthFactor = .95,
    this.heightFactor = .95,
    this.padding = const EdgeInsets.all(6),
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: METAL_CORNER_BORDER_MIN_SIZE.width,
        minHeight: METAL_CORNER_BORDER_MIN_SIZE.height,
      ),
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: widthFactor,
              heightFactor: heightFactor,
              child: Container(
                color: color ?? colorScheme.surface,
                padding: padding,
                child: child,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                foregroundDecoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'images/ui/borders/primary-metal-edge-border-2x.png'),
                    centerSlice: METAL_CORNER_BORDER_SLICE,
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
