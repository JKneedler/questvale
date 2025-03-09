import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class CheckBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isChecked;

  const CheckBox(
      {super.key,
      required this.width,
      required this.height,
      required this.isChecked});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isChecked ? colorScheme.onPrimaryFixedVariant : null,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: colorScheme.onPrimaryFixedVariant,
          width: 1.5,
        ),
      ),
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
