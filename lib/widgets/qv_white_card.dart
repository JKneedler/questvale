import 'package:flutter/material.dart';

class QVWhiteCard extends StatelessWidget {
  const QVWhiteCard({
    super.key,
    required this.child,
    required this.onTap,
    this.padding =
        const EdgeInsets.only(left: 24, right: 24, top: 40, bottom: 40),
    this.decorationImage = '',
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback onTap;
  final String decorationImage;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Center(
            child: FractionallySizedBox(
              widthFactor: .95,
              heightFactor: .95,
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  image: decorationImage.isNotEmpty
                      ? DecorationImage(
                          image: AssetImage(decorationImage),
                          fit: BoxFit.cover,
                          filterQuality: FilterQuality.none,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              padding: padding,
              foregroundDecoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/ui/borders/primary-border-2x.png'),
                  centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                  fit: BoxFit.fill,
                  filterQuality: FilterQuality.none,
                ),
              ),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
