import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TimePickerStatus { initial, selected }

class TimePickerState extends Equatable {
  final TimePickerStatus status;
  final int selectedHour;
  final int selectedMinute;
  final bool isAM;

  const TimePickerState({
    this.status = TimePickerStatus.initial,
    this.selectedHour = 1,
    this.selectedMinute = 0,
    this.isAM = true,
  });

  TimePickerState copyWith({
    TimePickerStatus? status,
    int? selectedHour,
    int? selectedMinute,
    bool? isAM,
  }) {
    return TimePickerState(
      status: status ?? this.status,
      selectedHour: selectedHour ?? this.selectedHour,
      selectedMinute: selectedMinute ?? this.selectedMinute,
      isAM: isAM ?? this.isAM,
    );
  }

  TimeOfDay get selectedTime {
    final hour = isAM ? selectedHour : selectedHour + 12;
    return TimeOfDay(hour: hour, minute: selectedMinute);
  }

  @override
  List<Object?> get props => [status, selectedHour, selectedMinute, isAM];
}
