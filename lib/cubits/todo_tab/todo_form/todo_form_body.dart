import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/character_tag/create_character_tag_page.dart';
import 'package:questvale/cubits/todo_tab/due_date/due_date_editor.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_check_box.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_segmented_control.dart';
import 'package:questvale/widgets/qv_tag_chip.dart';
import 'package:questvale/widgets/qv_textfield.dart';

/// The mutable todo fields the shared form body renders — everything below
/// the title/description text fields. Both AddTodoState and EditTodoState
/// map onto this so the same body widget can drive either cubit.
class TodoFormFields {
  const TodoFormFields({
    required this.name,
    required this.description,
    required this.dueDate,
    required this.hasTime,
    required this.reminders,
    required this.difficulty,
    required this.priority,
    required this.isHabit,
    required this.timeframe,
    required this.allowsMultipleCompletions,
    required this.availableTags,
    required this.selectedTags,
    this.isCompleted = false,
    this.currentStreak = 0,
  });

  final String name;
  final String description;
  final DateTime? dueDate;
  final bool hasTime;
  final List<ReminderType> reminders;
  final DifficultyLevel difficulty;
  final PriorityLevel priority;
  final bool isHabit;
  final HabitTimeframe? timeframe;
  final bool allowsMultipleCompletions;
  final List<Tag> availableTags;
  final List<Tag> selectedTags;
  final bool isCompleted;
  final int currentStreak;
}

/// Every mutation the shared form body can trigger, routed by each caller to
/// its own cubit (AddTodoCubit or EditTodoCubit — their method names already
/// line up, this just gives the body a single concrete type to depend on).
class TodoFormCallbacks {
  const TodoFormCallbacks({
    required this.onNameChanged,
    required this.onDescriptionChanged,
    required this.onTagToggled,
    required this.onTagsReloaded,
    required this.onDueDateDaySelected,
    required this.onDueDateTimeSelected,
    required this.onDueDateTimeCleared,
    required this.onReminderToggled,
    required this.onRemindersCleared,
    required this.onDueDateCleared,
    required this.onDifficultyChanged,
    required this.onPriorityChanged,
    required this.onHabitToggled,
    required this.onTimeframeChanged,
    required this.onMultipleCompletionsToggled,
  });

  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onDescriptionChanged;
  final ValueChanged<Tag> onTagToggled;
  final VoidCallback onTagsReloaded;
  final ValueChanged<DateTime> onDueDateDaySelected;
  final ValueChanged<TimeOfDay> onDueDateTimeSelected;
  final VoidCallback onDueDateTimeCleared;
  final ValueChanged<ReminderType> onReminderToggled;
  final VoidCallback onRemindersCleared;
  final VoidCallback onDueDateCleared;
  final ValueChanged<DifficultyLevel> onDifficultyChanged;
  final ValueChanged<PriorityLevel> onPriorityChanged;
  final ValueChanged<bool> onHabitToggled;
  final ValueChanged<HabitTimeframe> onTimeframeChanged;
  final ValueChanged<bool> onMultipleCompletionsToggled;
}

/// Shared body content for the add-todo and edit-todo sheets: title +
/// description text fields, tags, and the Due Date / Difficulty / Priority /
/// Repeats sections. Owns the name/description TextEditingControllers for
/// its lifetime so BlocBuilder rebuilds (which fire on every keystroke)
/// don't reset the fields' cursor/focus mid-type.
class TodoFormBody extends StatefulWidget {
  const TodoFormBody({
    super.key,
    required this.characterId,
    required this.fields,
    required this.callbacks,
    this.showCompletionToggle = true,
    this.onCompletionToggled,
    this.autofocusName = false,
  });

  final String characterId;
  final TodoFormFields fields;
  final TodoFormCallbacks callbacks;

  /// The edit-todo form shows a completion checkbox next to the title;
  /// creating a brand-new todo has nothing to mark complete yet, so the
  /// add-todo form hides it instead of restructuring the row around an
  /// always-unchecked, meaningless toggle.
  final bool showCompletionToggle;
  final VoidCallback? onCompletionToggled;

  /// Opens the keyboard on the title field as soon as the sheet appears —
  /// only wanted when creating a new todo, since editing an existing one
  /// shouldn't yank focus away from wherever the user tapped to get here.
  final bool autofocusName;

  @override
  State<TodoFormBody> createState() => _TodoFormBodyState();
}

class _TodoFormBodyState extends State<TodoFormBody> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fields.name);
    _descriptionController =
        TextEditingController(text: widget.fields.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fields = widget.fields;
    final callbacks = widget.callbacks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            if (widget.showCompletionToggle) ...[
              GestureDetector(
                onTap: widget.onCompletionToggled,
                child: QvCheckBox(
                  width: 32,
                  height: 32,
                  isChecked: fields.isCompleted,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: QvInsetBackground(
                type: QvInsetBackgroundType.secondary,
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: QvTextField(
                  controller: _nameController,
                  hint: 'Todo Name',
                  onChanged: callbacks.onNameChanged,
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  textSize: 24,
                  autofocus: widget.autofocusName,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Description
        QvInsetBackground(
          type: QvInsetBackgroundType.secondary,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SizedBox(
            height: 100,
            child: QvTextField(
              controller: _descriptionController,
              hint: 'Description',
              onChanged: callbacks.onDescriptionChanged,
              textInputAction: TextInputAction.done,
              maxLines: null,
            ),
          ),
        ),

        // Tags section
        const SizedBox(height: 16),
        _buildSectionTitle(context, 'Tags'),
        const SizedBox(height: 8),
        SizedBox(
          height: 30,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fields.availableTags.length + 1,
            itemBuilder: (context, index) {
              if (index == fields.availableTags.length) {
                return TagChip(
                  icon: Icons.add,
                  name: 'Tag',
                  color: Colors.transparent,
                  onPressed: () => CreateCharacterTagPage.showModal(
                    context,
                    widget.characterId,
                    callbacks.onTagsReloaded,
                  ),
                  margin: const EdgeInsets.only(left: 2, right: 50),
                );
              }
              final tag = fields.availableTags[index];
              return TagChip(
                icon: CharacterTag.availableIcons[tag.iconIndex],
                name: tag.name,
                color: CharacterTag.availableColors[tag.colorIndex],
                isSelected: fields.selectedTags.any(
                    (t) => t.characterTagId == tag.characterTagId),
                onPressed: () => callbacks.onTagToggled(tag),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // Details section
        _buildDueDateRow(context, fields, callbacks),
        _buildDifficultyRow(context, fields, callbacks),
        _buildPriorityRow(context, fields, callbacks),
        _buildHabitRow(context, fields, callbacks),
        if (fields.isHabit)
          _buildMultipleCompletionsRow(context, fields, callbacks),
      ],
    );
  }

  Widget _buildDueDateRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return _buildSelectableSection(
      context,
      label: 'Due Date',
      trailing: fields.dueDate != null
          ? GestureDetector(
              onTap: callbacks.onDueDateCleared,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DataFormatters.formatDateTime(
                        fields.dueDate!, fields.hasTime),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: fields.dueDate!.isBefore(DateTime.now()) &&
                              !fields.isCompleted
                          ? colorScheme.error
                          : colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(Symbols.close,
                      color: colorScheme.error, size: 16, weight: 900),
                ],
              ),
            )
          : null,
      child: QvInsetBackground(
        type: QvInsetBackgroundType.secondary,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DueDateEditor(
          selectedDate: fields.dueDate,
          hasTime: fields.hasTime,
          reminders: fields.reminders,
          onDateSelected: callbacks.onDueDateDaySelected,
          onTimeSelected: callbacks.onDueDateTimeSelected,
          onTimeCleared: callbacks.onDueDateTimeCleared,
          onReminderToggled: callbacks.onReminderToggled,
          onRemindersCleared: callbacks.onRemindersCleared,
        ),
      ),
    );
  }

  Widget _buildDifficultyRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
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
        selectedValue: fields.difficulty,
        onChanged: callbacks.onDifficultyChanged,
      ),
    );
  }

  Widget _buildPriorityRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
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
        selectedValue: fields.priority,
        onChanged: callbacks.onPriorityChanged,
      ),
    );
  }

  Widget _buildHabitRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return _buildSelectableSection(
      context,
      label: 'Repeats',
      trailing: fields.isHabit
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
                  '${fields.currentStreak}',
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
            fields.isHabit ? (fields.timeframe ?? HabitTimeframe.daily) : null,
        onChanged: (tf) {
          if (tf == null) {
            callbacks.onHabitToggled(false);
          } else {
            callbacks.onTimeframeChanged(tf);
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

  Widget _buildMultipleCompletionsRow(BuildContext context,
      TodoFormFields fields, TodoFormCallbacks callbacks) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => callbacks
            .onMultipleCompletionsToggled(!fields.allowsMultipleCompletions),
        behavior: HitTestBehavior.translucent,
        child: Row(
          children: [
            QvCheckBox(
              width: 20,
              height: 20,
              isChecked: fields.allowsMultipleCompletions,
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
