import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/due_date/due_date_state.dart';

class DueDateCubit extends Cubit<DueDateState> {
  final void Function(DateTime?, bool) onDateSelected;
  final DateTime? initialDueDate;
  final bool initialHasTime;

  DueDateCubit({
    required this.onDateSelected,
    this.initialDueDate,
    this.initialHasTime = false,
  }) : super(DueDateState(
          selectedDate: initialDueDate,
          hasTime: initialHasTime,
        ));

  void updateSelectedDate(DateTime date) {
    DateTime selectedDate = state.hasTime
        ? state.selectedDate!.copyWith(
            year: date.year,
            month: date.month,
            day: date.day,
          )
        : date;
    emit(state.copyWith(selectedDate: selectedDate));
  }

  void updateSelectedTime(DateTime time) {
    DateTime selectedDate = state.selectedDate ?? DateTime.now();
    emit(state.copyWith(
      selectedDate: selectedDate.copyWith(
        hour: time.hour,
        minute: time.minute,
      ),
      hasTime: true,
    ));
  }

  void clearSelectedTime() {
    emit(state.copyWith(hasTime: false));
  }

  void saveDueDate() {
    onDateSelected(state.selectedDate, state.hasTime);
    emit(state.copyWith(status: DueDateStatus.done));
  }

  void clearDueDate() {
    emit(DueDateState(status: DueDateStatus.initial));
  }
}
