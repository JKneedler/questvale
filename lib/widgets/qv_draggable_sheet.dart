import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_background.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';

/// Shared modal-sheet chrome, originally built for the add-todo/edit-todo
/// screens (see TodoFormSheet, which now just supplies a todo-specific
/// header on top of this) and reused by TownVisitSheet for the Combat &
/// Questing Redesign ticket. A DraggableScrollableSheet — dragging down from
/// the top of the content hands off to the modal's own dismiss animation via
/// shouldCloseOnMinExtent — wrapping a QvBackground, with [header] pinned as
/// a fixed-height overlay above the body.
class QvDraggableSheet extends StatelessWidget {
  const QvDraggableSheet({
    super.key,
    required this.header,
    required this.headerHeight,
    required this.body,
    this.footer,
    this.scrollableBody = true,
    this.initialChildSize = 0.92,
    this.maxChildSize = 0.92,
    this.minChildSize = 0.1,
  });

  final Widget header;
  final double headerHeight;
  final Widget body;

  /// Extra content below the body, only ever rendered when [scrollableBody]
  /// is true (see its own doc comment) — todo forms use this for a trailing
  /// delete button.
  final Widget? footer;

  /// True (the todo-form default): [body] is pushed through a
  /// SingleChildScrollView tied to the sheet's own drag controller, for
  /// content genuinely taller than the sheet (a long form). False: [body]
  /// fills the space below the header directly instead, with bounded height
  /// — for embedding a page that already manages its own internal layout
  /// (Expanded children, its own scrollables) and would otherwise break
  /// inside an unbounded SingleChildScrollView. The trade-off: a drag
  /// starting inside such a body's own scrollable won't resize/dismiss the
  /// sheet the way dragging the todo-form's single scrollable does — tap
  /// outside or a close button remain the dismiss paths.
  final bool scrollableBody;

  final double initialChildSize;
  final double maxChildSize;
  final double minChildSize;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialChildSize,
      maxChildSize: maxChildSize,
      minChildSize: minChildSize,
      expand: false,
      snap: true,
      builder: (context, scrollController) {
        return QvBackground(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: SafeArea(
            top: false,
            // Stack instead of Column+Expanded: as the sheet shrinks toward
            // its dismiss size, the available height briefly drops below the
            // fixed header's natural height. A Column would report that as a
            // RenderFlex overflow (an assertion Flutter always logs/paints
            // regardless of any ancestor ClipRect — clipping the canvas
            // doesn't stop the layout-time overflow check from firing).
            // Stack has no such check: it clips out-of-bounds children by
            // default (Clip.hardEdge) with no warning, so the same brief
            // shrink-past-header moment is just silently clipped instead.
            child: Stack(
              children: [
                Positioned.fill(
                  top: headerHeight,
                  child: scrollableBody
                      ? QvFadingScrollable(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            physics: const CalmSnapScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                body,
                                if (footer != null) ...[
                                  const SizedBox(height: 8),
                                  footer!,
                                ],
                                // DraggableScrollableSheet's own extent
                                // doesn't shrink for the keyboard, so
                                // without this the scrollable has no genuine
                                // extra room below its last child — a
                                // focused field's scroll-into-view can
                                // compute a target offset clamped short of
                                // actually clearing the keyboard. This
                                // spacer grows with the keyboard's own
                                // inset, giving that scroll somewhere real
                                // to land.
                                SizedBox(
                                    height: MediaQuery.of(context)
                                        .viewInsets
                                        .bottom),
                              ],
                            ),
                          ),
                        )
                      : body,
                ),
                Positioned(top: 0, left: 0, right: 0, child: header),
              ],
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
