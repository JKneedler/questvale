import 'package:flutter/material.dart';

class QVAppBar extends StatelessWidget {
  const QVAppBar({
    super.key,
    this.title = 'Questvale',
    this.includeBackButton = false,
  });

  final String title;
  final bool includeBackButton;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: topPadding, left: 16, right: 16),
      height: 60 + topPadding,
      color: colorScheme.surface,
      child: Row(
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: includeBackButton
                ? GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SizedBox(
                        child: Text('<',
                            style: TextStyle(
                                fontSize: 26, color: colorScheme.onSurface))),
                  )
                : SizedBox.shrink(),
          ),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 28),
              ),
            ),
          ),
          SizedBox(width: 40, height: 40),
        ],
      ),
    );
  }
}
