import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_view.dart'
    show TagChip;
import 'package:questvale/cubits/todo_tab/character_tag/create_character_tag_page.dart';
import 'package:questvale/cubits/todo_tab/due_date/due_date_page.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_cubit.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_state.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_check_box.dart';
import 'package:questvale/widgets/qv_popup_menu.dart';
import 'package:questvale/widgets/qv_popup_menu_item.dart';
import 'package:questvale/widgets/qv_textfield.dart';

class EditTodoView extends StatelessWidget {
  final Todo todo;

  const EditTodoView({
    super.key,
    required this.todo,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<EditTodoCubit, EditTodoState>(
      builder: (context, state) {
        return Wrap(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.93,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(
                            Symbols.keyboard_arrow_down,
                            weight: 500,
                            size: 32,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            context.read<EditTodoCubit>().submit();
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Symbols.check,
                            weight: 500,
                            size: 32,
                            color: colorScheme.onPrimaryFixedVariant,
                          ),
                        ),
                      ],
                    ),
                    // Todo title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () =>
                              context.read<EditTodoCubit>().toggleCompletion(),
                          child: QvCheckBox(
                            width: 20,
                            height: 20,
                            isChecked: state.isCompleted,
                          ),
                        ),
                        SizedBox(
                          width: 300,
                          child: QvTextField(
                            controller: TextEditingController(text: state.name),
                            onChanged: (value) => context
                                .read<EditTodoCubit>()
                                .nameChanged(value),
                            textInputAction: TextInputAction.done,
                            maxLines: 1,
                            textSize: 24,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Description section
                    SizedBox(
                      height: 100,
                      child: QvTextField(
                        controller:
                            TextEditingController(text: state.description),
                        onChanged: (value) => context
                            .read<EditTodoCubit>()
                            .descriptionChanged(value),
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                      ),
                    ),

                    // Tags section
                    _buildSectionTitle(context, 'Tags'),
                    const SizedBox(height: 8),
                    SizedBox(
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
                                state.todo.characterId,
                                () => context.read<EditTodoCubit>().loadTags(),
                              ),
                              margin: const EdgeInsets.only(left: 2, right: 50),
                            );
                          }
                          final tag = state.availableTags[index];
                          return TagChip(
                            icon: CharacterTag.availableIcons[tag.iconIndex],
                            name: tag.name,
                            color: CharacterTag.availableColors[tag.colorIndex],
                            isSelected: state.selectedTags.any(
                                (t) => t.characterTagId == tag.characterTagId),
                            onPressed: () =>
                                context.read<EditTodoCubit>().toggleTag(tag),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Details section
                    _buildSectionTitle(context, 'Details'),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => DueDatePage.showModal(
                        context,
                        initialDate: state.dueDate,
                        initialHasTime: state.hasTime,
                        initialReminders: state.reminders,
                        onDateSelected: (date, hasTime, reminders) => context
                            .read<EditTodoCubit>()
                            .dueDateAndRemindersChanged(
                                date, hasTime, reminders),
                      ),
                      child: _buildDetailItem(
                        context,
                        CALENDAR_ICON,
                        'Due Date',
                        state.dueDate != null
                            ? DataFormatters.formatDateTime(
                                state.dueDate!, state.hasTime)
                            : 'None',
                        isPastDue: state.dueDate != null &&
                            !state.todo.isCompleted &&
                            state.dueDate!.isBefore(DateTime.now()),
                      ),
                    ),
                    _buildDifficultyRow(context, state),
                    _buildPriorityRow(context, state),
                    _buildHabitRow(context, state),
                    if (state.isHabit)
                      _buildMultipleCompletionsRow(context, state),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDifficultyRow(BuildContext context, EditTodoState state) {
    final menuController = MenuController();
    return QVPopupMenu(
      menuController: menuController,
      offset: const Offset(0, -205),
      button: _buildDetailItem(
        context,
        DIFFICULTY_ICON,
        'Difficulty',
        _getDifficultyText(state.difficulty),
        iconColor: state.difficulty.color,
      ),
      menuContents: [
        for (int i = DifficultyLevel.values.length - 1; i >= 0; i--)
          QvPopupMenuItem(
            text: DifficultyLevel.values[i].name,
            icon: DIFFICULTY_ICON,
            iconColor: DifficultyLevel.values[i].color,
            onPressed: () {
              menuController.close();
              context
                  .read<EditTodoCubit>()
                  .difficultyChanged(DifficultyLevel.values[i]);
            },
          ),
      ],
    );
  }

  Widget _buildPriorityRow(BuildContext context, EditTodoState state) {
    final menuController = MenuController();
    return QVPopupMenu(
      menuController: menuController,
      offset: const Offset(0, -205),
      button: _buildDetailItem(
        context,
        PRIORITY_ICON,
        'Priority',
        _getPriorityText(state.priority),
        iconColor: state.priority.color,
      ),
      menuContents: [
        for (int i = PriorityLevel.values.length - 1; i >= 0; i--)
          QvPopupMenuItem(
            text: PriorityLevel.values[i].name,
            icon: PRIORITY_ICON,
            iconColor: PriorityLevel.values[i].color,
            onPressed: () {
              menuController.close();
              context
                  .read<EditTodoCubit>()
                  .priorityChanged(PriorityLevel.values[i]);
            },
          ),
      ],
    );
  }

  Widget _buildHabitRow(BuildContext context, EditTodoState state) {
    final menuController = MenuController();
    return QVPopupMenu(
      menuController: menuController,
      offset: const Offset(0, -260),
      button: _buildDetailItem(
        context,
        Symbols.event_repeat,
        'Repeats',
        state.isHabit
            ? '${(state.timeframe ?? HabitTimeframe.daily).name} '
                '(streak ${state.todo.currentStreak})'
            : 'One-time Task',
      ),
      menuContents: [
        QvPopupMenuItem(
          text: 'One-time Task',
          icon: Symbols.check_circle,
          iconColor:
              !state.isHabit ? Theme.of(context).colorScheme.primary : null,
          onPressed: () {
            menuController.close();
            context.read<EditTodoCubit>().habitToggled(false);
          },
        ),
        for (final tf in HabitTimeframe.values)
          QvPopupMenuItem(
            text: tf.name,
            icon: Symbols.event_repeat,
            iconColor: state.isHabit && state.timeframe == tf
                ? Theme.of(context).colorScheme.primary
                : null,
            onPressed: () {
              menuController.close();
              context.read<EditTodoCubit>().timeframeChanged(tf);
            },
          ),
      ],
    );
  }

  Widget _buildMultipleCompletionsRow(
      BuildContext context, EditTodoState state) {
    return GestureDetector(
      onTap: () => context
          .read<EditTodoCubit>()
          .multipleCompletionsToggled(!state.allowsMultipleCompletions),
      child: _buildDetailItem(
        context,
        Symbols.plus_one,
        'Multiple completions',
        state.allowsMultipleCompletions ? 'On' : 'Off',
        iconColor: state.allowsMultipleCompletions
            ? Theme.of(context).colorScheme.primary
            : null,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    );
  }

  Widget _buildDetailItem(
      BuildContext context, IconData icon, String label, String value,
      {Color? iconColor, bool isPastDue = false}) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: iconColor ?? colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isPastDue ? colorScheme.error : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDifficultyText(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.trivial:
        return 'Trivial';
      case DifficultyLevel.easy:
        return 'Easy';
      case DifficultyLevel.medium:
        return 'Medium';
      case DifficultyLevel.hard:
        return 'Hard';
      default:
        return 'Unknown';
    }
  }

  String _getPriorityText(PriorityLevel priority) {
    switch (priority) {
      case PriorityLevel.noPriority:
        return 'None';
      case PriorityLevel.low:
        return 'Low';
      case PriorityLevel.medium:
        return 'Medium';
      case PriorityLevel.high:
        return 'High';
      default:
        return 'Unknown';
    }
  }
}
