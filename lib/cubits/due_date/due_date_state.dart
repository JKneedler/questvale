import 'package:equatable/equatable.dart';

enum DueDateStatus { initial, loading, done }

class DueDateState extends Equatable {
  final DueDateStatus status;
  final DateTime? selectedDate;
  final DateTime? selectedTime;

  const DueDateState({
    this.status = DueDateStatus.initial,
    this.selectedDate,
    this.selectedTime,
  });

  DueDateState copyWith({
    DueDateStatus? status,
    DateTime? selectedDate,
    DateTime? selectedTime,
  }) {
    return DueDateState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
    );
  }

  @override
  List<Object?> get props => [status, selectedDate, selectedTime];
}
