import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

class NavBar extends StatelessWidget {
  const NavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.showSeparator = false,
    this.modalSheetOpen = false,
  });

  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool showSeparator;

  // True while a TownVisitSheet (or any future bottom sheet that leaves the
  // nav bar visible beneath it) is open — see NavState.modalSheetOpen's own
  // doc comment. Swaps the nav bar's background to colorScheme.surfaceContainer
  // to match QvBackground's own fill (see qv_background.dart's
  // surfaceContainerNoBottom asset), so the sheet and the bar beneath it read
  // as one continuous surface instead of a visible color seam.
  final bool modalSheetOpen;

  // Width of the sliding QvInsetBackground highlight and the height of the
  // band it (and the icons) sit in — matches the old per-item
  // QvInsetBackground's own width and its 28px icon + 16px padding.
  static const double _highlightWidth = 100;
  static const double _bandHeight = 44;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bandColor =
        modalSheetOpen ? colorScheme.surfaceContainer : colorScheme.surface;

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
              // icon + 16px QvInsetBackground padding = 44px) above the
              // centerSlice border's 36px minimum, with a little headroom.
              // The device's bottom safe-area inset (home indicator etc.)
              // is already handled by the SafeArea above — adding it here
              // too just pushed the row up with dead space above it rather
              // than clearance below it.
              height: 50,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / items.length;
                  return Stack(
                    children: [
                      // Matches the original per-item background bounds
                      // (each item's Container was only as tall as its
                      // content, ~44px, bottom-aligned) as one shared band.
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: _bandHeight,
                        child: Container(color: bandColor),
                      ),
                      // The highlight is now a single shared widget that
                      // slides between slots (via AnimatedPositioned)
                      // instead of each item toggling its own copy on/off.
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                        left: itemWidth * currentIndex +
                            (itemWidth - _highlightWidth) / 2,
                        bottom: 0,
                        width: _highlightWidth,
                        height: _bandHeight,
                        child: QvInsetBackground(
                          type: QvInsetBackgroundType.secondary,
                          width: _highlightWidth,
                          height: _bandHeight,
                          padding: EdgeInsets.zero,
                          child: const SizedBox.shrink(),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        height: _bandHeight,
                        child: Row(
                          children: List.generate(items.length, (i) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => onTap(i),
                                behavior: HitTestBehavior.translucent,
                                child: Center(
                                  child: Image.asset(
                                    'images/ui/icons/${items[i].iconName}-icon.png',
                                    filterQuality: FilterQuality.none,
                                    width: 28,
                                    height: 28,
                                    fit: BoxFit.contain,
                                    // Icon PNGs are now plain white glyphs —
                                    // tint at runtime to primary/secondary
                                    // per role instead of relying on
                                    // baked-in color variants.
                                    color: items[i].selected
                                        ? colorScheme.primary
                                        : colorScheme.secondary,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
                  );
                },
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
