import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

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
            SizedBox(
              width: MediaQuery.of(context).size.width + 20,
              height: 6 + bottomPadding,
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
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                        ),
                        child: QvInsetBackground(
                          type: QvInsetBackgroundType.secondary,
                          enabled: items[i].selected,
                          width: 100,
                          padding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          child: Image.asset(
                            'images/ui/icons/${items[i].iconName}-icon-${items[i].selected ? 'primary' : 'secondary'}.png',
                            filterQuality: FilterQuality.none,
                            scale: .1,
                            fit: BoxFit.contain,
                          ),
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
