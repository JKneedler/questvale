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

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Material(
      elevation: 10,
      color: colorScheme.primary,
      child: SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          width: MediaQuery.of(context).size.width + 20,
          height: 48 + bottomPadding,
          foregroundDecoration: BoxDecoration(
            image: DecorationImage(
              image:
                  AssetImage('images/ui/bronze-button-rounded-top-9s-1x.png'),
              centerSlice: Rect.fromLTWH(8, 8, 16, 16),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(items.length, (i) {
              return GestureDetector(
                onTap: () => onTap(i),
                child: Container(
                  width: 60,
                  height: 60,
                  alignment: Alignment.center,
                  foregroundDecoration: BoxDecoration(
                    image: DecorationImage(
                      image: i == currentIndex
                          ? AssetImage('images/ui/orange-slot-border-9s-1x.png')
                          : AssetImage(
                              'images/ui/orange-slot-border-in-9s-1x.png'),
                      centerSlice: Rect.fromLTWH(8, 8, 16, 16),
                      fit: BoxFit.fill,
                      filterQuality: FilterQuality.none,
                    ),
                  ),
                  decoration: BoxDecoration(
                    color: i == currentIndex
                        ? colorScheme.primary
                        : Color(0xff503c3b),
                  ),
                  child: SizedBox(
                    width: 35,
                    height: 35,
                    child: items[i].icon,
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
