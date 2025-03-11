import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_todo/add_todo_state.dart';
import 'package:questvale/cubits/due_date/due_date_state.dart';

class DueDateCubit extends Cubit<DueDateState> {
  final void Function(DateTime?, bool, List<ReminderType>) onDateSelected;
  final DateTime? initialDueDate;
  final bool initialHasTime;
  final List<ReminderType> initialReminders;

  DueDateCubit({
    required this.onDateSelected,
    this.initialDueDate,
    this.initialHasTime = false,
    this.initialReminders = const [],
  }) : super(DueDateState(
          selectedDate: initialDueDate,
          hasTime: initialHasTime,
          reminders: initialReminders,
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
      reminders: state.hasTime ? state.reminders : [],
    ));
  }

  void clearSelectedTime() {
    emit(state.copyWith(hasTime: false, reminders: const []));
  }

  void saveDueDate() {
    onDateSelected(state.selectedDate, state.hasTime, state.reminders);
    emit(state.copyWith(status: DueDateStatus.done));
  }

  void clearDueDate() {
    emit(DueDateState(status: DueDateStatus.initial));
  }

  void toggleReminder(ReminderType reminder) {
    DateTime date = state.selectedDate ?? DateTime.now();
    emit(state.copyWith(
      selectedDate: date,
      reminders: state.reminders.contains(reminder)
          ? state.reminders.where((e) => e != reminder).toList()
          : [...state.reminders, reminder],
    ));
  }

  void clearReminders() {
    emit(state.copyWith(reminders: const []));
  }
}
