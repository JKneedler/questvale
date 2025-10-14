import 'package:flutter/material.dart';

class QVNavBar extends StatelessWidget {
  const QVNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<QVNavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  AssetImage getImage(int index) {
    if (index == currentIndex) {
      if (index == 0) {
        return AssetImage('images/ui/borders/primary-nav-selected-left-2x.png');
      } else if (index == 4) {
        return AssetImage(
            'images/ui/borders/primary-nav-selected-right-2x.png');
      } else {
        return AssetImage(
            'images/ui/borders/primary-nav-selected-wider-2x.png');
      }
    } else if (index == currentIndex - 1) {
      return AssetImage('images/ui/borders/primary-nav-top-left-2x.png');
    } else if (index == currentIndex + 1) {
      return AssetImage('images/ui/borders/primary-nav-top-right-2x.png');
    } else {
      return AssetImage('images/ui/borders/primary-nav-top-2x.png');
    }
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      elevation: 10,
      color: colorScheme.primary,
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: MediaQuery.of(context).size.width + 20,
          height: 48 + bottomPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
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
                      image: DecorationImage(
                        image: getImage(i),
                        centerSlice: Rect.fromLTWH(16, 16, 32, 32),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.none,
                      ),
                    ),
                    child: Column(
                      spacing: 4,
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 35,
                          height: 35,
                          child: items[i].icon,
                        ),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            color: currentIndex == i
                                ? colorScheme.onSurface
                                : colorScheme.onPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class QVNavBarItem {
  const QVNavBarItem({
    required this.icon,
    required this.label,
    this.activeColor = const Color(0xFF9B87F5),
    this.inactiveColor = const Color(0xFF9AA0A6),
  });

  final Widget icon;
  final String label;
  final Color activeColor;
  final Color inactiveColor;
}
