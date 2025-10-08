import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class QvCheckBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isChecked;
  final Color? outlineColor;

  const QvCheckBox(
      {super.key,
      required this.width,
      required this.height,
      required this.isChecked,
      this.outlineColor});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isChecked ? colorScheme.onPrimaryFixedVariant : null,
        // borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isChecked
              ? Colors.transparent
              : outlineColor ?? colorScheme.onPrimaryFixedVariant,
          width: 1.5,
        ),
      ),
      // foregroundDecoration: BoxDecoration(
      //   image: DecorationImage(
      //     image: AssetImage('images/ui/white-full-border-9s-1x.png'),
      //     centerSlice: Rect.fromLTWH(8, 8, 16, 16),
      //     fit: BoxFit.fill,
      //     filterQuality: FilterQuality.none,
      //   ),
      // ),
      child: isChecked
          ? Center(
              child: Icon(
                Symbols.check,
                color: colorScheme.primaryContainer,
                size: width * 0.9,
                weight: 900,
              ),
            )
          : null,
    );
  }
}
