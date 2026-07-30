import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showSeparator = false,
  });

  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showSeparator;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSeparator)
              Container(height: 2, color: colorScheme.secondary),
            SizedBox(height: 8),
            SizedBox(
              width: MediaQuery.of(context).size.width + 20,
              // 50 comfortably fits the icon slot's natural height (28px
              // icon + 16px vertical padding = 44px), with a little headroom.
              height: 50 + bottomPadding,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: List.generate(items.length, (i) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onTap(i),
                      behavior: HitTestBehavior.translucent,
                      child: Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        color: items[i].selected
                            ? colorScheme.primary
                            : colorScheme.secondary,
                        child: Image.asset(
                          'images/ui/icons/${items[i].iconName}-icon.png',
                          filterQuality: FilterQuality.none,
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NavBarItem {
  const NavBarItem({
    required this.iconName,
    required this.label,
    this.selected = false,
  });

  final String iconName;
  final String label;
  final bool selected;
}
