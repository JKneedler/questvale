import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/add_todo/add_todo_cubit.dart';
import 'package:questvale/cubits/add_todo/add_todo_state.dart';
import 'package:questvale/cubits/add_todo/difficulty_selector_view.dart';
import 'package:questvale/cubits/due_date/due_date_page.dart';
import 'package:questvale/data/models/todo.dart';

class AddTodoView extends StatelessWidget {
  final void Function() onTodoAdded;

  const AddTodoView({
    super.key,
    required this.onTodoAdded,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        color: colorScheme.surfaceContainerLow,
        child: BlocBuilder<AddTodoCubit, AddTodoState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NameField(onTodoAdded: onTodoAdded, id: state.id),
                  DescriptionField(onTodoAdded: onTodoAdded, id: state.id),
                  EtcFields(onTodoAdded: onTodoAdded, state: state),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NameField extends StatelessWidget {
  final Function() onTodoAdded;
  final String id;

  const NameField({super.key, required this.onTodoAdded, required this.id});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: TextField(
        key: Key('addTodoView_name_${id}_textField'),
        decoration: InputDecoration(
          hintText: 'Todo Name',
          hintStyle: TextStyle(color: colorScheme.onPrimaryFixedVariant),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: TextStyle(
          fontSize: 16,
          color: colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.w500,
        ),
        textInputAction: TextInputAction.done,
        onChanged: (value) => context.read<AddTodoCubit>().nameChanged(value),
        onSubmitted: (value) async {
          if (value.isNotEmpty) {
            await context.read<AddTodoCubit>().submit();
            onTodoAdded();
          }
        },
      ),
    );
  }
}

class DescriptionField extends StatelessWidget {
  final void Function() onTodoAdded;
  final String id;

  const DescriptionField({
    super.key,
    required this.onTodoAdded,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 45.0,
        maxHeight: 150.0,
      ),
      child: TextField(
        key: Key('addTodoView_description_${id}_textField'),
        decoration: InputDecoration(
          hintText: 'Description',
          hintStyle: TextStyle(color: colorScheme.onPrimaryFixedVariant),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          isDense: true,
        ),
        style: TextStyle(
          fontSize: 14,
          color: colorScheme.onPrimaryContainer,
        ),
        maxLines: null,
        minLines: 2,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        onChanged: (value) =>
            context.read<AddTodoCubit>().descriptionChanged(value),
      ),
    );
  }
}

class EtcFields extends StatelessWidget {
  final Function() onTodoAdded;
  final AddTodoState state;
  const EtcFields({super.key, required this.onTodoAdded, required this.state});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        GestureDetector(
          onTap: () async {
            await DueDatePage.showModal(
              context,
              onDateSelected: (date) =>
                  context.read<AddTodoCubit>().dueDateChanged(date),
            );
          },
          child: Icon(
            Symbols.calendar_clock,
            color: state.dueDate.isNotEmpty
                ? colorScheme.primary
                : colorScheme.onPrimaryFixedVariant,
            weight: 600,
          ),
        ),
        const SizedBox(width: 18),
        Icon(
          Symbols.flag_2,
          color: colorScheme.onPrimaryFixedVariant,
          weight: 600,
        ),
        const SizedBox(width: 18),
        GestureDetector(
          onTap: () async {
            await DifficultyPage.showModal(
              context,
              onDifficultySelected: (difficulty) =>
                  context.read<AddTodoCubit>().difficultyChanged(difficulty),
            );
          },
          child: Icon(
            Symbols.trophy,
            color: state.difficulty > 1
                ? colorScheme.primary
                : colorScheme.onPrimaryFixedVariant,
            weight: 600,
          ),
        ),
        const SizedBox(width: 18),
        Icon(
          Symbols.more_horiz,
          color: colorScheme.onPrimaryFixedVariant,
          weight: 600,
        ),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () async {
                await context.read<AddTodoCubit>().submit();
                onTodoAdded();
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_upward,
                  color: colorScheme.surfaceContainerLow,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
