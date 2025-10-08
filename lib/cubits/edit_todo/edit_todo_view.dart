import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/edit_todo/edit_todo_cubit.dart';
import 'package:questvale/cubits/edit_todo/edit_todo_state.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_check_box.dart';
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
                    if (state.selectedTags.isNotEmpty) ...[
                      _buildSectionTitle(context, 'Tags'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: state.selectedTags
                            .map((tag) => _buildTagChip(context, tag))
                            .toList(),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Details section
                    _buildSectionTitle(context, 'Details'),
                    const SizedBox(height: 8),
                    _buildDetailItem(
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
                    _buildDetailItem(
                      context,
                      DIFFICULTY_ICON,
                      'Difficulty',
                      _getDifficultyText(state.difficulty),
                      iconColor: state.difficulty.color,
                    ),
                    _buildDetailItem(
                      context,
                      PRIORITY_ICON,
                      'Priority',
                      _getPriorityText(state.priority),
                      iconColor: state.priority.color,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusCard(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: todo.isCompleted
                  ? colorScheme.primaryContainer
                  : colorScheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              todo.isCompleted ? Symbols.check : Symbols.hourglass,
              color: todo.isCompleted
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  todo.isCompleted ? 'Completed' : 'In Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  todo.isCompleted
                      ? 'This task has been completed'
                      : 'This task is still in progress',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTagChip(BuildContext context, Tag tag) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.lerp(colorScheme.surfaceContainer,
            CharacterTag.availableColors[tag.colorIndex], 0.6),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CharacterTag.availableIcons[tag.iconIndex],
            color: colorScheme.onPrimary,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            tag.name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: colorScheme.onPrimary,
            ),
          ),
        ],
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
