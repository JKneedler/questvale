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
import 'package:questvale/widgets/qv_background.dart';
import 'package:questvale/widgets/qv_check_box.dart';
import 'package:questvale/widgets/qv_segmented_control.dart';
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
        // DraggableScrollableSheet (rather than a fixed-height scroll view)
        // so that dragging down from the top of the content shrinks the
        // sheet and hands off to the modal's own dismiss animation via
        // shouldCloseOnMinExtent, instead of the drag being swallowed by the
        // scroll view and going nowhere.
        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          maxChildSize: 0.92,
          minChildSize: 0.1,
          expand: false,
          snap: true,
          builder: (context, scrollController) {
            return QvBackground(
              width: double.infinity,
              height: double.infinity,
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const _CalmSnapScrollPhysics(),
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
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      // Todo title
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => context
                                .read<EditTodoCubit>()
                                .toggleCompletion(),
                            child: QvCheckBox(
                              width: 20,
                              height: 20,
                              isChecked: state.isCompleted,
                            ),
                          ),
                          SizedBox(
                            width: 300,
                            child: QvTextField(
                              controller:
                                  TextEditingController(text: state.name),
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
                                onPressed: () =>
                                    CreateCharacterTagPage.showModal(
                                  context,
                                  state.todo.characterId,
                                  () =>
                                      context.read<EditTodoCubit>().loadTags(),
                                ),
                                margin:
                                    const EdgeInsets.only(left: 2, right: 50),
                              );
                            }
                            final tag = state.availableTags[index];
                            return TagChip(
                              icon: CharacterTag.availableIcons[tag.iconIndex],
                              name: tag.name,
                              color:
                                  CharacterTag.availableColors[tag.colorIndex],
                              isSelected: state.selectedTags.any((t) =>
                                  t.characterTagId == tag.characterTagId),
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
            );
          },
        );
      },
    );
  }

  Widget _buildDifficultyRow(BuildContext context, EditTodoState state) {
    return _buildSelectableSection(
      context,
      label: 'Difficulty',
      child: QvSegmentedControl<DifficultyLevel>(
        items: [
          for (final level in DifficultyLevel.values)
            QvSegmentedControlItem(
              value: level,
              label: _getDifficultyText(level),
              icon: DIFFICULTY_ICON,
              color: level.color,
            ),
        ],
        selectedValue: state.difficulty,
        onChanged: (level) =>
            context.read<EditTodoCubit>().difficultyChanged(level),
      ),
    );
  }

  Widget _buildPriorityRow(BuildContext context, EditTodoState state) {
    return _buildSelectableSection(
      context,
      label: 'Priority',
      child: QvSegmentedControl<PriorityLevel>(
        items: [
          for (final level in PriorityLevel.values)
            QvSegmentedControlItem(
              value: level,
              label: _getPriorityText(level),
              icon: PRIORITY_ICON,
              color: level.color,
            ),
        ],
        selectedValue: state.priority,
        onChanged: (level) =>
            context.read<EditTodoCubit>().priorityChanged(level),
      ),
    );
  }

  Widget _buildHabitRow(BuildContext context, EditTodoState state) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return _buildSelectableSection(
      context,
      label: 'Repeats',
      trailing: state.isHabit
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Symbols.local_fire_department,
                  color: colorScheme.primary,
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  '${state.todo.currentStreak}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            )
          : null,
      child: QvSegmentedControl<HabitTimeframe?>(
        items: [
          const QvSegmentedControlItem(
            value: null,
            label: 'One-time',
            icon: Symbols.check_circle,
          ),
          for (final tf in HabitTimeframe.values)
            QvSegmentedControlItem(
              value: tf,
              label: tf.name,
              icon: Symbols.event_repeat,
            ),
        ],
        selectedValue:
            state.isHabit ? (state.timeframe ?? HabitTimeframe.daily) : null,
        onChanged: (tf) {
          if (tf == null) {
            context.read<EditTodoCubit>().habitToggled(false);
          } else {
            context.read<EditTodoCubit>().timeframeChanged(tf);
          }
        },
      ),
    );
  }

  Widget _buildSelectableSection(
    BuildContext context, {
    required String label,
    required Widget child,
    Widget? trailing,
  }) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (trailing != null) ...[
                const Spacer(),
                trailing,
              ],
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildMultipleCompletionsRow(
      BuildContext context, EditTodoState state) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => context
            .read<EditTodoCubit>()
            .multipleCompletionsToggled(!state.allowsMultipleCompletions),
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            QvCheckBox(
              width: 20,
              height: 20,
              isChecked: state.allowsMultipleCompletions,
            ),
            const SizedBox(width: 12),
            Text(
              'Multiple completions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
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
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
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

/// DraggableScrollableSheet's snap-on-release only picks the *nearest* snap
/// size (min or max) when the release velocity is within tolerance;
/// otherwise it jumps to the next size in the fling's direction, however far
/// that is. The default tolerance is only a few px/s, so almost any
/// perceptible release velocity counts as a fling and can send a small drag
/// near the top of the content all the way down to the dismiss size.
/// Widening the velocity tolerance means only a deliberate fast flick
/// triggers that directional jump; slower releases settle on whichever size
/// (open or dismiss) is actually closer.
class _CalmSnapScrollPhysics extends ScrollPhysics {
  const _CalmSnapScrollPhysics({super.parent});

  @override
  _CalmSnapScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _CalmSnapScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  Tolerance toleranceFor(ScrollMetrics metrics) {
    final defaultTolerance = super.toleranceFor(metrics);
    return Tolerance(
      velocity: 1000,
      distance: defaultTolerance.distance,
      time: defaultTolerance.time,
    );
  }
}
