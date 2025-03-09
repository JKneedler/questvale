import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/add_task/add_task_cubit.dart';
import 'package:questvale/cubits/add_task/add_task_state.dart';
import 'package:questvale/cubits/add_task/difficulty_selector_view.dart';
import 'package:questvale/cubits/due_date/due_date_page.dart';
import 'package:questvale/data/models/task.dart';

class AddTaskView extends StatelessWidget {
  final void Function() onTaskAdded;

  const AddTaskView({
    super.key,
    required this.onTaskAdded,
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
        child: BlocBuilder<AddTaskCubit, AddTaskState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NameField(onTaskAdded: onTaskAdded, id: state.id),
                  DescriptionField(onTaskAdded: onTaskAdded, id: state.id),
                  TagFields(),
                  EtcFields(onTaskAdded: onTaskAdded, state: state),
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
  final Function() onTaskAdded;
  final String id;

  const NameField({super.key, required this.onTaskAdded, required this.id});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 36,
      child: TextField(
        key: Key('addTaskView_name_${id}_textField'),
        decoration: InputDecoration(
          hintText: 'Task Name',
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
        onChanged: (value) => context.read<AddTaskCubit>().updateName(value),
        onSubmitted: (value) async {
          if (value.isNotEmpty) {
            await context.read<AddTaskCubit>().addTask();
            onTaskAdded();
          }
        },
      ),
    );
  }
}

class DescriptionField extends StatelessWidget {
  final void Function() onTaskAdded;
  final String id;

  const DescriptionField({
    super.key,
    required this.onTaskAdded,
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
        key: Key('addTaskView_description_${id}_textField'),
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
            context.read<AddTaskCubit>().updateDescription(value),
      ),
    );
  }
}

class TagFields extends StatelessWidget {
  const TagFields({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 6),
      child: Row(
        spacing: 6,
        children: [
          for (var tag in context.read<AddTaskCubit>().state.tags)
            TagToggle(tag: tag),
        ],
      ),
    );
  }
}

class TagToggle extends StatelessWidget {
  final TaskTags tag;
  const TagToggle({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => context.read<AddTaskCubit>().toggleTag(tag),
      child: Chip(
        label: Text(tag.name,
            style: TextStyle(
              fontSize: 12,
              color: tag.isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryFixedVariant,
            )),
        labelPadding: EdgeInsets.symmetric(horizontal: 8, vertical: -2),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: EdgeInsets.zero,
        backgroundColor: tag.isSelected
            ? colorScheme.primary
            : colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: tag.isSelected
                ? colorScheme.primary
                : colorScheme.onPrimaryFixedVariant,
          ),
        ),
      ),
    );
  }
}

class EtcFields extends StatelessWidget {
  final Function() onTaskAdded;
  final AddTaskState state;
  const EtcFields({super.key, required this.onTaskAdded, required this.state});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Row(
      spacing: 18,
      children: [
        GestureDetector(
          onTap: () async {
            await DueDatePage.showModal(
              context,
              onDateSelected: (date) =>
                  context.read<AddTaskCubit>().updateDueDate(date),
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
        Icon(
          Symbols.flag_2,
          color: colorScheme.onPrimaryFixedVariant,
          weight: 600,
        ),
        GestureDetector(
          onTap: () async {
            await DifficultyPage.showModal(
              context,
              onDifficultySelected: (difficulty) =>
                  context.read<AddTaskCubit>().updateDifficulty(difficulty),
            );
          },
          child: Icon(
            Symbols.trophy,
            color: state.difficulty != DifficultyLevel.trivial
                ? state.difficulty.color
                : colorScheme.onPrimaryFixedVariant,
            weight: 600,
          ),
        ),
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
                await context.read<AddTaskCubit>().addTask();
                onTaskAdded();
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
