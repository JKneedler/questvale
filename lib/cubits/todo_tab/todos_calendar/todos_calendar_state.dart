import 'package:equatable/equatable.dart';

class TodosCalendarState extends Equatable {
  final DateTime selectedDate;
  final DateTime displayedMonth;

  TodosCalendarState({DateTime? selectedDate, DateTime? displayedMonth})
      : selectedDate = selectedDate ?? _today(),
        displayedMonth =
            displayedMonth ?? _firstOfMonth(selectedDate ?? _today());

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime _firstOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  TodosCalendarState copyWith({
    DateTime? selectedDate,
    DateTime? displayedMonth,
  }) {
    return TodosCalendarState(
      selectedDate: selectedDate ?? this.selectedDate,
      displayedMonth: displayedMonth ?? this.displayedMonth,
    );
  }

  @override
  List<Object> get props => [selectedDate, displayedMonth];
}
