import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_state.dart';

class TimePickerCubit extends Cubit<TimePickerState> {
  final TimeOfDay? initialTime;
  final Function(TimeOfDay) onTimeSelected;

  TimePickerCubit({
    required this.initialTime,
    required this.onTimeSelected,
  }) : super(TimePickerState(
          selectedHour: initialTime?.hourOfPeriod ?? 1,
          selectedMinute: initialTime?.minute ?? 0,
          isAM: initialTime?.period == DayPeriod.am,
        )) {
    submit();
  }

  void hourChanged(int hour) {
    emit(state.copyWith(
      selectedHour: hour,
      status: TimePickerStatus.selected,
    ));
    submit();
  }

  void minuteChanged(int minute) {
    emit(state.copyWith(
      selectedMinute: minute,
      status: TimePickerStatus.selected,
    ));
    submit();
  }

  void periodChanged(bool isAM) {
    emit(state.copyWith(
      isAM: isAM,
      status: TimePickerStatus.selected,
    ));
    submit();
  }

  void submit() {
    onTimeSelected(state.selectedTime);
  }
}
