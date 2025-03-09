import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/due_date/due_date_cubit.dart';
import 'package:questvale/cubits/due_date/due_date_view.dart';

class DueDatePage {
  static Future<void> showModal(
    BuildContext context, {
    required void Function(String) onDateSelected,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) => BlocProvider(
        create: (context) => DueDateCubit(onDateSelected: onDateSelected),
        child: const DueDateView(),
      ),
    );
  }
}
