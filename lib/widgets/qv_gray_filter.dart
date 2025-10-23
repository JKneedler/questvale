import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';

class QVGrayFilter extends StatelessWidget {
  final Widget child;
  final bool isEnabled;
  const QVGrayFilter({super.key, required this.child, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: isEnabled
          ? const ColorFilter.matrix(GRAY_FILTER_MATRIX)
          : const ColorFilter.mode(Colors.transparent, BlendMode.color),
      child: child,
    );
  }
}
