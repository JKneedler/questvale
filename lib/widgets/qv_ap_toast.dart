import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

// Shows a transient "+ N AP" pill about a third of the way down the screen.
// Fire-and-forget: inserts its own OverlayEntry and removes itself once its
// animation finishes, so callers don't need to hold a reference.
void showApToast(BuildContext context, int amount) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ApToast(
      amount: amount,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _ApToast extends StatefulWidget {
  final int amount;
  final VoidCallback onDone;

  const _ApToast({required this.amount, required this.onDone});

  @override
  State<_ApToast> createState() => _ApToastState();
}

class _ApToastState extends State<_ApToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    );
    // Fade-in and hold keep their original ~210ms/~840ms pace; fade-out is
    // stretched to ~700ms (was ~350ms) so the sink-and-fade reads as a slow
    // drift rather than a quick disappear.
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 48),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_controller);
    // Holds in place through the fade-in and hold phases, then sinks
    // downward as it fades out — like a game's floating EXP indicator.
    _translateY = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 60),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 30.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 40,
      ),
    ]).animate(_controller);
    _controller.forward().whenComplete(widget.onDone);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final screenHeight = MediaQuery.of(context).size.height;

    return Positioned(
      bottom: screenHeight / 5,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, _translateY.value),
              child: Opacity(opacity: _opacity.value, child: child),
            ),
            child: QvButton(
              buttonColor: ButtonColor.primary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                '+ ${widget.amount} AP',
                style: QvTextStyles.sectionTitle.copyWith(color: colorScheme.onPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
