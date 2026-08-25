import 'package:flutter/material.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_text_styles.dart';

/// A single-column number wheel scroller, styled to match TimePickerView's
/// wheel columns (same QvInsetBackground highlight band, same
/// ListWheelScrollView config, same selected/unselected text treatment) —
/// fully controlled, no internal state, so the caller owns the selected
/// value entirely.
class QvNumberWheelPicker extends StatelessWidget {
  const QvNumberWheelPicker({
    super.key,
    required this.min,
    required this.max,
    required this.selectedValue,
    required this.onChanged,
    this.columnWidth = 80,
    this.itemExtent = 40,
    this.wheelHeight = 200,
    this.labelBuilder,
  });

  final int min;
  final int max;
  final int selectedValue;
  final ValueChanged<int> onChanged;
  final double columnWidth;
  final double itemExtent;
  final double wheelHeight;
  final String Function(int value)? labelBuilder;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final itemCount = max - min + 1;
    final selectedIndex = (selectedValue - min).clamp(0, itemCount - 1);

    return SizedBox(
      height: wheelHeight,
      child: Stack(
        children: [
          Center(
            child: QvInsetBackground(
              type: QvInsetBackgroundType.secondary,
              width: columnWidth,
              height: itemExtent,
              padding: EdgeInsets.zero,
              child: const SizedBox.shrink(),
            ),
          ),
          Center(
            child: SizedBox(
              width: columnWidth,
              child: ListWheelScrollView.useDelegate(
                itemExtent: itemExtent,
                perspective: 0.005,
                diameterRatio: 1.2,
                physics: const FixedExtentScrollPhysics(),
                onSelectedItemChanged: (index) => onChanged(min + index),
                controller:
                    FixedExtentScrollController(initialItem: selectedIndex),
                childDelegate: ListWheelChildBuilderDelegate(
                  childCount: itemCount,
                  builder: (context, index) {
                    final value = min + index;
                    final isSelected = index == selectedIndex;
                    return Center(
                      child: Text(
                        labelBuilder != null
                            ? labelBuilder!(value)
                            : '$value',
                        style: (isSelected ? QvTextStyles.emphasis : QvTextStyles.subtitle)
                            .copyWith(
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withValues(alpha: 0.35),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
