import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/due_date/due_date_state.dart';

class DueDateCubit extends Cubit<DueDateState> {
  final void Function(String) onDateSelected;

  DueDateCubit({required this.onDateSelected}) : super(DueDateState());

  void updateSelectedDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  void updateSelectedTime(DateTime time) {
    emit(state.copyWith(selectedTime: time));
  }

  void clearSelectedTime() {
    emit(state.copyWith(selectedTime: null));
  }

  void saveDueDate() {
    if (state.selectedDate != null) {
      final date = state.selectedDate!;
      final time = state.selectedTime;

      final dueDate = time != null
          ? DateTime(
              date.year,
              date.month,
              date.day,
              time.hour,
              time.minute,
            )
          : date;

      onDateSelected(dueDate.toIso8601String());
      emit(state.copyWith(status: DueDateStatus.done));
    }
  }
}
