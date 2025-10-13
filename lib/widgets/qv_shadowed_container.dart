import 'package:flutter/material.dart';

class QvShadowedContainer extends StatelessWidget {
  const QvShadowedContainer(
      {super.key,
      this.borderRadius = 12,
      this.offset = const Offset(0, 2),
      required this.child});

  final Widget child;
  final double borderRadius;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Transform.translate(
          offset: offset,
          child: Center(
            child: FractionallySizedBox(
              widthFactor: .99,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 0, 0, 1), // shadow color
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}
