import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_item.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_state.dart';
import 'package:questvale/cubits/add_todo/add_todo_page.dart';

class TodosOverviewView extends StatelessWidget {
  const TodosOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final todoCubit = context.read<TodosOverviewCubit>();
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text('Questvale', style: TextStyle(color: colorScheme.onSurface)),
        backgroundColor: colorScheme.surface,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        shape: CircleBorder(),
        onPressed: () async {
          await AddTodoPage.showModal(
            context,
            () => todoCubit.loadTodos(),
          );
        },
        child: Icon(
          Icons.add,
          size: 32,
          color: colorScheme.onPrimary,
        ),
      ),
      body: Expanded(child: BlocBuilder<TodosOverviewCubit, TodosOverviewState>(
          builder: (context, todosOverviewState) {
        return ListView.builder(
            shrinkWrap: true,
            itemCount: todosOverviewState.todos.length,
            padding: const EdgeInsets.all(2),
            itemBuilder: (context, index) {
              return TodosOverviewItem(todo: todosOverviewState.todos[index]);
            });
      })),
      backgroundColor: colorScheme.surface,
    );
  }
}
