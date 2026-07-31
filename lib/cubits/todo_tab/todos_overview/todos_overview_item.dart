import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:questvale/cubits/todo_tab/todos_overview/todos_overview_cubit.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/helpers/data_formatters.dart';
import 'package:questvale/cubits/todo_tab/edit_todo/edit_todo_page.dart';
import 'package:questvale/widgets/qv_ap_toast.dart';
import 'package:questvale/widgets/qv_button.dart';
import 'package:questvale/widgets/qv_check_box.dart';
import '../../../data/models/todo.dart';

class TodosOverviewItem extends StatefulWidget {
  final Todo todo;
  const TodosOverviewItem({super.key, required this.todo});

  @override
  State<TodosOverviewItem> createState() => _TodosOverviewItemState();
}

class _TodosOverviewItemState extends State<TodosOverviewItem> {
  bool isHighlighted = false;
  bool _fadingOut = false;

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    final todoCubit = context.read<TodosOverviewCubit>();
    final isPastDue = widget.todo.dueDate != null &&
        widget.todo.dueDate!.isBefore(DateTime.now());

    return AnimatedOpacity(
      opacity: _fadingOut ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(widget.todo.id),
        margin: const EdgeInsets.only(bottom: 10),
        child: QvButton(
          buttonColor: ButtonColor.surfaceContainer,
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
                  onTapUp: (_) async {
                    final isMultiCheck = widget.todo.isHabit &&
                        widget.todo.allowsMultipleCompletions;
                    final isCompletingNow = !widget.todo.isCompleted;
                    if (!isMultiCheck && isCompletingNow) {
                      setState(() => _fadingOut = true);
                      await Future.delayed(const Duration(milliseconds: 300));
                      if (!mounted) return;
                    }
                    final apEarned = widget.todo.isHabit
                        ? await todoCubit.completeHabitOnce(widget.todo)
                        : await todoCubit.toggleCompletion(widget.todo);
                    if (apEarned > 0 && mounted) {
                      showApToast(context, apEarned);
                    }
                  },
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      child: widget.todo.isHabit &&
                              widget.todo.allowsMultipleCompletions
                          ? MultiCheckIndicator(
                              count: widget.todo.completionsInCurrentPeriod,
                            )
                          : QvCheckBox(
                              width: 24,
                              height: 24,
                              isChecked: widget.todo.isCompleted,
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                    child: Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.todo.name,
                          softWrap: true,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: widget.todo.isCompleted
                                ? colorScheme.onSurface.withValues(alpha: 0.5)
                                : colorScheme.onSurface,
                          ),
                        ),
                        if (widget.todo.description.isNotEmpty)
                          Text(
                            widget.todo.description,
                            softWrap: true,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                        if (widget.todo.tags.isNotEmpty)
                          Wrap(
                            spacing: 6,
                            children: widget.todo.tags
                                .map((tag) => TodoItemTagChip(tag: tag))
                                .toList(),
                          ),
                        Row(
                          children: [
                            if (widget.todo.isHabit)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Symbols.local_fire_department,
                                    color: colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${widget.todo.currentStreak}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                            if (widget.todo.difficulty !=
                                DifficultyLevel.trivial)
                              Icon(
                                Symbols.trophy,
                                color: widget.todo.difficulty.color,
                                size: 18,
                              ),
                            const SizedBox(width: 6),
                            if (widget.todo.dueDate != null)
                              Text(
                                DataFormatters.formatDateTime(
                                    widget.todo.dueDate!,
                                    widget.todo.hasTime),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isPastDue
                                      ? colorScheme.error
                                      : colorScheme.onSurface
                                          .withValues(alpha: 0.5),
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
      ),
    );
  }
}

class MultiCheckIndicator extends StatelessWidget {
  final int count;
  const MultiCheckIndicator({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Symbols.add,
            size: 20,
            weight: 700,
            color: colorScheme.onSurface,
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
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
      width: 46,
      height: 24,
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
          size: 17,
        ),
      ),
    );
  }
}
