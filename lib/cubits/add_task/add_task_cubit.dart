import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/add_task/add_task_state.dart';
import 'package:questvale/data/models/tag.dart';
import 'package:questvale/data/models/task.dart';
import 'package:questvale/data/repositories/tag_repository.dart';
import 'package:questvale/data/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class AddTaskCubit extends Cubit<AddTaskState> {
  final TaskRepository taskRepository;
  final TagRepository tagRepository;

  AddTaskCubit(this.taskRepository, this.tagRepository)
      : super(AddTaskState(id: Uuid().v1())) {
    loadTags();
  }

  Future<void> loadTags() async {
    List<Tag> tags = await tagRepository.getTags();
    emit(state.copyWith(tags: [
      for (Tag tag in tags)
        TaskTags(
          id: tag.id,
          name: tag.name,
          isSelected: false,
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

  void toggleTag(TaskTags tag) {
    List<TaskTags> newTags = [
      for (TaskTags t in state.tags)
        t.id == tag.id ? t.copyWith(isSelected: !t.isSelected) : t
    ];
    emit(state.copyWith(tags: newTags));
  }

  Future<void> addTask() async {
    emit(state.copyWith(status: AddTaskStatus.loading));

    Task newTask = Task(
      id: Uuid().v1(),
      name: state.name,
      description: state.description,
      isCompleted: false,
      difficulty: state.difficulty,
      dueDate: state.dueDate,
      tags: [],
      checklist: [],
    );

    // List<ChecklistItem> checklist = [
    //   for (ChecklistStateItem item in state.checklist)
    //     ChecklistItem(
    //       id: item.id,
    //       task: newTask,
    //       name: item.name,
    //       isCompleted: item.isCompleted,
    //     )
    // ];

    List<Tag> tags = [
      for (TaskTags tag in state.tags.where((tag) => tag.isSelected))
        Tag(id: tag.id, name: tag.name)
    ];

    await taskRepository.addTask(newTask.copyWith(tags: tags));
    emit(state.copyWith(
      status: AddTaskStatus.initial,
      id: Uuid().v1(),
      name: '',
      description: '',
      dueDate: '',
      difficulty: DifficultyLevel.trivial,
      checklist: [],
      tags: [for (TaskTags t in state.tags) t.copyWith(isSelected: false)],
    ));
  }
}
