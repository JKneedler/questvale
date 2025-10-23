import 'package:flutter/material.dart';

class QvCheckBox extends StatelessWidget {
  final double width;
  final double height;
  final bool isChecked;

  const QvCheckBox(
      {super.key,
      required this.width,
      required this.height,
      required this.isChecked});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: Image(
        color: isChecked ? Colors.black54 : Colors.black87,
        filterQuality: FilterQuality.none,
        image: isChecked
            ? AssetImage('images/ui/white-checkbox-checked.png')
            : AssetImage('images/ui/white-checkbox.png'),
        fit: BoxFit.fill,
      ),
    );
    // return Container(
    //   width: width,
    //   height: height,
    //   decoration: BoxDecoration(
    //     color: isChecked ? colorScheme.onPrimaryFixedVariant : null,
    //     // borderRadius: BorderRadius.circular(4),
    //     border: Border.all(
    //       color: isChecked
    //           ? Colors.transparent
    //           : outlineColor ?? colorScheme.onPrimaryFixedVariant,
    //       width: 1.5,
    //     ),
    //   ),
    //   child: isChecked
    //       ? Center(
    //           child: Icon(
    //             Symbols.check,
    //             color: colorScheme.primaryContainer,
    //             size: width * 0.9,
    //             weight: 900,
    //           ),
    //         )
    //       : null,
    // );
  }
}
