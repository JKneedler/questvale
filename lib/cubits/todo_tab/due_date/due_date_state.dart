import 'package:equatable/equatable.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_state.dart';

enum DueDateStatus { initial, loading, done }

class DueDateState extends Equatable {
  final DueDateStatus status;
  final DateTime? selectedDate;
  final bool hasTime;
  final List<ReminderType> reminders;

  const DueDateState({
    this.status = DueDateStatus.initial,
    this.selectedDate,
    this.hasTime = false,
    this.reminders = const [],
  });

  DueDateState copyWith({
    DueDateStatus? status,
    DateTime? selectedDate,
    bool? hasTime,
    List<ReminderType>? reminders,
  }) {
    return DueDateState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      hasTime: hasTime ?? this.hasTime,
      reminders: reminders ?? this.reminders,
    );
  }

  @override
  List<Object?> get props => [status, selectedDate, hasTime, reminders];
}
