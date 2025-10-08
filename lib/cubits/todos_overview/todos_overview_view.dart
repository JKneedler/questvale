import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_item.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_state.dart';
import 'package:questvale/cubits/add_todo/add_todo_page.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/widgets/qv_app_bar.dart';

class TodosOverviewView extends StatelessWidget {
  const TodosOverviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final todoCubit = context.read<TodosOverviewCubit>();
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: GestureDetector(
        onTap: () async {
          Character? character = todoCubit.state.character;
          if (character != null) {
            await AddTodoPage.showModal(
              context,
              () => todoCubit.loadCharacter(),
              character.id,
            );
          }
        },
        child: Container(
          width: 60,
          height: 60,
          foregroundDecoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/ui/bronze-button-empty-9s-1x.png'),
              centerSlice: Rect.fromLTWH(8, 8, 16, 16),
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
          ),
          decoration: BoxDecoration(
            color: Color(0xff854c30),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Image.asset(
              'images/pixel-icons/plus.png',
              filterQuality: FilterQuality.none,
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),

      // 2️⃣ Position it in the bottom center
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          QVAppBar(),
          Expanded(
            child: BlocBuilder<TodosOverviewCubit, TodosOverviewState>(
                builder: (context, todosOverviewState) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: todosOverviewState.todos.length,
                  padding: const EdgeInsets.only(
                      left: 2, right: 2, top: 10, bottom: 10),
                  itemBuilder: (context, index) {
                    return TodosOverviewItem(
                        todo: todosOverviewState.todos[index]);
                  });
            }),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}
