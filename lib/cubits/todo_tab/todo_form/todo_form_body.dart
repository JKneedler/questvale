import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:questvale/widgets/qv_number_wheel_picker.dart';
import 'package:questvale/widgets/qv_segmented_control.dart';
import 'package:questvale/widgets/qv_tag_chip.dart';
import 'package:questvale/widgets/qv_textfield.dart';
import 'package:questvale/widgets/qv_weekday_selector.dart';

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
    this.repeatInterval = 1,
    this.repeatWeekdays = const {},
    this.monthlyRepeatMode = MonthlyRepeatMode.dayOfMonth,
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
  final int repeatInterval;
  final Set<int> repeatWeekdays;
  final MonthlyRepeatMode monthlyRepeatMode;
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
    required this.onRepeatIntervalChanged,
    required this.onRepeatWeekdayToggled,
    required this.onMonthlyRepeatModeChanged,
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
  final ValueChanged<int> onRepeatIntervalChanged;
  final ValueChanged<int> onRepeatWeekdayToggled;
  final ValueChanged<MonthlyRepeatMode> onMonthlyRepeatModeChanged;
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
  bool _intervalExpanded = false;
  late DateTime _displayedMonth;

  // Keys on each expandable section's outer container, so that expanding one
  // can scroll the sheet's outer SingleChildScrollView (from TodoFormSheet)
  // just far enough that the whole newly-expanded section — not just the
  // sliver of it that happened to already be on screen — ends up visible.
  final GlobalKey _dueDateSectionKey = GlobalKey();
  final GlobalKey _timeSectionKey = GlobalKey();
  final GlobalKey _remindersSectionKey = GlobalKey();
  final GlobalKey _intervalSectionKey = GlobalKey();

  // Covers the whole Repeats section (segmented control + interval row +
  // weekday selector / monthly toggle), so picking any timeframe other than
  // None can reveal everything that unlocks below it, not just the row that
  // was tapped.
  final GlobalKey _repeatsSectionKey = GlobalKey();

  // Scrolling has to wait until the frame after the state change that grows
  // a section — only then does its RenderBox reflect the new, taller size.
  // Computes the same target offset Scrollable.ensureVisible(alignment: 1.0)
  // would (pins the section's bottom edge to the viewport's bottom edge),
  // but only animates there when that offset is further down than the
  // current scroll position — so a section that's already fully visible
  // (e.g. collapsing a row further down freed up space above it) never gets
  // yanked upward to satisfy the alignment.
  void _scrollExpandedSectionIntoView(GlobalKey key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sectionContext = key.currentContext;
      if (sectionContext == null) return;
      final renderObject = sectionContext.findRenderObject();
      if (renderObject == null) return;
      final scrollable = Scrollable.maybeOf(sectionContext);
      if (scrollable == null) return;
      final position = scrollable.position;
      final viewport = RenderAbstractViewport.of(renderObject);
      final targetOffset = viewport
          .getOffsetToReveal(renderObject, 1.0)
          .offset
          .clamp(position.minScrollExtent, position.maxScrollExtent);
      if (targetOffset > position.pixels) {
        position.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

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

    // Picking any Repeats option other than None should reveal everything
    // that choice unlocks (interval wheel, weekday selector, monthly
    // toggle) — not just whatever row the user happened to tap. Fires both
    // when a habit is freshly turned on and when the timeframe is switched
    // (e.g. Daily -> Weekly reveals the weekday selector that Daily doesn't
    // have).
    final wasUnset =
        !oldWidget.fields.isHabit || oldWidget.fields.timeframe == null;
    final isNowSet = widget.fields.isHabit && widget.fields.timeframe != null;
    final timeframeChanged =
        oldWidget.fields.timeframe != widget.fields.timeframe;
    if (isNowSet && (wasUnset || timeframeChanged)) {
      _scrollExpandedSectionIntoView(_repeatsSectionKey);
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
        KeyedSubtree(
          key: _repeatsSectionKey,
          child: _buildHabitRow(context, fields, callbacks),
        ),
        _buildDifficultyRow(context, fields, callbacks),
        _buildPriorityRow(context, fields, callbacks),
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
        key: _dueDateSectionKey,
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
              onTap: () => setState(() {
                _dateExpanded = !_dateExpanded;
                if (_dateExpanded) {
                  _scrollExpandedSectionIntoView(_dueDateSectionKey);
                }
              }),
              onClear: hasDueDate ? callbacks.onDueDateCleared : null,
            ),
            if (_dateExpanded)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: QvMonthCalendar(
                  displayedMonth: _displayedMonth,
                  selectedDate: fields.dueDate,
                  onMonthChanged: _changeMonth,
                  onDateSelected: callbacks.onDueDateDaySelected,
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
        key: _timeSectionKey,
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
              onTap: () => setState(() {
                _timeExpanded = !_timeExpanded;
                if (_timeExpanded) {
                  _scrollExpandedSectionIntoView(_timeSectionKey);
                }
              }),
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
        key: _remindersSectionKey,
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
              onTap: () => setState(() {
                _remindersExpanded = !_remindersExpanded;
                if (_remindersExpanded) {
                  _scrollExpandedSectionIntoView(_remindersSectionKey);
                }
              }),
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

  Widget _buildReminderOptionRow(
      BuildContext context,
      ReminderType reminderType,
      TodoFormFields fields,
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
      child: Column(
        children: [
          QvSegmentedControl<HabitTimeframe?>(
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
            selectedValue: fields.isHabit
                ? (fields.timeframe ?? HabitTimeframe.daily)
                : null,
            onChanged: (tf) {
              if (tf == null) {
                callbacks.onHabitToggled(false);
              } else {
                callbacks.onTimeframeChanged(tf);
              }
            },
          ),
          if (fields.isHabit && fields.timeframe != null) ...[
            const SizedBox(height: 10),
            _buildRepeatIntervalRow(context, fields, callbacks),
            if (fields.timeframe == HabitTimeframe.weekly) ...[
              const SizedBox(height: 10),
              QvWeekdaySelector(
                selectedWeekdays: fields.repeatWeekdays,
                onToggled: callbacks.onRepeatWeekdayToggled,
              ),
            ],
            if (fields.timeframe == HabitTimeframe.monthly) ...[
              const SizedBox(height: 10),
              _buildMonthlyRepeatModeRow(context, fields, callbacks),
            ],
            const SizedBox(height: 14),
            _buildMultipleCompletionsRow(context, fields, callbacks),
          ],
        ],
      ),
    );
  }

  Widget _buildRepeatIntervalRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
    final timeframe = fields.timeframe!;
    final int min;
    final int max;
    switch (timeframe) {
      case HabitTimeframe.daily:
        min = 1;
        max = 30;
        break;
      case HabitTimeframe.weekly:
        min = 1;
        max = 52;
        break;
      case HabitTimeframe.monthly:
        min = 1;
        max = 12;
        break;
    }

    return QvInsetBackground(
      key: _intervalSectionKey,
      type: QvInsetBackgroundType.secondary,
      width: double.infinity,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildExpandableValueRow(
            context,
            value: DataFormatters.formatRepeatInterval(
                fields.repeatInterval, timeframe),
            isSet: true,
            expanded: _intervalExpanded,
            onTap: () => setState(() {
              _intervalExpanded = !_intervalExpanded;
              if (_intervalExpanded) {
                _scrollExpandedSectionIntoView(_intervalSectionKey);
              }
            }),
          ),
          if (_intervalExpanded)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: QvNumberWheelPicker(
                min: min,
                max: max,
                selectedValue: fields.repeatInterval.clamp(min, max),
                onChanged: callbacks.onRepeatIntervalChanged,
                wheelHeight: 120,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMonthlyRepeatModeRow(BuildContext context, TodoFormFields fields,
      TodoFormCallbacks callbacks) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final reference = fields.dueDate ?? DateTime.now();
    final ordinalInMonth = ((reference.day - 1) ~/ 7) + 1;
    final description = fields.monthlyRepeatMode == MonthlyRepeatMode.dayOfMonth
        ? 'Repeats on the ${DataFormatters.ordinal(reference.day)}'
        : 'Repeats on the ${DataFormatters.ordinal(ordinalInMonth)} '
            '${DataFormatters.weekdayName(reference.weekday)}';

    return Column(
      children: [
        QvSegmentedControl<MonthlyRepeatMode>(
          itemSize: 40,
          highlightWidthFraction: 0.9,
          items: [
            for (final mode in MonthlyRepeatMode.values)
              QvSegmentedControlItem(
                value: mode,
                label: mode.name,
              ),
          ],
          selectedValue: fields.monthlyRepeatMode,
          onChanged: callbacks.onMonthlyRepeatModeChanged,
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
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

    return GestureDetector(
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
            'Allow multiple completions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurface,
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
