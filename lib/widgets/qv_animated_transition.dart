import 'package:flutter/widgets.dart';

enum QvAnimatedTransitionType {
  slideLeft,
  slideRight,
  fade;
}

class QvAnimatedTransition extends StatelessWidget {
  const QvAnimatedTransition({
    super.key,
    required this.duration,
    required this.type,
    required this.child,
  });

  final Widget child;
  final QvAnimatedTransitionType type;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: duration,
      transitionBuilder: (child, animation) {
        return _QvAnimatedTransition(
          type: type,
          animation: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}

class _QvAnimatedTransition extends StatelessWidget {
  final Animation<double> animation;
  final QvAnimatedTransitionType type;
  final Widget child;

  const _QvAnimatedTransition({
    required this.animation,
    required this.type,
    required this.child,
  });

  bool get _isIncoming {
    // New child: controller goes forward (0 -> 1)
    // Old child: controller goes reverse (1 -> 0)
    return animation.status == AnimationStatus.forward ||
        // This extra check covers the very first frame where status
        // might already be completed for the "only child" case.
        (animation.status == AnimationStatus.completed &&
            animation.value == 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        if (type == QvAnimatedTransitionType.slideLeft ||
            type == QvAnimatedTransitionType.slideRight) {
          // Choose the appropriate tween for THIS child
          final Tween<Offset> tween = _isIncoming
              // Incoming page: start just off-screen right, slide to center
              ? Tween<Offset>(
                  begin: type == QvAnimatedTransitionType.slideLeft
                      ? const Offset(1.0, 0.0)
                      : const Offset(-1.0, 0.0),
                  end: Offset.zero,
                )
              // Outgoing page: start centered, slide off to the left
              : Tween<Offset>(
                  begin: type == QvAnimatedTransitionType.slideLeft
                      ? const Offset(-1.0, 0.0)
                      : const Offset(1.0, 0.0),
                  end: Offset.zero,
                );

          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );

          return SlideTransition(
            position: tween.animate(curved),
            child: child,
          );
        } else if (type == QvAnimatedTransitionType.fade) {
          // Choose the appropriate tween for THIS child
          final Tween<double> tween = _isIncoming
              // Incoming page: start at 0, fade to 1
              ? Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                )
              // Outgoing page: start at 1, fade to 0
              : Tween<double>(
                  begin: 0.0,
                  end: 1.0,
                );

          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          );
          return FadeTransition(
            opacity: tween.animate(curved),
            child: child,
          );
        }
        return child;
      },
    );
  }
}
