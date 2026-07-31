import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

class QvSegmentedControlItem<T> {
  const QvSegmentedControlItem({
    required this.value,
    required this.label,
    this.icon,
    this.color,
  });

  final T value;
  final String label;
  final IconData? icon;
  final Color? color;
}

/// A row of equal-width, tappable choices with a QvInsetBackground highlight
/// that slides between them — the same sliding-highlight pattern as the
/// bottom [NavBar], sized to its section instead of the full screen.
class QvSegmentedControl<T> extends StatelessWidget {
  const QvSegmentedControl({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<QvSegmentedControlItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onChanged;

  static const double _bandHeight = 76;
  static const double _boxSize = 76;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final selectedIndex =
        items.indexWhere((item) => item.value == selectedValue);

    return SizedBox(
      height: _bandHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / items.length;
          final boxOffset = (itemWidth - _boxSize) / 2;
          return Stack(
            children: [
              if (selectedIndex >= 0)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  left: itemWidth * selectedIndex + boxOffset,
                  top: 0,
                  width: _boxSize,
                  height: _boxSize,
                  child: QvInsetBackground(
                    type: QvInsetBackgroundType.secondary,
                    width: _boxSize,
                    height: _boxSize,
                    padding: EdgeInsets.zero,
                    child: const SizedBox.shrink(),
                  ),
                ),
              Row(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final isSelected = i == selectedIndex;
                  final segmentColor = isSelected
                      ? (item.color ?? colorScheme.primary)
                      : colorScheme.onSurface.withValues(alpha: 0.6);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => onChanged(item.value),
                      behavior: HitTestBehavior.translucent,
                      child: Center(
                        child: SizedBox(
                          width: _boxSize,
                          height: _boxSize,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.icon != null) ...[
                                  Icon(
                                    item.icon,
                                    size: 24,
                                    color: segmentColor,
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  item.label,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: segmentColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        },
      ),
    );
  }
}
