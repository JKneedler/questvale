import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/character_tag/create_character_tag_page.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_cubit.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_view.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/data/models/todo_reminder.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_check_box.dart';
import 'package:questvale/widgets/qv_fading_scrollable.dart';
import 'package:questvale/widgets/qv_inset_background.dart';
import 'package:questvale/widgets/qv_month_calendar.dart';
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

  // Local UI-only state for the Due Date / Time / Reminders rows'
  // expand-in-place pickers — never persisted, so a fresh TodoFormBody (new
  // todo, or a different todo loaded into edit) always starts collapsed.
  bool _dateExpanded = false;
  bool _timeExpanded = false;
  bool _remindersExpanded = false;
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.fields.name);
    _descriptionController =
        TextEditingController(text: widget.fields.description);
    final base = widget.fields.dueDate ?? DateTime.now();
    _displayedMonth = DateTime(base.year, base.month);
  }

  @override
  void didUpdateWidget(covariant TodoFormBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow the due date to whatever month it lands in when it's changed
    // from outside the calendar grid (e.g. cleared then re-set elsewhere).
    final date = widget.fields.dueDate;
    if (date != null &&
        (date.year != oldWidget.fields.dueDate?.year ||
            date.month != oldWidget.fields.dueDate?.month)) {
      _displayedMonth = DateTime(date.year, date.month);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
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
          child: QvFadingScrollable(
            direction: Axis.horizontal,
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
                  isSelected: fields.selectedTags
                      .any((t) => t.characterTagId == tag.characterTagId),
                  onPressed: () => callbacks.onTagToggled(tag),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Details section
        _buildDueDateRow(context, fields, callbacks),
        if (fields.dueDate != null) ...[
          _buildTimeRow(context, fields, callbacks),
          _buildReminderRow(context, fields, callbacks),
        ],
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
    final hasDueDate = fields.dueDate != null;

    return _buildSelectableSection(
      context,
      label: 'Due Date',
      child: QvInsetBackground(
        type: QvInsetBackgroundType.secondary,
        width: double.infinity,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildExpandableValueRow(
              context,
              value: hasDueDate
                  ? DataFormatters.formatDateTime(fields.dueDate!, false)
                  : 'None',
              isSet: hasDueDate,
              expanded: _dateExpanded,
              onTap: () => setState(() => _dateExpanded = !_dateExpanded),
              onClear: hasDueDate ? callbacks.onDueDateCleared : null,
            ),
            if (_dateExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: QvMonthCalendar(
                  displayedMonth: _displayedMonth,
                  selectedDate: fields.dueDate,
                  onMonthChanged: _changeMonth,
                  onDateSelected: (date) {
                    callbacks.onDueDateDaySelected(date);
                    setState(() => _dateExpanded = false);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
    return _buildSelectableSection(
      context,
      label: 'Time',
      child: QvInsetBackground(
        type: QvInsetBackgroundType.secondary,
        width: double.infinity,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildExpandableValueRow(
              context,
              value: fields.hasTime
                  ? DataFormatters.formatTime(fields.dueDate!)
                  : 'None',
              isSet: fields.hasTime,
              expanded: _timeExpanded,
              onTap: () => setState(() => _timeExpanded = !_timeExpanded),
              onClear: fields.hasTime ? callbacks.onDueDateTimeCleared : null,
            ),
            if (_timeExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BlocProvider(
                  create: (context) => TimePickerCubit(
                    initialTime: fields.hasTime
                        ? TimeOfDay(
                            hour: fields.dueDate!.hour,
                            minute: fields.dueDate!.minute)
                        : TimeOfDay.now(),
                    onTimeSelected: callbacks.onDueDateTimeSelected,
                  ),
                  child: const TimePickerView(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
    final hasReminders = fields.reminders.isNotEmpty;
    final options = fields.hasTime
        ? ReminderType.values.sublist(5, 10)
        : ReminderType.values.sublist(0, 5);

    return _buildSelectableSection(
      context,
      label: 'Reminders',
      child: QvInsetBackground(
        type: QvInsetBackgroundType.secondary,
        width: double.infinity,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildExpandableValueRow(
              context,
              value: hasReminders
                  ? fields.reminders.map((e) => e.name).join(', ')
                  : 'None',
              isSet: hasReminders,
              expanded: _remindersExpanded,
              onTap: () =>
                  setState(() => _remindersExpanded = !_remindersExpanded),
              onClear: hasReminders ? callbacks.onRemindersCleared : null,
            ),
            if (_remindersExpanded)
              Padding(
                padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
                child: Column(
                  children: [
                    for (final reminderType in options)
                      _buildReminderOptionRow(
                          context, reminderType, fields, callbacks),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderOptionRow(BuildContext context,
      ReminderType reminderType, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final isChecked = fields.reminders.contains(reminderType);

    return GestureDetector(
      onTap: () => callbacks.onReminderToggled(reminderType),
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reminderType.name,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                  color: isChecked
                      ? colorScheme.primary
                      : colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            if (isChecked)
              Icon(Symbols.check, color: colorScheme.primary, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableValueRow(
    BuildContext context, {
    required String value,
    required bool isSet,
    required bool expanded,
    required VoidCallback onTap,
    VoidCallback? onClear,
  }) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: isSet
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onClear != null) ...[
                QvButton(
                  width: 64,
                  height: 36,
                  buttonColor: ButtonColor.surfaceContainer,
                  onTap: onClear,
                  child: Center(
                    child: Text(
                      'Clear',
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Icon(
                expanded ? Symbols.expand_less : Symbols.expand_more,
                color: colorScheme.onSurface,
                size: 20,
              ),
            ],
          ),
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
        itemSize: 40,
        highlightWidthFraction: 0.9,
        items: [
          const QvSegmentedControlItem(
            value: null,
            label: 'None',
          ),
          for (final tf in HabitTimeframe.values)
            QvSegmentedControlItem(
              value: tf,
              label: tf.name,
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
