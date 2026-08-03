import 'package:equatable/equatable.dart';

enum CreateCharacterTagStatus { initial, loading, success, failure }

class CreateCharacterTagState extends Equatable {
  final CreateCharacterTagStatus status;
  final String name;
  final String? errorMessage;

  const CreateCharacterTagState({
    this.status = CreateCharacterTagStatus.initial,
    this.name = '',
    this.errorMessage,
  });

  CreateCharacterTagState copyWith({
    CreateCharacterTagStatus? status,
    String? name,
    String? errorMessage,
  }) {
    return CreateCharacterTagState(
      status: status ?? this.status,
      name: name ?? this.name,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, name, errorMessage];
}
