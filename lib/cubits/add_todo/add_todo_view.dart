import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/add_todo/add_todo_cubit.dart';
import 'package:questvale/cubits/add_todo/add_todo_state.dart';
import 'package:questvale/cubits/character_tag/create_character_tag_page.dart';
import 'package:questvale/cubits/due_date/due_date_page.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_popup_menu.dart';
import 'package:questvale/widgets/qv_popup_menu_item.dart';

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
                  TagsField(state: state),
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

class TagsField extends StatelessWidget {
  final AddTodoState state;

  const TagsField({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: state.availableTags.length + 1,
        itemBuilder: (context, index) {
          if (index == state.availableTags.length) {
            return TagChip(
              icon: Icons.add,
              name: 'Tag',
              color: Colors.transparent,
              onPressed: () => CreateCharacterTagPage.showModal(
                context,
                state.characterId,
                () {
                  context.read<AddTodoCubit>().loadAvailableTags();
                },
              ),
              margin: const EdgeInsets.only(left: 2, right: 50),
            );
          }
          return TagChip(
            icon: CharacterTag
                .availableIcons[state.availableTags[index].iconIndex],
            name: state.availableTags[index].name,
            color: CharacterTag
                .availableColors[state.availableTags[index].colorIndex],
            isSelected: state.selectedTags.contains(state.availableTags[index]),
            onPressed: () {
              context
                  .read<AddTodoCubit>()
                  .toggleTag(state.availableTags[index]);
            },
          );
        },
      ),
    );
  }
}

class TagChip extends StatelessWidget {
  final IconData icon;
  final String name;
  final Color color;
  final bool isSelected;
  final void Function() onPressed;
  final EdgeInsets margin;

  const TagChip({
    super.key,
    required this.icon,
    required this.name,
    required this.color,
    required this.onPressed,
    this.isSelected = false,
    this.margin = const EdgeInsets.symmetric(horizontal: 2),
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: margin,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected ? color : colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(100),
          border: isSelected
              ? Border.all(
                  color: Colors.transparent,
                  width: 1.5,
                )
              : Border.all(
                  color: colorScheme.onPrimaryFixedVariant,
                  width: 1.5,
                ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 2,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onPrimaryFixedVariant,
              size: 16,
            ),
            Text(
              name,
              style: TextStyle(
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onPrimaryFixedVariant,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
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
              initialDate: state.dueDate,
              initialHasTime: state.hasTime,
              onDateSelected: (DateTime? date, bool hasTime) =>
                  context.read<AddTodoCubit>().dueDateChanged(date, hasTime),
            );
          },
          child: Row(
            children: [
              Icon(
                Symbols.calendar_clock,
                color: state.dueDate != null
                    ? colorScheme.primary
                    : colorScheme.onPrimaryFixedVariant,
                weight: 600,
              ),
              const SizedBox(width: 4),
              if (state.dueDate != null)
                Text(
                  DataFormatters.formatDateTime(state.dueDate!, state.hasTime),
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        PriorityMenu(priority: state.priority),
        const SizedBox(width: 12),
        DifficultyMenu(difficulty: state.difficulty),
        const SizedBox(width: 12),
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

class PriorityMenu extends StatelessWidget {
  final PriorityLevel priority;

  final MenuController menuController = MenuController();

  PriorityMenu({super.key, required this.priority});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return QVPopupMenu(
      menuController: menuController,
      offset: const Offset(0, -205),
      button: Icon(
        Symbols.flag_2,
        color: priority != PriorityLevel.noPriority
            ? priority.color
            : colorScheme.onPrimaryFixedVariant,
        weight: 600,
      ),
      menuContents: [
        for (int i = PriorityLevel.values.length - 1; i >= 0; i--)
          QvPopupMenuItem(
            text: PriorityLevel.values[i].name,
            icon: Symbols.flag_2,
            iconColor: PriorityLevel.values[i].color,
            onPressed: () {
              menuController.close();
              context
                  .read<AddTodoCubit>()
                  .priorityChanged(PriorityLevel.values[i]);
            },
          ),
      ],
    );
  }
}

class DifficultyMenu extends StatelessWidget {
  final DifficultyLevel difficulty;

  final MenuController menuController = MenuController();

  DifficultyMenu({super.key, required this.difficulty});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return QVPopupMenu(
      menuController: menuController,
      offset: const Offset(0, -205),
      button: Icon(
        Symbols.trophy,
        color: difficulty != DifficultyLevel.trivial
            ? difficulty.color
            : colorScheme.onPrimaryFixedVariant,
        weight: 600,
      ),
      menuContents: [
        for (int i = DifficultyLevel.values.length - 1; i >= 0; i--)
          QvPopupMenuItem(
            text: DifficultyLevel.values[i].name,
            icon: Symbols.trophy,
            iconColor: DifficultyLevel.values[i].color,
            onPressed: () {
              menuController.close();
              context
                  .read<AddTodoCubit>()
                  .difficultyChanged(DifficultyLevel.values[i]);
            },
          ),
      ],
    );
  }
}
