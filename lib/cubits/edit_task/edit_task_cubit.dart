import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/edit_task/edit_task_state.dart';
import 'package:questvale/data/models/checklist_item.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/task.dart';
import 'package:questvale/data/repositories/tag_repository.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class EditTaskCubit extends Cubit<EditTaskState> {
  final TaskRepository taskRepository;
  final TagRepository tagRepository;

  EditTaskCubit(this.taskRepository, this.tagRepository, Task? startTask)
      : super(EditTaskState()) {
    if (startTask != null) {
      emit(EditTaskState(
        startTask: startTask,
        name: startTask.name,
        description: startTask.description,
        dueDate: startTask.dueDate,
        difficulty: startTask.difficulty,
        checklist: [
          for (final checklistItem in startTask.checklist)
            ChecklistStateItem(
                id: checklistItem.id,
                name: checklistItem.name,
                isCompleted: checklistItem.isCompleted)
        ],
        tags: const [],
      ));
    }
    loadTags();
  }

  Future<void> loadTags() async {
    List<Tag> tags = await tagRepository.getTags();
    List<String>? stateTagIds =
        state.startTask?.tags.map((Tag e) => e.id).toList();
    emit(state.copyWith(tags: [
      for (Tag tag in tags)
        TaskTags(
          id: tag.id,
          name: tag.name,
          isSelected: stateTagIds?.contains(tag.id) ?? false,
        )
    ]));
  }

  void updateName(String value) {
    emit(state.copyWith(name: value));
  }

  void updateDescription(String value) {
    emit(state.copyWith(description: value));
  }

  void updateDueDate(String value) {
    emit(state.copyWith(dueDate: value));
  }

  void updateDifficulty(DifficultyLevel value) {
    emit(state.copyWith(difficulty: value));
  }

  void addToChecklist(String value) {
    final newChecklist = [
      ...state.checklist,
      ChecklistStateItem(id: Uuid().v1(), name: value, isCompleted: false)
    ];
    emit(state.copyWith(checklist: newChecklist));
  }

  void editChecklistItem(int index, String value) {
    List<ChecklistStateItem> newChecklist = List.from(state.checklist);
    newChecklist[index] = newChecklist[index].copyWith(name: value);
    emit(state.copyWith(checklist: newChecklist));
  }

  void removeChecklistItem(int index) {
    List<ChecklistStateItem> newChecklist = List.from(state.checklist);
    newChecklist.removeAt(index);
    emit(state.copyWith(checklist: newChecklist));
  }

  void updateTag(int index) {
    List<TaskTags> newTags = [
      for (int i = 0; i < state.tags.length; i++)
        i == index
            ? state.tags[i].copyWith(isSelected: !state.tags[i].isSelected)
            : state.tags[i]
    ];
    emit(state.copyWith(tags: newTags));
  }

  Future<void> saveTask() async {
    emit(state.copyWith(status: EditTaskStatus.loading));
    if (state.startTask != null) {
      final updatedTask = state.startTask?.copyWith(
        name: state.name,
        description: state.description,
        difficulty: state.difficulty,
        dueDate: state.dueDate,
      );
      if (updatedTask != null) {
        List<ChecklistItem> checklist = [
          for (ChecklistStateItem item in state.checklist)
            ChecklistItem(
                id: item.id,
                task: updatedTask,
                name: item.name,
                isCompleted: item.isCompleted)
        ];
        List<Tag> tags = [
          for (TaskTags tag in state.tags.where((tag) => tag.isSelected))
            Tag(id: tag.id, name: tag.name)
        ];
        await taskRepository
            .updateTask(updatedTask.copyWith(checklist: checklist, tags: tags));
      }
      emit(state.copyWith(status: EditTaskStatus.done));
    } else {
      Task addTask = Task(
        id: Uuid().v1(),
        name: state.name,
        description: state.description,
        isCompleted: false,
        difficulty: state.difficulty,
        dueDate: state.dueDate,
        tags: [],
        checklist: [],
      );
      List<ChecklistItem> checklist = [
        for (ChecklistStateItem item in state.checklist)
          ChecklistItem(
            id: item.id,
            task: addTask,
            name: item.name,
            isCompleted: item.isCompleted,
          )
      ];
      List<Tag> tags = [
        for (TaskTags tag in state.tags.where((tag) => tag.isSelected))
          Tag(id: tag.id, name: tag.name)
      ];
      await taskRepository
          .addTask(addTask.copyWith(checklist: checklist, tags: tags));
      emit(state.copyWith(status: EditTaskStatus.done));
    }
  }
}
