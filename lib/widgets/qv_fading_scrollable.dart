import 'package:flutter/material.dart';
import 'package:questvale/helpers/constants.dart';

/// Softens a scrollable's clipped edges with a fade instead of a hard cut,
/// showing the fade only on edges that actually have more content beyond
/// them — it doubles as a "there's more to scroll" affordance rather than a
/// purely decorative vignette. Wrap this directly around a
/// ListView/GridView/SingleChildScrollView/etc. (the scrollable itself, not
/// some ancestor Padding/Container) — the fade is a ShaderMask over the
/// scrollable's own paint bounds, and it listens for that descendant's
/// scroll notifications to know how close to each edge it is.
///
/// The fade distance is content-relative pixels (SCROLL_FADE_DISTANCE),
/// converted to a fraction of the scrollable's rendered extent so it reads
/// the same regardless of how big that particular scrollable is.
class QvFadingScrollable extends StatefulWidget {
  const QvFadingScrollable({
    super.key,
    required this.child,
    this.direction = Axis.vertical,
    this.fadeStart = true,
    this.fadeEnd = true,
  });

  final Widget child;
  final Axis direction;

  /// Whether the leading edge (top for vertical, left for horizontal) is
  /// allowed to fade at all — set false when that edge is a fixed boundary
  /// that should never fade even if the scrollable somehow reports content
  /// beyond it. Normally leave this true: the fade only actually renders
  /// once the scrollable is scrolled past its start, so a list at rest
  /// already shows no fade here.
  final bool fadeStart;

  /// Whether the trailing edge (bottom for vertical, right for horizontal)
  /// is allowed to fade at all. See [fadeStart].
  final bool fadeEnd;

  @override
  State<QvFadingScrollable> createState() => _QvFadingScrollableState();
}

class _QvFadingScrollableState extends State<QvFadingScrollable> {
  bool _canScrollStart = false;
  bool _canScrollEnd = false;

  bool _handleScrollMetrics(ScrollMetrics metrics) {
    final canScrollStart = metrics.extentBefore > 0.5;
    final canScrollEnd = metrics.extentAfter > 0.5;
    if (canScrollStart != _canScrollStart || canScrollEnd != _canScrollEnd) {
      setState(() {
        _canScrollStart = canScrollStart;
        _canScrollEnd = canScrollEnd;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final extent = widget.direction == Axis.vertical
            ? constraints.maxHeight
            : constraints.maxWidth;
        final fadeFraction =
            extent > 0 ? (SCROLL_FADE_DISTANCE / extent).clamp(0.0, 0.5) : 0.0;
        final fadeStart = widget.fadeStart && _canScrollStart;
        final fadeEnd = widget.fadeEnd && _canScrollEnd;

        return NotificationListener<Notification>(
          onNotification: (notification) {
            if (notification is ScrollNotification) {
              return _handleScrollMetrics(notification.metrics);
            }
            if (notification is ScrollMetricsNotification) {
              return _handleScrollMetrics(notification.metrics);
            }
            return false;
          },
          child: ShaderMask(
            blendMode: BlendMode.dstIn,
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: widget.direction == Axis.vertical
                    ? Alignment.topCenter
                    : Alignment.centerLeft,
                end: widget.direction == Axis.vertical
                    ? Alignment.bottomCenter
                    : Alignment.centerRight,
                colors: const [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [
                  0.0,
                  fadeStart ? fadeFraction : 0.0,
                  fadeEnd ? 1 - fadeFraction : 1.0,
                  1.0,
                ],
              ).createShader(bounds);
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}
