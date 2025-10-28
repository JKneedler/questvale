import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_cubit.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_state.dart';

class TimePickerView extends StatelessWidget {
  const TimePickerView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: IntrinsicWidth(
        child: BlocBuilder<TimePickerCubit, TimePickerState>(
          builder: (context, state) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      Center(
                        child: Container(
                          height: 50,
                          width: 220,
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Hours
                          SizedBox(
                            width: 80,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) => context
                                  .read<TimePickerCubit>()
                                  .hourChanged(index + 1),
                              controller: FixedExtentScrollController(
                                initialItem: state.selectedHour - 1,
                              ),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 12,
                                builder: (context, index) {
                                  final hour =
                                      (index + 1).toString().padLeft(2, '0');
                                  final isSelected =
                                      index + 1 == state.selectedHour;
                                  return Center(
                                    child: Text(
                                      hour,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onPrimaryFixedVariant,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // Minutes
                          SizedBox(
                            width: 80,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) => context
                                  .read<TimePickerCubit>()
                                  .minuteChanged(index),
                              controller: FixedExtentScrollController(
                                initialItem: state.selectedMinute,
                              ),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 60,
                                builder: (context, index) {
                                  final minute =
                                      index.toString().padLeft(2, '0');
                                  final isSelected =
                                      index == state.selectedMinute;
                                  return Center(
                                    child: Text(
                                      minute,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onPrimaryFixedVariant,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          // AM/PM
                          SizedBox(
                            width: 80,
                            child: ListWheelScrollView.useDelegate(
                              itemExtent: 40,
                              perspective: 0.005,
                              diameterRatio: 1.2,
                              physics: const FixedExtentScrollPhysics(),
                              onSelectedItemChanged: (index) => context
                                  .read<TimePickerCubit>()
                                  .periodChanged(index == 0),
                              controller: FixedExtentScrollController(
                                initialItem: state.isAM ? 0 : 1,
                              ),
                              childDelegate: ListWheelChildBuilderDelegate(
                                childCount: 2,
                                builder: (context, index) {
                                  final isSelected = (index == 0) == state.isAM;
                                  return Center(
                                    child: Text(
                                      index == 0 ? 'AM' : 'PM',
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: isSelected
                                            ? colorScheme.onPrimary
                                            : colorScheme.onPrimaryFixedVariant,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
