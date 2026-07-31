import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_background.dart';

/// Shared modal-sheet chrome for the add-todo and edit-todo screens: a
/// DraggableScrollableSheet (so dragging down from the top of the content
/// hands off to the modal's own dismiss animation via shouldCloseOnMinExtent)
/// wrapping a scrollable QvBackground. Callers supply their own header
/// (cancel/save actions differ between add and edit) and body content.
class TodoFormSheet extends StatelessWidget {
  const TodoFormSheet({
    super.key,
    required this.header,
    required this.body,
  });

  final Widget header;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      maxChildSize: 0.92,
      minChildSize: 0.1,
      expand: false,
      snap: true,
      builder: (context, scrollController) {
        return QvBackground(
          width: double.infinity,
          height: double.infinity,
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const CalmSnapScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [header, body],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// DraggableScrollableSheet's snap-on-release only picks the *nearest* snap
/// size (min or max) when the release velocity is within tolerance;
/// otherwise it jumps to the next size in the fling's direction, however far
/// that is. The default tolerance is only a few px/s, so almost any
/// perceptible release velocity counts as a fling and can send a small drag
/// near the top of the content all the way down to the dismiss size.
/// Widening the velocity tolerance means only a deliberate fast flick
/// triggers that directional jump; slower releases settle on whichever size
/// (open or dismiss) is actually closer.
class CalmSnapScrollPhysics extends ScrollPhysics {
  const CalmSnapScrollPhysics({super.parent});

  @override
  CalmSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CalmSnapScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Tolerance toleranceFor(ScrollMetrics metrics) {
    final defaultTolerance = super.toleranceFor(metrics);
    return Tolerance(
      velocity: 1000,
      distance: defaultTolerance.distance,
      time: defaultTolerance.time,
    );
  }
}
