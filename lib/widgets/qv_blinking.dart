import 'package:flutter/material.dart';

class QvBlinking extends StatefulWidget {
  const QvBlinking({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.minOpacity = 0.2,
    this.curve = Curves.easeInOut,
  });

  final Widget child;
  final Duration duration;
  final double minOpacity; // 0–1
  final Curve curve;

  @override
  State<QvBlinking> createState() => _QvBlinkingState();
}

class _QvBlinkingState extends State<QvBlinking> {
  bool _high = true; // toggles between high (1.0) and low (minOpacity)

  @override
  void initState() {
    super.initState();
    // Kick off the first transition after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _high = !_high);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _high ? 1.0 : widget.minOpacity,
      duration: widget.duration,
      curve: widget.curve,
      onEnd: () => setState(() => _high = !_high), // loop forever
      child: widget.child,
    );
  }
}
