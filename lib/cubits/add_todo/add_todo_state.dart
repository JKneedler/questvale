import 'package:equatable/equatable.dart';

enum AddTodoStatus { initial, loading, done }

class AddTodoState extends Equatable {
  final AddTodoStatus status;
  final String id;
  final String name;
  final String description;
  final String dueDate;
  final int difficulty;

  const AddTodoState({
    this.status = AddTodoStatus.initial,
    required this.id,
    this.name = '',
    this.description = '',
    this.dueDate = '',
    this.difficulty = 1,
  });

  AddTodoState copyWith({
    AddTodoStatus? status,
    String? id,
    String? name,
    String? description,
    String? dueDate,
    int? difficulty,
  }) {
    return AddTodoState(
      status: status ?? this.status,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  @override
  List<Object> get props => [
        status,
        id,
        name,
        description,
        dueDate,
        difficulty,
      ];
}
