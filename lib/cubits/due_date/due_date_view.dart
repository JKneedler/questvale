import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/due_date/due_date_cubit.dart';
import 'package:questvale/cubits/due_date/due_date_state.dart';

class DueDateView extends StatelessWidget {
  const DueDateView({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surfaceContainerLow,
      child: BlocBuilder<DueDateCubit, DueDateState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: colorScheme.primary)),
                    ),
                    TextButton(
                      onPressed: () {
                        if (state.selectedDate != null) {
                          context.read<DueDateCubit>().saveDueDate();
                          Navigator.pop(context);
                        }
                      },
                      child: Text('Done',
                          style: TextStyle(color: colorScheme.primary)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                    _QuickSelectButton(
                      icon: Symbols.wb_twilight,
                      label: 'This\nMorning',
                      onTap: () {
                        final now = DateTime.now();
                        context.read<DueDateCubit>().updateSelectedDate(
                            DateTime(now.year, now.month, now.day, 9, 0));
                        context.read<DueDateCubit>().updateSelectedTime(
                            DateTime(now.year, now.month, now.day, 9, 0));
                      },
                    ),
                  ],
                ),
              ),
              Divider(height: 1),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Date',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            padding: EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            'Duration',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: colorScheme.copyWith(
                    primary: colorScheme.primary,
                    onPrimary: colorScheme.onPrimary,
                    surface: colorScheme.surface,
                    onSurface: colorScheme.onSurface,
                  ),
                ),
                child: CalendarDatePicker(
                  initialDate: state.selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                  onDateChanged: (date) =>
                      context.read<DueDateCubit>().updateSelectedDate(date),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _SettingRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: state.selectedTime != null
                          ? '${state.selectedTime!.hour.toString().padLeft(2, '0')}:${state.selectedTime!.minute.toString().padLeft(2, '0')}'
                          : 'None',
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          final now = DateTime.now();
                          final dateTime = DateTime(
                            now.year,
                            now.month,
                            now.day,
                            time.hour,
                            time.minute,
                          );
                          context
                              .read<DueDateCubit>()
                              .updateSelectedTime(dateTime);
                        }
                      },
                    ),
                    _SettingRow(
                      icon: Icons.notifications_none,
                      label: 'Reminder',
                      value: 'None',
                      onTap: () {},
                    ),
                    _SettingRow(
                      icon: Icons.repeat,
                      label: 'Repeat',
                      value: 'None',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: colorScheme.primary),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
              ),
            ),
            SizedBox(height: 4),
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

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurfaceVariant),
            SizedBox(width: 16),
            Text(label,
                style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w500)),
            Spacer(),
            Text(value,
                style: TextStyle(
                    color: colorScheme.onSurfaceVariant, fontSize: 16)),
            Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
