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
          // TimeOfDay.hourOfPeriod is 0-11 (0 covers both 12AM and 12PM),
          // but this wheel shows a 1-12 clock face, so 0 needs mapping to 12.
          selectedHour: initialTime == null
              ? 1
              : (initialTime.hourOfPeriod == 0 ? 12 : initialTime.hourOfPeriod),
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
