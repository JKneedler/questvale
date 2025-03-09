import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/data/repositories/todo_repository.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tr = TodoRepository(db: context.read<Database>());
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              'Log Todos',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            leading: Icon(Icons.list, color: colorScheme.primary),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            onTap: () => tr.getTodos().then((todos) => print(todos)),
          ),
          ListTile(
            title: Text(
              'Log TodoTags',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            leading: Icon(Icons.tag, color: colorScheme.primary),
            contentPadding: const EdgeInsets.only(left: 30, right: 30),
            onTap: () => print('TodoTags logging not implemented'),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}
