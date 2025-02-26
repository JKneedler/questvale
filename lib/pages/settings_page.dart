import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = TaskRepository(db: context.read<Database>().database);
    final cr = CharacterRepository(db: context.read<Database>().database);
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(color: colorScheme.onPrimary),
        ),
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
      ),
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 10,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingButton(
              name: 'Log Tasks',
              onPressed: () => tr.logTasks(),
            ),
            SettingButton(
              name: 'Log Checklist Items',
              onPressed: () => tr.logChecklistItems(),
            ),
            SettingButton(
              name: 'Log Tags',
              onPressed: () => tr.logTags(),
            ),
            SettingButton(
              name: 'Log TaskTags',
              onPressed: () => tr.logTaskTags(),
            ),
            SettingButton(
              name: 'Log Characters',
              onPressed: () => cr.printCharacters(),
            ),
            SettingButton(
              name: 'Log Quests',
              onPressed: () => cr.printQuests(),
            ),
            SettingButton(
              name: 'Log Equipment',
              onPressed: () => cr.printEquipment(),
            )
          ],
        ),
      ),
    );
  }
}

class SettingButton extends StatelessWidget {
  final String name;
  final Function() onPressed;

  const SettingButton({super.key, required this.name, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 60,
      child: TextButton(
        onPressed: () => onPressed(),
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
              side: BorderSide(width: 2, color: colorScheme.secondary),
              borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
        child: Text(
          name,
          style: TextStyle(color: colorScheme.onSurface),
        ),
      ),
    );
  }
}
