import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_state.dart'
    show ReminderType;
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_cubit.dart';
import 'package:questvale/cubits/todo_tab/time_picker/time_picker_view.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:jk_pixel_ui/jk_pixel_ui.dart';

/// Shared due-date editing UI — quick-select shortcuts, full month
/// calendar, time picker, and reminders picker — used both by the
/// full-screen DueDateView modal (add-todo flow) and inline within the
/// edit-todo screen. Fully controlled: the only state it owns is which
/// month the calendar is currently displaying, and every change is
/// reported via callbacks so each caller can route them to its own cubit.
class DueDateEditor extends StatefulWidget {
  const DueDateEditor({
    super.key,
    required this.selectedDate,
    required this.hasTime,
    required this.reminders,
    required this.onDateSelected,
    required this.onTimeSelected,
    required this.onTimeCleared,
    required this.onReminderToggled,
    required this.onRemindersCleared,
  });

  final DateTime? selectedDate;
  final bool hasTime;
  final List<ReminderType> reminders;

  /// Called with the plain calendar day tapped (quick-select shortcut or a
  /// day in the grid) — merging it with any existing time-of-day is left to
  /// the caller's cubit.
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final VoidCallback onTimeCleared;
  final ValueChanged<ReminderType> onReminderToggled;
  final VoidCallback onRemindersCleared;

  @override
  State<DueDateEditor> createState() => _DueDateEditorState();
}

class _DueDateEditorState extends State<DueDateEditor> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    final base = widget.selectedDate ?? DateTime.now();
    _displayedMonth = DateTime(base.year, base.month);
  }

  @override
  void didUpdateWidget(covariant DueDateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Follow the selected date to whatever month it lands in when a
    // quick-select shortcut (e.g. "Next Monday") jumps outside the month
    // currently on screen.
    final date = widget.selectedDate;
    if (date != null &&
        (date.year != oldWidget.selectedDate?.year ||
            date.month != oldWidget.selectedDate?.month)) {
      _displayedMonth = DateTime(date.year, date.month);
    }
  }

  void _changeMonth(int delta) {
    setState(() {
      _displayedMonth =
          DateTime(_displayedMonth.year, _displayedMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _QuickSelectButton(
              icon: Icons.calendar_today,
              label: 'Today',
              onTap: () => widget.onDateSelected(DateTime.now()),
            ),
            _QuickSelectButton(
              icon: Symbols.wb_sunny,
              label: 'Tomorrow',
              onTap: () => widget
                  .onDateSelected(DateTime.now().add(const Duration(days: 1))),
            ),
            _QuickSelectButton(
              icon: Icons.calendar_month,
              label: 'Next\nMonday',
              onTap: () {
                final now = DateTime.now();
                final daysUntilMonday = (8 - now.weekday) % 7;
                widget.onDateSelected(now.add(Duration(days: daysUntilMonday)));
              },
            ),
          ],
        ),
        QvMonthCalendar(
          displayedMonth: _displayedMonth,
          selectedDate: widget.selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          onMonthChanged: _changeMonth,
          onDateSelected: widget.onDateSelected,
        ),
        const SizedBox(height: 16),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              _TimeRow(
                selectedDate: widget.selectedDate,
                hasTime: widget.hasTime,
                onTimeSelected: widget.onTimeSelected,
                onTimeCleared: widget.onTimeCleared,
              ),
              Divider(
                color: Color.lerp(
                    colorScheme.onPrimaryFixedVariant, Colors.transparent, 0.5),
                height: 1,
                indent: 16,
                endIndent: 16,
              ),
              _ReminderRow(
                hasTime: widget.hasTime,
                reminders: widget.reminders,
                onReminderToggled: widget.onReminderToggled,
                onRemindersCleared: widget.onRemindersCleared,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickSelectButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickSelectButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 70,
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 32,
                weight: 900,
                fill: 1,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: QvTextStyles.micro.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  const _TimeRow({
    required this.selectedDate,
    required this.hasTime,
    required this.onTimeSelected,
    required this.onTimeCleared,
  });

  final DateTime? selectedDate;
  final bool hasTime;
  final ValueChanged<TimeOfDay> onTimeSelected;
  final VoidCallback onTimeCleared;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final menuController = MenuController();

    return QVPopupMenu(
      menuController: menuController,
      alignment: AlignmentDirectional.bottomEnd,
      offset: const Offset(-240, -275),
      button: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.access_time,
                color: hasTime ? colorScheme.primary : colorScheme.onSurface,
                size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Time',
                style: QvTextStyles.body.copyWith(
                  color: hasTime ? colorScheme.primary : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              hasTime ? DataFormatters.formatTime(selectedDate!) : 'None',
              style: QvTextStyles.body.copyWith(
                color: hasTime
                    ? colorScheme.primary
                    : colorScheme.onPrimaryFixedVariant,
              ),
            ),
            const SizedBox(width: 10),
            if (!hasTime)
              Icon(Symbols.unfold_more,
                  color: colorScheme.onPrimaryFixedVariant, size: 20),
            if (hasTime)
              GestureDetector(
                onTap: onTimeCleared,
                child: Icon(Symbols.close,
                    color: colorScheme.error, size: 20, weight: 900),
              ),
          ],
        ),
      ),
      menuContents: [
        BlocProvider(
          create: (context) => TimePickerCubit(
            initialTime: hasTime
                ? TimeOfDay(
                    hour: selectedDate!.hour,
                    minute: selectedDate!.minute,
                  )
                : TimeOfDay.now(),
            onTimeSelected: onTimeSelected,
          ),
          child: const TimePickerView(),
        ),
      ],
    );
  }
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.hasTime,
    required this.reminders,
    required this.onReminderToggled,
    required this.onRemindersCleared,
  });

  final bool hasTime;
  final List<ReminderType> reminders;
  final ValueChanged<ReminderType> onReminderToggled;
  final VoidCallback onRemindersCleared;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final menuController = MenuController();

    final options = hasTime
        ? ReminderType.values.sublist(5, 10)
        : ReminderType.values.sublist(0, 5);

    return QVPopupMenu(
      menuController: menuController,
      alignment: AlignmentDirectional.bottomEnd,
      offset: const Offset(-200, -295),
      button: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Symbols.alarm,
                color: reminders.isNotEmpty
                    ? colorScheme.primary
                    : colorScheme.onSurface,
                size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Reminders',
                style: QvTextStyles.body.copyWith(
                  color: reminders.isNotEmpty
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                reminders.isNotEmpty
                    ? reminders.map((e) => e.name).join(', ')
                    : 'None',
                style: QvTextStyles.body.copyWith(
                  color: reminders.isNotEmpty
                      ? colorScheme.primary
                      : colorScheme.onPrimaryFixedVariant,
                ),
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 10),
            if (reminders.isEmpty)
              Icon(Symbols.unfold_more,
                  color: colorScheme.onPrimaryFixedVariant, size: 20),
            if (reminders.isNotEmpty)
              GestureDetector(
                onTap: onRemindersCleared,
                child: Icon(Symbols.close,
                    color: colorScheme.error, size: 20, weight: 900),
              ),
          ],
        ),
      ),
      menuContents: [
        for (final reminderType in options)
          QvPopupMenuCheckItem(
            text: reminderType.name,
            isChecked: reminders.contains(reminderType),
            onPressed: () => onReminderToggled(reminderType),
          ),
      ],
    );
  }
}
