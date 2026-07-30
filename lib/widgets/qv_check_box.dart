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
            ? colorScheme.onSurface.withValues(alpha: 0.5)
            : colorScheme.onSurface,
        filterQuality: FilterQuality.none,
        image: isChecked
            ? AssetImage('images/ui/checkbox-checked.png')
            : AssetImage('images/ui/checkbox-unchecked.png'),
        fit: BoxFit.fill,
      ),
    );
  }
}
