import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_item.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_state.dart';
import 'package:questvale/cubits/todo_tab/add_todo/add_todo_page.dart';
import 'package:questvale/cubits/todo_tab/todos_calendar/todos_calendar_view.dart';
import 'package:questvale/data/models/character.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/todo.dart';
import 'package:questvale/helpers/constants.dart';
import 'package:questvale/widgets/qv_app_bar.dart';
import 'package:questvale/widgets/qv_inset_background.dart';

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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
              image: AssetImage('images/ui/buttons/button-primary.png'),
              centerSlice: STANDARD_BORDER_SLICE,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.none,
            ),
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
          QvAppBar(
            leading: BlocBuilder<TodosOverviewCubit, TodosOverviewState>(
              builder: (context, state) => _ApDisplay(
                actionPoints: state.character?.actionPoints ?? 0,
              ),
            ),
            trailingButton: QvAppBarButton(
              button: '⋮',
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: colorScheme.surfaceContainer,
                builder: (context) => BlocProvider.value(
                  value: todoCubit,
                  child: const TodosOverviewMenuSheet(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
              ),
              child: BlocBuilder<TodosOverviewCubit, TodosOverviewState>(
                  builder: (context, todosOverviewState) {
                if (todosOverviewState.viewMode == TodosViewMode.calendar) {
                  return const TodosCalendarBody();
                }
                final visibleTodos = todosOverviewState.visibleTodos;
                return ListView.builder(
                    shrinkWrap: true,
                    itemCount: visibleTodos.length,
                    padding: const EdgeInsets.only(
                        left: 6, right: 6, top: 10, bottom: 10),
                    itemBuilder: (context, index) {
                      final todo = visibleTodos[index];
                      return TodosOverviewItem(
                          key: ValueKey(todo.id), todo: todo);
                    });
              }),
            ),
          ),
        ],
      ),
      backgroundColor: colorScheme.surface,
    );
  }
}

class _ApDisplay extends StatelessWidget {
  final int actionPoints;

  const _ApDisplay({required this.actionPoints});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return QvInsetBackground(
      type: QvInsetBackgroundType.secondary,
      padding: const EdgeInsets.only(top: 2, bottom: 6, left: 20, right: 20),
      child: Center(
        child: Text(
          '$actionPoints',
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class TodosOverviewMenuSheet extends StatelessWidget {
  const TodosOverviewMenuSheet({super.key});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final cubit = context.read<TodosOverviewCubit>();
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MenuRow(
              icon: Symbols.filter_alt,
              label: 'Filter',
              onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: colorScheme.surfaceContainer,
                    builder: (context) => BlocProvider.value(
                      value: cubit,
                      child: const TodosFilterSheet(),
                    ),
                  )),
          _MenuRow(
              icon: Symbols.sort,
              label: 'Sort',
              onTap: () => showModalBottomSheet(
                    context: context,
                    backgroundColor: colorScheme.surfaceContainer,
                    builder: (context) => BlocProvider.value(
                      value: cubit,
                      child: const TodosSortSheet(),
                    ),
                  )),
          _MenuRow(
              icon: cubit.state.viewMode == TodosViewMode.calendar
                  ? Symbols.list
                  : Symbols.calendar_month,
              label: cubit.state.viewMode == TodosViewMode.calendar
                  ? 'Swap to List View'
                  : 'Swap to Calendar View',
              onTap: () {
                cubit.setViewMode(
                  cubit.state.viewMode == TodosViewMode.calendar
                      ? TodosViewMode.list
                      : TodosViewMode.calendar,
                );
                Navigator.pop(context);
              }),
        ],
      ),
    );
  }
}

class TodosFilterSheet extends StatefulWidget {
  const TodosFilterSheet({super.key});

  @override
  State<TodosFilterSheet> createState() => _TodosFilterSheetState();
}

class _TodosFilterSheetState extends State<TodosFilterSheet> {
  TodoFilter? expanded;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TodosOverviewCubit>();
    final state = cubit.state;

    void apply(TodoFilter filter, {Tag? tag, PriorityLevel? priority}) {
      cubit.setFilter(filter, tag: tag, priority: priority);
      Navigator.of(context).popUntil((route) => route.isFirst);
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final f in [
            TodoFilter.none,
            TodoFilter.today,
            TodoFilter.thisWeek,
            TodoFilter.all,
            TodoFilter.completed,
          ])
            _FilterOptionRow(
              label: f.name,
              isSelected: state.filter == f,
              onTap: () => apply(f),
            ),
          _FilterOptionRow(
            label: TodoFilter.byTag.name,
            isSelected: state.filter == TodoFilter.byTag,
            onTap: () => setState(() => expanded =
                expanded == TodoFilter.byTag ? null : TodoFilter.byTag),
          ),
          if (expanded == TodoFilter.byTag)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.availableTags
                    .map((tag) => _ChoiceChip(
                          label: tag.name,
                          isSelected: state.filterTag?.characterTagId ==
                              tag.characterTagId,
                          onTap: () => apply(TodoFilter.byTag, tag: tag),
                        ))
                    .toList(),
              ),
            ),
          _FilterOptionRow(
            label: TodoFilter.byPriority.name,
            isSelected: state.filter == TodoFilter.byPriority,
            onTap: () => setState(() => expanded =
                expanded == TodoFilter.byPriority
                    ? null
                    : TodoFilter.byPriority),
          ),
          if (expanded == TodoFilter.byPriority)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PriorityLevel.values
                    .map((p) => _ChoiceChip(
                          label: p.name,
                          isSelected: state.filterPriority == p,
                          onTap: () =>
                              apply(TodoFilter.byPriority, priority: p),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class TodosSortSheet extends StatelessWidget {
  const TodosSortSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TodosOverviewCubit>();
    final state = cubit.state;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final s in TodoSort.values)
            _FilterOptionRow(
              label: s.name,
              isSelected: state.sort == s,
              onTap: () {
                cubit.setSort(s);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
        ],
      ),
    );
  }
}

class _FilterOptionRow extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOptionRow({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color:
                      isSelected ? colorScheme.primary : colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Symbols.check, color: colorScheme.primary, size: 20),
          ],
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChoiceChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.surface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuRow(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.onSurface, size: 20),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
