import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_todo/add_todo_state.dart';
import 'package:questvale/cubits/due_date/due_date_cubit.dart';
import 'package:questvale/cubits/due_date/due_date_view.dart';

class DueDatePage {
  static Future<void> showModal(
    BuildContext context, {
    required void Function(DateTime?, bool, List<ReminderType>) onDateSelected,
    DateTime? initialDate,
    bool initialHasTime = false,
    List<ReminderType> initialReminders = const [],
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => BlocProvider(
        create: (context) => DueDateCubit(
          onDateSelected: onDateSelected,
          initialDueDate: initialDate,
          initialHasTime: initialHasTime,
          initialReminders: initialReminders,
        ),
        child: const DueDateView(),
      ),
    );
  }
}
