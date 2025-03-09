import 'package:equatable/equatable.dart';

enum CreateCharacterTagStatus { initial, loading, success, failure }

class CreateCharacterTagState extends Equatable {
  final CreateCharacterTagStatus status;
  final String name;
  final int colorIndex;
  final int iconIndex;
  final String? errorMessage;

  const CreateCharacterTagState({
    this.status = CreateCharacterTagStatus.initial,
    this.name = '',
    this.colorIndex = 0,
    this.iconIndex = 0,
    this.errorMessage,
  });

  CreateCharacterTagState copyWith({
    CreateCharacterTagStatus? status,
    String? name,
    int? colorIndex,
    int? iconIndex,
    String? errorMessage,
  }) {
    return CreateCharacterTagState(
      status: status ?? this.status,
      name: name ?? this.name,
      colorIndex: colorIndex ?? this.colorIndex,
      iconIndex: iconIndex ?? this.iconIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, name, colorIndex, iconIndex, errorMessage];
}
