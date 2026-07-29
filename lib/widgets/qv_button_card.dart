import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';

// NOTE: unused today (no call sites), and its asset
// images/ui/white-frame-border-9s-2x.png does not exist on disk — this will
// throw an asset-load error the moment something renders it. Needs real art
// before this widget is used.
class QVButtonCard extends StatelessWidget {
  const QVButtonCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: STANDARD_BORDER_MIN_SIZE.width,
        minHeight: STANDARD_BORDER_MIN_SIZE.height,
      ),
      child: Container(
        color: colorScheme.primary,
        foregroundDecoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/ui/white-frame-border-9s-2x.png'),
            centerSlice: STANDARD_BORDER_SLICE,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        child: child,
      ),
    );
  }
}
