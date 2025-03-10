import 'package:equatable/equatable.dart';

enum DueDateStatus { initial, loading, done }

class DueDateState extends Equatable {
  final DueDateStatus status;
  final DateTime? selectedDate;
  final bool hasTime;

  const DueDateState({
    this.status = DueDateStatus.initial,
    this.selectedDate,
    this.hasTime = false,
  });

  DueDateState copyWith({
    DueDateStatus? status,
    DateTime? selectedDate,
    bool? hasTime,
  }) {
    return DueDateState(
      status: status ?? this.status,
      selectedDate: selectedDate ?? this.selectedDate,
      hasTime: hasTime ?? this.hasTime,
    );
  }

  @override
  List<Object?> get props => [status, selectedDate, hasTime];
}
