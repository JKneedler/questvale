import 'package:flutter/material.dart';

class QvFadeIn extends StatefulWidget {
  const QvFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 700),
    this.delay = Duration.zero,
    this.curve = Curves.easeOutCubic,
    this.beginOpacity = 0.0,
    this.endOpacity = 1.0,
    this.playOnce = true, // if false, it’ll re-run whenever the key changes
  });

  final Widget child;
  final Duration duration;
  final Duration delay;
  final Curve curve;
  final double beginOpacity;
  final double endOpacity;
  final bool playOnce;

  @override
  State<QvFadeIn> createState() => _QvFadeInState();
}

class _QvFadeInState extends State<QvFadeIn> {
  late double _opacity = widget.beginOpacity;
  bool _played = false;

  @override
  void initState() {
    super.initState();
    _kickoff();
  }

  @override
  void didUpdateWidget(covariant QvFadeIn oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If not playOnce and we got a new key/instance, run again
    if (!widget.playOnce && oldWidget.key != widget.key) {
      _played = false;
      _opacity = widget.beginOpacity;
      _kickoff();
    }
  }

  void _kickoff() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || (widget.playOnce && _played)) return;
      if (widget.delay > Duration.zero) {
        await Future<void>.delayed(widget.delay);
        if (!mounted) return;
      }
      setState(() {
        _opacity = widget.endOpacity;
        _played = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _opacity,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.child,
    );
  }
}
