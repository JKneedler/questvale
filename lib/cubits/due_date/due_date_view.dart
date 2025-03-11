import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/due_date/due_date_cubit.dart';
import 'package:questvale/cubits/due_date/due_date_state.dart';
import 'package:questvale/cubits/time_picker/time_picker_cubit.dart';
import 'package:questvale/cubits/time_picker/time_picker_view.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/widgets/qv_popup_menu.dart';

class DueDateView extends StatelessWidget {
  const DueDateView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: BlocBuilder<DueDateCubit, DueDateState>(
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: colorScheme.primary)),
                    ),
                    if (state.selectedDate != null)
                      GestureDetector(
                        onTap: () {
                          context.read<DueDateCubit>().clearDueDate();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          child: Row(
                            children: [
                              Text(
                                DataFormatters.formatDateTime(
                                    state.selectedDate!, state.hasTime),
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Symbols.close,
                                color: colorScheme.error,
                                size: 20,
                                weight: 900,
                              ),
                            ],
                          ),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        context.read<DueDateCubit>().saveDueDate();
                        Navigator.pop(context);
                      },
                      child: Text('Done',
                          style: TextStyle(color: colorScheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _QuickSelectButton(
                      icon: Icons.calendar_today,
                      label: 'Today',
                      onTap: () {
                        context
                            .read<DueDateCubit>()
                            .updateSelectedDate(DateTime.now());
                      },
                    ),
                    _QuickSelectButton(
                      icon: Symbols.wb_sunny,
                      label: 'Tomorrow',
                      onTap: () {
                        context.read<DueDateCubit>().updateSelectedDate(
                            DateTime.now().add(Duration(days: 1)));
                      },
                    ),
                    _QuickSelectButton(
                      icon: Icons.calendar_month,
                      label: 'Next\nMonday',
                      onTap: () {
                        final now = DateTime.now();
                        final daysUntilMonday = (8 - now.weekday) % 7;
                        context.read<DueDateCubit>().updateSelectedDate(
                            now.add(Duration(days: daysUntilMonday)));
                      },
                    ),
                  ],
                ),
                CalendarDatePicker(
                  key: ValueKey(state.selectedDate),
                  initialDate: state.selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  onDateChanged: (date) =>
                      context.read<DueDateCubit>().updateSelectedDate(date),
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
                      TimeRow(),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          );
        },
      ),
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
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimeRow extends StatelessWidget {
  const TimeRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final state = context.watch<DueDateCubit>().state;
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
                color:
                    state.hasTime ? colorScheme.primary : colorScheme.onSurface,
                size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Time',
                style: TextStyle(
                  color: state.hasTime
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              state.hasTime
                  ? DataFormatters.formatTime(state.selectedDate!)
                  : 'None',
              style: TextStyle(
                color: state.hasTime
                    ? colorScheme.primary
                    : colorScheme.onPrimaryFixedVariant,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 10),
            if (!state.hasTime)
              Icon(Symbols.unfold_more,
                  color: colorScheme.onPrimaryFixedVariant, size: 20),
            if (state.hasTime)
              GestureDetector(
                onTap: () {
                  context.read<DueDateCubit>().clearSelectedTime();
                },
                child: Icon(Symbols.close,
                    color: colorScheme.error, size: 20, weight: 900),
              ),
          ],
        ),
      ),
      menuContents: [
        BlocProvider(
          create: (context) => TimePickerCubit(
            initialTime: state.hasTime
                ? TimeOfDay(
                    hour: state.selectedDate!.hour,
                    minute: state.selectedDate!.minute,
                  )
                : TimeOfDay.now(),
            onTimeSelected: (time) {
              final now = DateTime.now();
              final dateTime = DateTime(
                now.year,
                now.month,
                now.day,
                time.hour,
                time.minute,
              );
              context.read<DueDateCubit>().updateSelectedTime(dateTime);
            },
          ),
          child: const TimePickerView(),
        ),
      ],
    );
  }
}
