import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:questvale/cubits/edit_task/edit_task_cubit.dart';
import 'package:questvale/cubits/edit_task/edit_task_state.dart';
import 'package:questvale/data/models/task.dart';
import 'package:questvale/data/repositories/tag_repository.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:sqflite/sqflite.dart';

class EditTaskView extends StatelessWidget {
  final String pageTitle;

  const EditTaskView({super.key, required this.pageTitle});

  static Route<void> route({required String pageTitle, Task? startTask}) {
    return PageRouteBuilder(
        pageBuilder: (context, anim, secondAnim) => BlocProvider(
              create: (context) => EditTaskCubit(
                TaskRepository(db: context.read<Database>()),
                TagRepository(db: context.read<Database>()),
                startTask,
              ),
              child: EditTaskView(pageTitle: pageTitle),
            ),
        transitionsBuilder: (context, anim, secondAnim, child) {
          return SlideTransition(
              position: anim.drive(
                  Tween(begin: Offset(0.0, 1.0), end: Offset.zero)
                      .chain(CurveTween(curve: Curves.ease))),
              child: child);
        });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final state = context.watch<EditTaskCubit>().state;

    return BlocListener<EditTaskCubit, EditTaskState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == EditTaskStatus.done,
      listener: (context, state) => Navigator.of(context).pop(),
      child: Scaffold(
          appBar: AppBar(
            title: Text(
              pageTitle,
              style: TextStyle(color: colorScheme.onPrimary),
            ),
            backgroundColor: colorScheme.primary,
            leading: IconButton(
              icon: Icon(
                Icons.close,
                color: colorScheme.onPrimary,
              ),
              onPressed: () => state.status != EditTaskStatus.loading
                  ? Navigator.of(context).pop()
                  : {},
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.check, color: colorScheme.onPrimary),
                onPressed: () => context.read<EditTaskCubit>().submit(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 100),
              child: Column(
                spacing: 40,
                children: [
                  NameField(
                      name: state.name,
                      onNameChange: context.read<EditTaskCubit>().updateName),
                  DescriptionField(
                    description: state.description,
                    onDescriptionChange:
                        context.read<EditTaskCubit>().updateDescription,
                  ),
                  DifficultyField(
                    difficulty: state.difficulty,
                    onDifficultyChange:
                        context.read<EditTaskCubit>().updateDifficulty,
                  ),
                  DueDateField(
                    dueDate: state.dueDate,
                    onDueDateChange:
                        context.read<EditTaskCubit>().updateDueDate,
                  ),
                  ChecklistSection(
                    checklist: state.checklist,
                    onAddChecklistItem:
                        context.read<EditTaskCubit>().addToChecklist,
                    onChecklistItemChange:
                        context.read<EditTaskCubit>().editChecklistItem,
                    onRemoveFromChecklist:
                        context.read<EditTaskCubit>().removeChecklistItem,
                  ),
                  TagsField(
                    tags: state.tags,
                    onTagChange: context.read<EditTaskCubit>().updateTag,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}

class NameField extends StatelessWidget {
  final String name;
  final Function(String value) onNameChange;

  const NameField({super.key, required this.name, required this.onNameChange});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('editTaskView_title_textFormField'),
      initialValue: name,
      autocorrect: false,
      decoration: InputDecoration(labelText: 'Name'),
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onNameChange(value),
    );
  }
}

class DescriptionField extends StatelessWidget {
  final String description;
  final Function(String value) onDescriptionChange;

  const DescriptionField(
      {super.key,
      required this.description,
      required this.onDescriptionChange});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: const Key('editTaskView_description_textFormField'),
      initialValue: description,
      autocorrect: false,
      keyboardType: TextInputType.multiline,
      maxLines: 4,
      decoration: InputDecoration(labelText: 'Description'),
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onDescriptionChange(value),
    );
  }
}

final iconList = [
  Icons.looks_one,
  Icons.looks_two,
  Icons.looks_3,
  Icons.looks_4,
];

class DifficultyField extends StatelessWidget {
  final DifficultyLevel difficulty;
  final Function(DifficultyLevel value) onDifficultyChange;

  const DifficultyField(
      {super.key, required this.difficulty, required this.onDifficultyChange});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final toggleBools = [
      for (DifficultyLevel diff in DifficultyLevel.values) diff == difficulty
    ];

    final toggleWidgets = [
      for (DifficultyLevel diff in DifficultyLevel.values)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 6,
          children: [
            Icon(iconList[diff.index]),
            Text(diff
                .toString()
                .replaceFirst('DifficultyLevel.', '')
                .toUpperCase())
          ],
        )
    ];

    return ToggleButtons(
        isSelected: toggleBools,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        constraints: const BoxConstraints(minWidth: 80, minHeight: 80),
        selectedColor: colorScheme.onPrimary,
        fillColor: colorScheme.primary,
        onPressed: (index) => onDifficultyChange(DifficultyLevel.values[index]),
        children: toggleWidgets);
  }
}

class DueDateField extends StatelessWidget {
  final String dueDate;
  final Function(String value) onDueDateChange;

  const DueDateField(
      {super.key, required this.dueDate, required this.onDueDateChange});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key(dueDate),
      initialValue: dueDate,
      decoration: InputDecoration(
          icon: Icon(Icons.calendar_today), labelText: 'Due Date'),
      readOnly: true,
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: dueDate != ''
                ? DateFormat('MM-dd-yyyy').parse(dueDate)
                : DateTime.now(), //get today's date
            firstDate: DateTime.now(),
            lastDate: DateTime(2101));
        FocusManager.instance.primaryFocus?.unfocus();
        if (pickedDate != null) {
          onDueDateChange(DateFormat('MM-dd-yyyy').format(pickedDate));
        }
      },
    );
  }
}

class ChecklistSection extends StatelessWidget {
  final List<ChecklistStateItem> checklist;
  final Function(String) onAddChecklistItem;
  final Function(int, String) onChecklistItemChange;
  final Function(int) onRemoveFromChecklist;

  const ChecklistSection({
    super.key,
    required this.checklist,
    required this.onAddChecklistItem,
    required this.onChecklistItemChange,
    required this.onRemoveFromChecklist,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final listView = checklist.isNotEmpty
        ? ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.only(bottom: 20),
            shrinkWrap: true,
            itemCount: checklist.length,
            itemBuilder: (context, index) {
              return ChecklistItemField(
                checklistStateItem: checklist[index],
                index: index,
                onChecklistItemChange: onChecklistItemChange,
                onRemoveFromChecklist: onRemoveFromChecklist,
              );
            },
          )
        : const SizedBox.shrink();

    return Container(
      //decoration: BoxDecoration(color: colorScheme.secondaryContainer),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          listView,
          GestureDetector(
            onTap: () {
              onAddChecklistItem('');
            },
            child: Container(
              decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              height: 50,
              child: Center(child: Text('Add Checklist Item')),
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistItemField extends StatelessWidget {
  final ChecklistStateItem checklistStateItem;
  final int index;
  final Function(int, String) onChecklistItemChange;
  final Function(int) onRemoveFromChecklist;

  const ChecklistItemField({
    super.key,
    required this.checklistStateItem,
    required this.index,
    required this.onChecklistItemChange,
    required this.onRemoveFromChecklist,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: Key(
          'editTaskView_checklistItem_${checklistStateItem.id}_textFormField'),
      initialValue: checklistStateItem.name,
      autocorrect: false,
      decoration: InputDecoration(
        icon: GestureDetector(
          child: Icon(Icons.do_not_disturb_on_outlined),
          onTap: () => onRemoveFromChecklist(index),
        ),
      ),
      onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
      onChanged: (value) => onChecklistItemChange(index, value),
    );
  }
}

class TagsField extends StatelessWidget {
  final List<TaskTags> tags;
  final Function(int) onTagChange;

  const TagsField({
    super.key,
    required this.tags,
    required this.onTagChange,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final toggleBools = [for (TaskTags taskTag in tags) taskTag.isSelected];

    final toggleWidgets = [
      for (int i = 0; i < tags.length; i++)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(tags[i].name),
          ],
        )
    ];

    return ToggleButtons(
      direction: Axis.vertical,
      isSelected: toggleBools,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      constraints: BoxConstraints(minWidth: 400, minHeight: 50),
      selectedColor: colorScheme.onPrimary,
      fillColor: colorScheme.primary,
      onPressed: (index) => onTagChange(index),
      children: toggleWidgets,
    );
  }
}
