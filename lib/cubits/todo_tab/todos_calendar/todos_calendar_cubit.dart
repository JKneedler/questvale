import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todo_tab/todos_calendar/todos_calendar_state.dart';

class TodosCalendarCubit extends Cubit<TodosCalendarState> {
  TodosCalendarCubit() : super(TodosCalendarState());

  void selectDate(DateTime date) {
    emit(state.copyWith(
      selectedDate: DateTime(date.year, date.month, date.day),
    ));
  }

  void changeMonth(int delta) {
    final newMonth = DateTime(
      state.displayedMonth.year,
      state.displayedMonth.month + delta,
      1,
    );
    emit(state.copyWith(displayedMonth: newMonth));
  }
}
