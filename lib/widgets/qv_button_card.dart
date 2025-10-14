import 'package:flutter/material.dart';

class QVButtonCard extends StatelessWidget {
  const QVButtonCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primary,
      foregroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/ui/white-frame-border-9s-2x.png'),
          centerSlice: Rect.fromLTWH(16, 16, 32, 32),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
      child: child,
    );
  }
}
