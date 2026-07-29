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
        color: isChecked
            ? colorScheme.onPrimaryFixedVariant
            : colorScheme.onPrimaryContainer,
        filterQuality: FilterQuality.none,
        image: isChecked
            ? AssetImage('images/ui/white-checkbox-checked.png')
            : AssetImage('images/ui/white-checkbox.png'),
        fit: BoxFit.fill,
      ),
    );
  }
}
