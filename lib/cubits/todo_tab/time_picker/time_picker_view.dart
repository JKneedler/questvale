import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_cubit.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_state.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

/// Hour/minute/AM-PM wheel scroller for picking a time, styled to match the
/// rest of the app's pixel-bordered look instead of a plain Material sheet —
/// a QvInsetBackground stands in for the highlighted center band (the same
/// role QvSegmentedControl's sliding highlight plays), with hairline column
/// dividers instead of a boxed card.
class TimePickerView extends StatelessWidget {
  const TimePickerView({super.key});

  static const double _columnWidth = 80;
  static const double _itemExtent = 40;
  static const double _wheelHeight = 200;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final dividerColor =
        Color.lerp(colorScheme.onPrimaryFixedVariant, Colors.transparent, 0.5);

    return BlocBuilder<TimePickerCubit, TimePickerState>(
      builder: (context, state) {
        return SizedBox(
          height: _wheelHeight,
          child: Stack(
            children: [
              Center(
                child: QvInsetBackground(
                  type: QvInsetBackgroundType.secondary,
                  width: _columnWidth * 3,
                  height: _itemExtent,
                  padding: EdgeInsets.zero,
                  child: const SizedBox.shrink(),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _WheelColumn(
                    itemCount: 12,
                    selectedIndex: state.selectedHour - 1,
                    labelBuilder: (index) =>
                        (index + 1).toString().padLeft(2, '0'),
                    onSelectedItemChanged: (index) =>
                        context.read<TimePickerCubit>().hourChanged(index + 1),
                  ),
                  _ColumnDivider(color: dividerColor),
                  _WheelColumn(
                    itemCount: 60,
                    selectedIndex: state.selectedMinute,
                    labelBuilder: (index) => index.toString().padLeft(2, '0'),
                    onSelectedItemChanged: (index) =>
                        context.read<TimePickerCubit>().minuteChanged(index),
                  ),
                  _ColumnDivider(color: dividerColor),
                  _WheelColumn(
                    itemCount: 2,
                    selectedIndex: state.isAM ? 0 : 1,
                    labelBuilder: (index) => index == 0 ? 'AM' : 'PM',
                    onSelectedItemChanged: (index) => context
                        .read<TimePickerCubit>()
                        .periodChanged(index == 0),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnDivider extends StatelessWidget {
  const _ColumnDivider({required this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1.5,
      height: TimePickerView._itemExtent * 2,
      color: color,
    );
  }
}

class _WheelColumn extends StatelessWidget {
  const _WheelColumn({
    required this.itemCount,
    required this.selectedIndex,
    required this.labelBuilder,
    required this.onSelectedItemChanged,
  });

  final int itemCount;
  final int selectedIndex;
  final String Function(int index) labelBuilder;
  final ValueChanged<int> onSelectedItemChanged;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: TimePickerView._columnWidth,
      child: ListWheelScrollView.useDelegate(
        itemExtent: TimePickerView._itemExtent,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: onSelectedItemChanged,
        controller: FixedExtentScrollController(initialItem: selectedIndex),
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected = index == selectedIndex;
            return Center(
              child: Text(
                labelBuilder(index),
                style:
                    (isSelected ? QvTextStyles.emphasis : QvTextStyles.subtitle)
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
    );
  }
}
