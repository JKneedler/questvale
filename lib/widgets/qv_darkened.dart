import 'package:flutter/material.dart';

class QvDarkened extends StatelessWidget {
  final Widget child;
  final bool isEnabled;
  const QvDarkened({super.key, required this.child, this.isEnabled = false});

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
        colorFilter: ColorFilter.mode(
            Colors.black.withValues(alpha: isEnabled ? 0.2 : 0),
            BlendMode.darken),
        child: child);
  }
}
