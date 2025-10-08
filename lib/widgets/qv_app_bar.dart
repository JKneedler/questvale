import 'package:flutter/material.dart';

class QVAppBar extends StatelessWidget {
  const QVAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      height: 60 + topPadding,
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      foregroundDecoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/ui/bronze-button-rounded-bottom-9s-1x.png'),
          centerSlice: Rect.fromLTWH(8, 8, 16, 16),
          fit: BoxFit.fill,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Questvale',
                style: TextStyle(color: colorScheme.onPrimary, fontSize: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
