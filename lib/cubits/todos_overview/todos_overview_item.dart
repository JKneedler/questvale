import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/widgets/check_box.dart';
import '../../data/models/todo.dart';

class TodosOverviewItem extends StatefulWidget {
  final Todo todo;
  const TodosOverviewItem({super.key, required this.todo});

  @override
  State<TodosOverviewItem> createState() => _TodosOverviewItemState();
}

class _TodosOverviewItemState extends State<TodosOverviewItem> {
  bool isHighlighted = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final todoCubit = context.read<TodosOverviewCubit>();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (context) => todoCubit.deleteTodo(widget.todo),
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
          ],
        ),
        child: AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
                color: isHighlighted
                    ? colorScheme.secondary
                    : colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.all(Radius.circular(6))),
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () async {
                setState(() {
                  isHighlighted = true;
                });
                await Future.delayed(const Duration(milliseconds: 150));
                if (mounted) {
                  setState(() {
                    isHighlighted = false;
                  });
                }
              },
              child: Material(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTapUp: (_) => todoCubit.toggleCompletion(widget.todo),
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          child: CheckBox(
                            width: 20,
                            height: 20,
                            isChecked: widget.todo.isCompleted,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14, bottom: 14),
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.todo.name,
                              softWrap: true,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: widget.todo.isCompleted
                                    ? colorScheme.onPrimaryFixedVariant
                                    : colorScheme.onPrimaryContainer,
                              ),
                            ),
                            if (widget.todo.description.isNotEmpty)
                              Text(
                                widget.todo.description,
                                softWrap: true,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onPrimaryFixedVariant,
                                ),
                              ),
                            if (widget.todo.tags.isNotEmpty)
                              Wrap(
                                spacing: 4,
                                children: widget.todo.tags
                                    .map((tag) => TodoItemTagChip(tag: tag))
                                    .toList(),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ),
    );
  }
}

class TodoItemTagChip extends StatelessWidget {
  final Tag tag;
  const TodoItemTagChip({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 20,
      decoration: BoxDecoration(
        color: Color.lerp(colorScheme.surfaceContainer,
            CharacterTag.availableColors[tag.colorIndex], 0.6),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Center(
        child: Icon(
          CharacterTag.availableIcons[tag.iconIndex],
          color: Color.lerp(
              colorScheme.onPrimary, colorScheme.onPrimaryFixedVariant, 0.3),
          size: 15,
        ),
      ),
    );
  }
}
