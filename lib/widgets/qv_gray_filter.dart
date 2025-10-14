import 'package:flutter/material.dart';

class QVGrayFilter extends StatelessWidget {
  final Widget child;
  final bool isEnabled;
  const QVGrayFilter({super.key, required this.child, this.isEnabled = true});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: isEnabled
          ? const ColorFilter.matrix(<double>[
              // R         G         B         A  Bias
              0.2126, 0.7152, 0.0722, 0, 0, // R'
              0.2126, 0.7152, 0.0722, 0, 0, // G'
              0.2126, 0.7152, 0.0722, 0, 0, // B'
              0, 0, 0, 1, 0, // A'
            ])
          : const ColorFilter.mode(Colors.transparent, BlendMode.color),
      child: child,
    );
  }
}
