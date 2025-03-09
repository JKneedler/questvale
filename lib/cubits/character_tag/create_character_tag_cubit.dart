import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:questvale/cubits/character_tag/create_character_tag_state.dart';
import 'package:questvale/data/models/character_tag.dart';
import 'package:questvale/data/repositories/character_repository.dart';
import 'package:uuid/uuid.dart';

class CreateCharacterTagCubit extends Cubit<CreateCharacterTagState> {
  final CharacterRepository characterRepository;
  final String characterId;

  CreateCharacterTagCubit(this.characterRepository, this.characterId)
      : super(const CreateCharacterTagState());

  void nameChanged(String value) {
    emit(state.copyWith(name: value));
  }

  void colorIndexChanged(int value) {
    emit(state.copyWith(colorIndex: value));
  }

  void iconIndexChanged(int value) {
    emit(state.copyWith(iconIndex: value));
  }

  Future<void> submit() async {
    if (state.name.isEmpty) {
      emit(state.copyWith(
        status: CreateCharacterTagStatus.failure,
        errorMessage: 'Name cannot be empty',
      ));
      return;
    }

    emit(state.copyWith(status: CreateCharacterTagStatus.loading));

    try {
      final tag = CharacterTag(
        id: const Uuid().v4(),
        characterId: characterId,
        name: state.name,
        colorIndex: state.colorIndex,
        iconIndex: state.iconIndex,
      );

      await characterRepository.createCharacterTag(tag);
      emit(state.copyWith(status: CreateCharacterTagStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: CreateCharacterTagStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
