import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

// Shows a transient "- N HP" pill about a third of the way down the screen,
// for when an enemy attack resolves and damages the player — the same
// fire-and-forget shape as QvApToast (qv_ap_toast.dart), just styled as a
// hit taken rather than AP gained.
void showDamageToast(BuildContext context, int amount) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _DamageToast(
      amount: amount,
      onDone: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _DamageToast extends StatefulWidget {
  final int amount;
  final VoidCallback onDone;

  const _DamageToast({required this.amount, required this.onDone});

  @override
  State<_DamageToast> createState() => _DamageToastState();
}

class _DamageToastState extends State<_DamageToast>
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
    _opacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 12),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 48),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
    ]).animate(_controller);
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
              buttonColor: ButtonColor.fireRed,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Text(
                '- ${widget.amount} HP',
                style: QvTextStyles.sectionTitle.copyWith(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
