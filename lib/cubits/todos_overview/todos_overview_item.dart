import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/cubits/edit_todo/edit_todo_page.dart';
import 'package:questvale/widgets/qv_check_box.dart';
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
    final isPastDue = widget.todo.dueDate != null &&
        widget.todo.dueDate!.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/ui/buttons/white-button-filled-2x.png'),
          centerSlice: Rect.fromLTWH(16, 16, 32, 32),
          fit: BoxFit.fill,
          filterQuality: FilterQuality.none,
        ),
      ),
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
            EditTodoPage.show(context, widget.todo);
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
                    child: QvCheckBox(
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
                      Row(
                        children: [
                          if (widget.todo.difficulty != DifficultyLevel.trivial)
                            Icon(
                              Symbols.trophy,
                              color: widget.todo.difficulty.color,
                              size: 16,
                            ),
                          const SizedBox(width: 4),
                          if (widget.todo.dueDate != null)
                            Text(
                              DataFormatters.formatDateTime(
                                  widget.todo.dueDate!, widget.todo.hasTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: isPastDue
                                    ? colorScheme.error
                                    : colorScheme.primary,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
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
